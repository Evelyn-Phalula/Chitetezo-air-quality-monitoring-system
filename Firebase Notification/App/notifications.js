const admin = require('firebase-admin');
const serviceAccount = require('C:/Users/MAXON MACHEDA MR 200/Documents/chitetezo-6f57d-firebase-adminsdk-1r0do-3e71357924.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://chitetezo-6f57d-default-rtdb.firebaseio.com',
});

const tokensRef = admin.database().ref('tokens');
const sensorDataRef = admin.database().ref('random_numbers');

// Function to send a notification to a single device
async function sendNotification(token, title, body) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    token: token,
    android: {
      priority: 'high',
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('Notification sent successfully:', response);
  } catch (error) {
    console.error('Error sending notification:', error);
  }
}

// Retrieve sensor data from the database and send notifications
sensorDataRef.once('value')
  .then((snapshot) => {
    const sensorData = snapshot.val();
    if (sensorData) {
      const values = Object.values(sensorData);

      if (values.length > 0) {
        const greatestValue = Math.max(...values);

        return tokensRef.once('value')
          .then((snapshot) => {
            snapshot.forEach((childSnapshot) => {
              const token = childSnapshot.val();
              sendNotification(
                token,
                'Chitetezo Air Pollution Monitoring System',
                `Greatest Sensor Data Value: ${greatestValue}`
              );
            });
          });
      } else {
        throw new Error('No sensor data values found');
      }
    } else {
      throw new Error('Sensor data not found');
    }
  })
  .catch((error) => {
    console.error('Error retrieving sensor data:', error);
  });