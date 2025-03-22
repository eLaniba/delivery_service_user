const functions = require("firebase-functions"); // For Firestore trigger
const admin = require("firebase-admin");
const express = require("express");
const bodyParser = require("body-parser");

admin.initializeApp();
const db = admin.firestore();

//TODO: Will push this to the server soon, if the user changes the name, all chat history will be replaced

exports.onUserNameChanged = functions.firestore
  .document('users/{userId}')
  .onUpdate((change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const userId = context.params.userId;

    // Check if the display name has actually changed.
    if (beforeData.displayName === afterData.displayName) {
      return null;
    }

    const newDisplayName = afterData.displayName;

    // Query chats where this user is a participant.
    const chatsRef = admin.firestore().collection('chats');
    return chatsRef.where('participants', 'array-contains', userId).get().then(snapshot => {
      const batch = admin.firestore().batch();
      snapshot.forEach(doc => {
        const data = doc.data();
        // Update the participantNames map for this user.
        const participantNames = data.participantNames || {};
        participantNames[userId] = newDisplayName;
        batch.update(doc.ref, { participantNames: participantNames });
      });
      return batch.commit();
    });
  });

//TODO: 1. User Place order, firebase deploy --only functions:onOrderCreatedStore receive Notification
/**
 * Triggered whenever a new order document is created in "active_orders/{orderId}".
 * This function retrieves the 'storeId' from the order, then fetches the store's FCM tokens
 * in "stores/{storeId}/tokens", and sends a push notification.
 */
exports.onOrderCreated = functions.firestore
  .document('active_orders/{orderId}')
  .onCreate(async (snapshot, context) => {
    try {
      const newOrder = snapshot.data();
      const storeId = newOrder.storeID;

      if (!storeId) {
        console.log('No storeID specified in the order data.');
        return null;
      }

      const tokensSnapshot = await db
        .collection('stores')
        .doc(storeId)
        .collection('tokens')
        .get();

      const storeTokens = tokensSnapshot.docs
        .map(doc => doc.data().token)
        .filter(token => token && typeof token === 'string' && token.length > 0); // Validate tokens

      if (storeTokens.length === 0) {
        console.log(`No tokens found for store: ${storeId}`);
        return null;
      }

      console.log('Sending notification to tokens:', storeTokens);

      // Loop through each token and send individually
      for (const token of storeTokens) {
        try {
          const message = {
            token: token,
            notification: {
              title: 'New Order Received',
              body: `Order #${context.params.orderId} was placed.`,
            },
          };

          const response = await admin.messaging().send(message);
          console.log(`✅ Notification sent to device with token: ${token}`);
        } catch (error) {
          console.error(`❌ Failed to send notification to token: ${token}`, error.message);
        }
      }

    } catch (error) {
      console.error('❌ Error in onOrderCreated function:', error.message, error.stack);
      throw new functions.https.HttpsError('unknown', 'Failed to send notification', error);
    }
  });