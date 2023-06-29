const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

const tokensRef = admin.database().ref("tokens");
const sensorDataRef = admin.database().ref("random_numbers");

// Function to send a notification to a single device
async function sendNotification(token, title, body) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    token: token,
    android: {
      priority: "high",
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Notification sent successfully:", response);
  } catch (error) {
    console.error("Error sending notification:", error);
  }
}

// Retrieve sensor data from the database and send notifications
exports.sendNotifications = functions.database.ref("random_numbers").onWrite((change, context) => {
  return sensorDataRef.limitToLast(1).once("value")
    .then((snapshot) => {
      const sensorData = snapshot.val();
      const currentSensorValue = Object.values(sensorData)[0];

      if (currentSensorValue > 100) {
        if (currentSensorValue > 100 && currentSensorValue <= 150) {
          // Send notifications for the first range (101 - 150)
           return tokensRef.once("value")
            .then((snapshot) => {
              snapshot.forEach((childSnapshot) => {
                const token = childSnapshot.val();
                sendNotification(
                  token,
                  "From Chitetezo Air Pollution Monitoring System",
                  `Unhealthy Air for Sensitive Groups: ${currentSensorValue}\nPlease take a further action!`
                );
              });
            })
            .catch((error) => {
              console.error("Error sending notifications:", error);
            });
        } else if (currentSensorValue > 150 && currentSensorValue <= 200) {
          return tokensRef.once("value")
            .then((snapshot) => {
              snapshot.forEach((childSnapshot) => {
                const token = childSnapshot.val();
                sendNotification(
                  token,
                  "From Chitetezo Air Pollution Monitoring System",
                  `Unhealthy Air: ${currentSensorValue}\nPlease take a further action!`
                );
              });
            })
            .catch((error) => {
              console.error("Error sending notifications:", error);
            });
        } else if (currentSensorValue > 200 && currentSensorValue <= 300) {
          // Send notifications for the third range (201 - 300)
           return tokensRef.once("value")
            .then((snapshot) => {
              snapshot.forEach((childSnapshot) => {
                const token = childSnapshot.val();
                sendNotification(
                  token,
                  "From Chitetezo Air Pollution Monitoring System",
                  `Very Unhealthy Air: ${currentSensorValue}\nPlease take a further action!`
                );
              });
            })
            .catch((error) => {
              console.error("Error sending notifications:", error);
            });
        } else {
          // Send notifications for values greater than 300
           return tokensRef.once("value")
            .then((snapshot) => {
              snapshot.forEach((childSnapshot) => {
                const token = childSnapshot.val();
                sendNotification(
                  token,
                  "From Chitetezo Air Pollution Monitoring System",
                  `Hazardous Air: ${currentSensorValue}\nPlease take a further action!`
                );
              });
            })
            .catch((error) => {
              console.error("Error sending notifications:", error);
            });
        }
      } else {
        console.log("Sensor value is less than or equal to 100, no notification sent.");
      }
    })
    .catch((error) => {
      console.error("Error retrieving sensor data:", error);
    });
});
