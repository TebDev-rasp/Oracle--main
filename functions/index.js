/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.monitorHeatIndex = functions.database
  .ref('/sensor_data/smooth/heat_index/celsius')
  .onWrite(async (change, context) => {
    const heatIndex = change.after.val();
    
    if (!heatIndex) return null;

    const message = {
      data: {
        heat_index: heatIndex.toString(),
      },
      topic: 'heat_index_updates',
    };

    try {
      await admin.messaging().send(message);
      console.log('Heat index notification sent:', heatIndex);
    } catch (error) {
      console.error('Error sending message:', error);
    }
  });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
