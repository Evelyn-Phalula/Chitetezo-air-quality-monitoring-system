
import RPi.GPIO as GPIO     # Import Library to access GPIO PIN
from urllib.parse import urlparse
import paho.mqtt.client as paho
import os,sys
import time
import serial
import requests
import websockets
import asyncio
import pymysql
import datetime
import Adafruit_DHT
import json
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import Adafruit_ADS1x15
GPIO.setmode(GPIO.BOARD)    # Consider complete raspberry-pi board
GPIO.setwarnings(False)     # To avoid same PIN use warning

# Define GPIO to LCD mapping
LCD_RS = 7
LCD_E  = 11
LCD_D4 = 12
LCD_D5 = 13
LCD_D6 = 15
LCD_D7 = 16
Buzzer = 29               # Define PIN for Buzzer
MQ2_Pin = 18                 # Define PIN for MQ2 Sensor
Led_light = 31 
GPIO.setup(Buzzer,GPIO.OUT)   # Set pin function as output
GPIO.setup(MQ2_Pin,GPIO.IN,pull_up_down=GPIO.PUD_UP)   # Set pin function as input
GPIO.setup(LCD_E, GPIO.OUT)  # E
GPIO.setup(LCD_RS, GPIO.OUT) # RS
GPIO.setup(LCD_D4, GPIO.OUT) # DB4
GPIO.setup(LCD_D5, GPIO.OUT) # DB5
GPIO.setup(LCD_D6, GPIO.OUT) # DB6
GPIO.setup(LCD_D7, GPIO.OUT) # DB7
GPIO.setup(Led_light, GPIO.OUT)

#Temperature and Humidity
sensor = Adafruit_DHT.DHT22
pin = 21
humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)

def on_connect(self, mosq, obj, rc):
        self.subscribe("Fan", 0)
    
def on_publish(mosq, obj, mid):
    print("mid: " + str(mid))

mqttc = paho.Client()                        
#object declaration
# Assign event callbacks
mqttc.on_connect = on_connect
mqttc.on_publish = on_publish

url_str = os.environ.get('CLOUDMQTT_URL', 'tcp://broker.emqx.io:1883') 
url = urlparse(url_str)
mqttc.connect(url.hostname, url.port)

# Timing constants
E_PULSE = 0.0005
E_DELAY = 0.0005
delay = 1

#Thingspeak channell setting
API_KEY = "6KHN0XMGLQA9YORI"
BASE_URL = f'https://api.thingspeak.com/update?api_key={API_KEY}'

# Define some device constants
LCD_WIDTH = 16    # Maximum characters per line
LCD_CHR = True
LCD_CMD = False
LCD_LINE_1 = 0x80 # LCD RAM address for the 1st line
LCD_LINE_2 = 0xC0 # LCD RAM address for the 2nd line
LCD_LINE_3 = 0x90# LCD RAM address for the 3nd line

'''
Function Name :lcd_init()
Function Description : this function is used to initialized lcd by sending the different commands
'''
def lcd_init():
  # Initialise display
  lcd_byte(0x33,LCD_CMD) # 110011 Initialise
  lcd_byte(0x32,LCD_CMD) # 110010 Initialise
  lcd_byte(0x06,LCD_CMD) # 000110 Cursor move direction
  lcd_byte(0x0C,LCD_CMD) # 001100 Display On,Cursor Off, Blink Off
  lcd_byte(0x28,LCD_CMD) # 101000 Data length, number of lines, font size
  lcd_byte(0x01,LCD_CMD) # 000001 Clear display
  time.sleep(E_DELAY)
'''
Function Name :lcd_byte(bits ,mode)
Fuction Name :the main purpose of this function to convert the byte data into bit and send to lcd port
'''
def lcd_byte(bits, mode):
  # Send byte to data pins
  # bits = data
  # mode = True  for character
  #        False for command
 
  GPIO.output(LCD_RS, mode) # RS
 
  # High bits
  GPIO.output(LCD_D4, False)
  GPIO.output(LCD_D5, False)
  GPIO.output(LCD_D6, False)
  GPIO.output(LCD_D7, False)
  if bits&0x10==0x10:
    GPIO.output(LCD_D4, True)
  if bits&0x20==0x20:
    GPIO.output(LCD_D5, True)
  if bits&0x40==0x40:
    GPIO.output(LCD_D6, True)
  if bits&0x80==0x80:
    GPIO.output(LCD_D7, True)
 
  # Toggle 'Enable' pin
  lcd_toggle_enable()
 
  # Low bits
  GPIO.output(LCD_D4, False)
  GPIO.output(LCD_D5, False)
  GPIO.output(LCD_D6, False)
  GPIO.output(LCD_D7, False)
  if bits&0x01==0x01:
    GPIO.output(LCD_D4, True)
  if bits&0x02==0x02:
    GPIO.output(LCD_D5, True)
  if bits&0x04==0x04:
    GPIO.output(LCD_D6, True)
  if bits&0x08==0x08:
    GPIO.output(LCD_D7, True)
 
  # Toggle 'Enable' pin
  lcd_toggle_enable()
'''
Function Name : lcd_toggle_enable()
Function Description: this is used to toggle the Enable pin
'''
def lcd_toggle_enable():
  # Toggle enable
  time.sleep(E_DELAY)
  GPIO.output(LCD_E, True)
  time.sleep(E_PULSE)
  GPIO.output(LCD_E, False)
  time.sleep(E_DELAY)
'''
Function Name :lcd_string(message,line)
Function  Description : print data on lcd 
'''
def lcd_string(message,line):
  # Send string to display
 
  message = message.ljust(LCD_WIDTH," ")
 
  lcd_byte(line, LCD_CMD)
 
  for i in range(LCD_WIDTH):
    lcd_byte(ord(message[i]),LCD_CHR)

lcd_init()
lcd_string("Welcome Everyone",LCD_LINE_1)
lcd_string("This is GRoup 12",LCD_LINE_2)
time.sleep(2)
lcd_string("Chitetezo Air Pollution",LCD_LINE_1)
lcd_string("Monitoring System ",LCD_LINE_2)
time.sleep(2)
lcd_byte(0x01,LCD_CMD) # 000001 Clear display
# Define delay between readings
delay = 5
'''
#This statement get data from serial port where arduino is conected and flushes the data
if __name__ == '__main__':
    ser = serial.Serial('/dev/ttyACM0', 9600, timeout=1)
    ser.flush()
'''
# Initialize Firebase with your credentials
cred = credentials.Certificate('/home/ZuzuTech/Desktop/CHITETEZO-AIR-POLLUTION-MONITORING-SYSTEM/chitetezo-6f57d-firebase-adminsdk-1r0do-8b8b8a8f29.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://chitetezo-6f57d-default-rtdb.firebaseio.com/'
})
ref = db.reference('/')

adc = Adafruit_ADS1x15.ADS1115()
GAIN =1
#asynchronous websocket handler
async def websocket_handler(websocket, path):
    # Open serial connection to serial port
    #ser = serial.Serial('/dev/ttyUSB0', 9600)
    #ser.flush()
    

    # Read data from serial connection and send to web socket
    while True:
        if humidity is not None and temperature is not None:
            print(f'Temperature: {temperature:.2f} C')
            print(f'Humidity: {humidity:.2f} %')
   
        else:
            print("Failed")
        time.sleep(5)
        #data = ser.readline().decode('utf-8').strip()
        data = adc.read_adc(0, gain=GAIN)
        data2 = adc.read_adc(1, gain=GAIN)
        tem = str(temperature)
        hum = str(humidity)
        the_data = {
                'temperature':tem,
                'humidity':hum,
                 'air_quality':data,
                'air_quality1':data2
            
            }
        json_data = json.dumps(the_data)
        await websocket.send(json_data)
        ref.child('random_numbers').push(data) 
        rc = mqttc.loop()
        #Check switch pressed or not
        if data > 0:
                line = str(data)
                #print the received value
                print(f'{line} sent to Dashboard Successfully')
                # Construct ThingSpeak update URL with sensor data
                update_url = f'{BASE_URL}&field1={line}'
                # Send data to ThingSpeak
                response = requests.get(update_url)
    
                # Check if data was successfully sent
                if response.status_code == 200:
                    print(f'{line} sent to ThingSpeak successfully.')
                else:
                    print('Error sending data to ThingSpeak.')
    
               # Wait 15 seconds before sending the next data point
                time.sleep(5)
                
              # Connect to the database
                connection = pymysql.connect(
                    host='localhost',
                    user='chitetezo',
                    password='zuzu',
                    db='chitetezo'
                )
                
                # Create a cursor object
                cursor = connection.cursor()
                #get the current date and time
                now = datetime.datetime.now()
                
                # Execute a SQL query to insert data into the database
                sql_query = "INSERT INTO air_quality (data, date_time) VALUES (%s,%s)"
                data = (line, now)
                #cursor.execute(sql_query, data)
                
                
                
                # Insert sensor data into the database
                #sensor_id = 1
                #sensor_value = 25.4
                try:
                    cursor.execute(sql_query, data)
                    connection.commit()
                    print("Sensor data inserted into the Database successfully")
                except pymysql.Error as e:
                    print(f"Error: {e}")
                # Commit the changes to the database
                #connection.commit()
                # Close the cursor and connection objects
                cursor.close()
                connection.close()
    
                
                #converting to float
                my_data = float(line)
                #testing values
                if 0 <= my_data <= 50:
                    lcd_string("Good",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    GPIO.output(Buzzer,False)
                    GPIO.output(Led_light,False)
                    #Sending to mqtt dashboard
                    mqttc.publish("air",f"Air level Quality {line}")
                    print(f'{line} Good.')
                    
                elif 51 <= my_data <= 100:
                    lcd_string("Moderate",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    GPIO.output(Buzzer,False)
                    GPIO.output(Led_light,False)
                    #Sending to mqtt dashboard
                    mqttc.publish("air",f"Air level Quality {line}")
                    print(f'{line} Moderate.')
                    
                elif 101 <= my_data <= 200:
                    lcd_string("Unhealthy",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    GPIO.output(Buzzer,True)
                    GPIO.output(Led_light,True)
                    #Sending to mqtt dashboard
                    mqttc.publish("air",f"Air level Quality {line}")
                    print(f'{line} Unheathy.')
                    
                elif 200 <= my_data <= 300:
                    lcd_string("Very Unhealthy",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    GPIO.output(Buzzer,True)
                    GPIO.output(Led_light,True)
                    #Sending to mqtt dashboard
                    mqttc.publish("air",f"Air level Quality {line}")
                    print(f'{line} Very Unheathy.')
                    
                else:
                    lcd_string("Hazardous",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    GPIO.output(Buzzer,True)
                    GPIO.output(Led_light,True)
                    #Sending to mqtt dashboard
                    mqttc.publish("air",f"Air level Quality {line}")
                    print(f'{line} Hazardous.')
                    
           
    # Close serial connection
    ser.close()

# Start web socket server
async def main():
    async with websockets.serve(websocket_handler, '192.168.0.03', 8765):
        await asyncio.Future()

asyncio.run(main())
  

 