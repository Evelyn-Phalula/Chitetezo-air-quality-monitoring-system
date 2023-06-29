#importing all necessary libraries for the project
import RPi.GPIO as GPIO     
from urllib.parse import urlparse 
import paho.mqtt.client as paho 
import os,sys #import 
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
import drivers
from time import sleep

GPIO.setmode(GPIO.BOARD)    #set the GPIO numbering mode to GPIO.BOARD
GPIO.setwarnings(False)     #disable GPIO pin warning
display = drivers.Lcd()     #create an instance of the LCD class from the drivers module


yellow_led = 7 # Define PIN for yellow led light
green_led  = 11 # Define PIN for green led light
LCD_D4 = 12 # Define PIN for lcd
LCD_D5 = 13 # Define PIN for lcd
LCD_D6 = 15 # Define PIN for lcd
LCD_D7 = 16 # Define PIN for lcd
Buzzer = 29     # Define PIN for Buzzer
MQ2_Pin = 18    # Define PIN for MQ2 Sensor
Led_light = 31 # Define PIN for red led light

#setting up GPIO pins as input pins or output pins
GPIO.setup(Buzzer,GPIO.OUT)   # Set pin function as output
GPIO.setup(MQ2_Pin,GPIO.IN,pull_up_down=GPIO.PUD_UP)   # Set pin function as input
GPIO.setup(green_led, GPIO.OUT)  # E Set pin function as output
GPIO.setup(yellow_led, GPIO.OUT) # RS Set pin function as output
GPIO.setup(LCD_D4, GPIO.OUT) # DB4 Set pin function as output
GPIO.setup(LCD_D5, GPIO.OUT) # DB5 Set pin function as output
GPIO.setup(LCD_D6, GPIO.OUT) # DB6 Set pin function as output
GPIO.setup(LCD_D7, GPIO.OUT) # DB7 Set pin function as output
GPIO.setup(Led_light, GPIO.OUT) #Set pin function as output

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
Function Description:basically this is used to toggle Enable pin
'''
def lcd_toggle_enable():
  # Toggle enable
  time.sleep(E_DELAY)
  #GPIO.output(LCD_E, True)
  time.sleep(E_PULSE)
  #GPIO.output(LCD_E, False)
  time.sleep(E_DELAY)
'''
Function Name :lcd_string(message,line)
Function  Description :print the data on lcd 
'''
def lcd_string(message,line):
  # Send string to display
 
  message = message.ljust(LCD_WIDTH," ")
 
  lcd_byte(line, LCD_CMD)
 
  for i in range(LCD_WIDTH):
    lcd_byte(ord(message[i]),LCD_CHR)
#initializing the lcd
lcd_init()
display.lcd_display_string("Welcome Everyone",1)
display.lcd_display_string("This is GRoup 12 ",2)
sleep(5)
display.lcd_display_string("Chitetezo Air Pollution",1)
display.lcd_display_string("Monitoring System ",2)
sleep(5)
display.lcd_clear() # 000001 Clear display

#printing on the LCD when the code started running
display.lcd_display_string("Connecting....", 1)  # Write line of text to first line of display
display.lcd_display_string("BREATHE EASY", 2)  # Write line of text to second line of display
sleep(5)                                           # Give time for the message to be read
display.lcd_display_string("Takes 3 mins", 1)   # Refresh the first line of display with a different message
sleep(5)                                           # Give time for the message to be read
display.lcd_clear()                                # Clear the display of any data
sleep(2)

#Temperature and Humidity
sensor = Adafruit_DHT.DHT22
#DHT22 to Raspnerry conection
pin = 21

# Initialize Firebase with your credentials
cred = credentials.Certificate('/home/ZuzuTech/Desktop/CHITETEZO-AIR-POLLUTION-MONITORING-SYSTEM/chitetezo-6f57d-firebase-adminsdk-1r0do-8b8b8a8f29.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://chitetezo-6f57d-default-rtdb.firebaseio.com/'
})
#refrence to the realtime database in the firebase
ref = db.reference('/')

#declaring adc variable
adc = Adafruit_ADS1x15.ADS1115()
GAIN =1

#websocket function containg everything concerning results
async def websocket_handler(websocket, path):
   
    while True:
        #getting humidity and temperature sensor
        humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)
          
        #testing the humidity and temperature  
        if humidity is not None and temperature is not None:
            print(f'Temperature: {temperature:.2f} C')
            print(f'Humidity: {humidity:.2f} %')
   
        else:
            print("Failed")
        time.sleep(5)
        
        #receiving data from ADC(ADS1115)
        data = adc.read_adc(0, gain=GAIN)
        #data2 = adc.read_adc(1, gain=GAIN)
        
        #casting values of temperature and humidity into string
        tem = str(temperature)
        hum = str(humidity)
        #declaring jsonfile that collect multiple data
        the_data = {
                'temperature':tem,
                'humidity':hum,
                 'air_quality':data,
                'air_quality_sensor':data
            
            }
        json_data = json.dumps(the_data)
        #seding temp,humid and sensor data to dashboard
        await websocket.send(json_data)
        #sending sensor data to firebase
        ref.child('random_numbers').push(data) 
        
        #Check id sensor data is greater that zerothen execute
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
                
                # Insert sensor data into the database
                try:
                    cursor.execute(sql_query, data)
                    connection.commit()
                    print("Sensor data inserted into the Database successfully")
                except pymysql.Error as e:
                    print(f"Error: {e}")
                 #closing cursor and connection   
                cursor.close()
                connection.close()
    
                
                #converting to float
                my_data = float(line)
                #testing values
                #if greater than zero and less than or equal 50 do the this
                if 0 <= my_data <= 50:
                    lcd_string("Good",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    display.lcd_display_string("Good Air", 1)  # Write line of text to first line of display
                    display.lcd_display_string(line, 2)
                    sleep(10)
                    display.lcd_clear()
                    GPIO.output(Buzzer,False)
                    GPIO.output(Led_light,False)
                    GPIO.output(yellow_led,False) 
                    GPIO.output(green_led,True)
                    print(f'{line} Good.')
                
                #if greater than 50 and less than or equal 100 do the this   
                elif 51 <= my_data <= 100:
                    lcd_string("Moderate",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    display.lcd_display_string("Moderate Air", 1)  # Write line of text to first line of display
                    display.lcd_display_string(line, 2)
                    sleep(10)
                    display.lcd_clear()
                    GPIO.output(green_led,False)
                    GPIO.output(Led_light,False) 
                    GPIO.output(Buzzer,False)
                    GPIO.output(yellow_led,True)
                    print(f'{line} Moderate.')
                 
                #if greater than 100 and less than or equal 200 do the this 
                elif 101 <= my_data <= 200:
                    lcd_string("Unhealthy",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    display.lcd_display_string("Unheathly Air", 1)  # Write line of text to first line of display
                    display.lcd_display_string(line, 2)
                    sleep(10)
                    display.lcd_clear()
                    GPIO.output(green_led,False)
                    GPIO.output(yellow_led,False)
                    GPIO.output(Buzzer,True)
                    GPIO.output(Led_light,True)
                    print(f'{line} Unheathy.')
               
               #if greater than 200 and less than or equal 300 do the this
                elif 201 <= my_data <= 300:
                    lcd_string("Very Unhealthy",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    display.lcd_display_string("Very Unheathyl Air", 1)  # Write line of text to first line of display
                    display.lcd_display_string(line, 2)
                    sleep(10)
                    display.lcd_clear() 
                    GPIO.output(yellow_led,False)
                    GPIO.output(green_led,False)
                    GPIO.output(Buzzer,True)
                    GPIO.output(Led_light,True)
                    print(f'{line} Very Unheathy.')
                  #if greater than 300 do the this  
                else:
                    lcd_string("Hazardous",LCD_LINE_1)
                    lcd_string(line,LCD_LINE_2)
                    display.lcd_display_string("Hazardous Air", 1)  # Write line of text to first line of display
                    display.lcd_display_string(line, 2)
                    sleep(10)
                    display.lcd_clear() 
                    GPIO.output(yellow_led,False)
                    GPIO.output(green_led,False)
                    GPIO.output(Buzzer,True)
                    GPIO.output(Led_light,True)
                    print(f'{line} Hazardous.')
                    
           
    # Close serial connection
    ser.close()

#Start web socket server
#define an asynchronous function called main() and then call asyncio.run() to run the main() function
async def main():
    async with websockets.serve(websocket_handler, '192.168.0.05', 8765):
        await asyncio.Future()

asyncio.run(main())
  

 