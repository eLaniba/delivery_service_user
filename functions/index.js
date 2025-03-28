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
exports.newOrderNotification = functions.firestore
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
        .filter(token => token && typeof token === 'string' && token.length > 0);

      if (storeTokens.length === 0) {
        console.log(`No tokens found for store: ${storeId}`);
        return null;
      }

      // Set notification title and body
      const notificationTitle = 'New Order Received';
      const notificationBody = `Order #${context.params.orderId} was placed.`;

      console.log('Sending notification to tokens:', storeTokens);

      // Loop through each token and send individually
      for (const token of storeTokens) {
        try {
          const message = {
            token: token,
            notification: {
              title: notificationTitle,
              body: notificationBody,
            },
          };

          const response = await admin.messaging().send(message);
          console.log(`✅ Notification sent to device with token: ${token}`);
        } catch (error) {
          console.error(`❌ Failed to send notification to token: ${token}`, error.message);
        }
      }

      // Create notification data object
      const notificationData = {
        orderID: context.params.orderId,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        title: notificationTitle,
        body: notificationBody,
        type: 'order',
        read: false,
      };

      // Write the notification document to 'stores/{storeID}/notifications'
      await db
        .collection('stores')
        .doc(storeId)
        .collection('notifications')
        .add(notificationData);

      return null;
    } catch (error) {
      console.error('❌ Error in onOrderCreated function:', error.message, error.stack);
      throw new functions.https.HttpsError('unknown', 'Failed to send notification', error);
    }
  });

  //TODO: Transactions for Completed Orders
exports.completeTransaction = functions.firestore
  .document('active_orders/{orderID}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Proceed only if orderStatus changed to 'Completed'
    if (afterData.orderStatus !== 'Completed' || beforeData.orderStatus === 'Completed') {
      return null;
    }

    // Retrieve necessary fields with fallback values
    const subTotal = afterData.subTotal || 0;
    const serviceFee = afterData.serviceFee || 0;
    const riderFee = afterData.riderFee || 0;
    const paymentMethod = afterData.paymentMethod;

    // Step 1: Calculate payment details
    const serviceCommission = subTotal * 0.01;
    const serviceFeeTotal = serviceCommission + serviceFee;
    const storeEarnings = subTotal - serviceCommission;

    // Step 2: Prepare store transaction document data with unified "earnings" field
    let storeTransactionData = {
      orderID: afterData.orderID,
      orderCompleted: afterData.orderDelivered,
      paymentMethod: paymentMethod,
      serviceCommission: serviceCommission,
      serviceFee: serviceFee,
      serviceFeeTotal: serviceFeeTotal,
      earnings: storeEarnings
    };

    // Step 3: Prepare rider transaction document data with unified "earnings" field
    let riderTransactionData = {
      orderID: afterData.orderID,
      orderCompleted: afterData.orderDelivered,
      paymentMethod: paymentMethod,
      earnings: riderFee
    };

    // Write the transaction document to the store's subcollection
    const storeTransactionRef = admin.firestore()
      .collection('stores')
      .doc(afterData.storeID)
      .collection('transactions')
      .doc();

    // Write the transaction document to the rider's subcollection
    const riderTransactionRef = admin.firestore()
      .collection('riders')
      .doc(afterData.riderID)
      .collection('transactions')
      .doc();

    // Execute both writes concurrently
    const promises = [
      storeTransactionRef.set(storeTransactionData),
      riderTransactionRef.set(riderTransactionData)
    ];

    return Promise.all(promises);
  });

exports.restockCancelledOrder = functions.firestore
  .document('active_orders/{orderID}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Only trigger if the orderStatus changed to 'cancelled'
    if (beforeData.orderStatus !== 'Cancelled' && afterData.orderStatus === 'Cancelled') {
      const storeID = afterData.storeID;
      if (!storeID) {
        console.error('storeID is missing in the cancelled order document.');
        return null;
      }

      const items = afterData.items;
      if (!items || !Array.isArray(items)) {
        console.error('Items list is missing or not an array.');
        return null;
      }

      // Process each item from the order
      const updatePromises = items.map(item => {
        // Validate that itemID and itemQnty are present
        if (!item.itemID || typeof item.itemQnty !== 'number') {
          console.error('Missing itemID or itemQnty for item:', item);
          return Promise.resolve();
        }

        // Reference the corresponding store's item document
        const itemRef = admin.firestore().doc(`stores/${storeID}/items/${item.itemID}`);

        // Increment the store's item quantity by the cancelled order's itemQnty
        return itemRef.update({
          itemStock: admin.firestore.FieldValue.increment(item.itemQnty)
        });
      });

      // Wait for all updates to complete
      return Promise.all(updatePromises);
    }

    // If orderStatus wasn't changed to 'cancelled', do nothing.
    return null;
  });

  //TODO: New Message Notification
exports.newChatNotification = functions.firestore
  .document('chats/{chatId}')
  .onWrite(async (change, context) => {
    // Exit if the document was deleted.
    if (!change.after.exists) {
      console.log('Chat document was deleted.');
      return null;
    }

    const chatData = change.after.data();

    // Extract lastSender from the chat document.
    const lastSender = chatData.lastSender;
    if (!lastSender) {
      console.log('No lastSender found in chat document.');
      return null;
    }

    // Determine the receiverID by getting the participant that is not the lastSender.
    const participants = chatData.participants;
    if (!participants || !Array.isArray(participants)) {
      console.log('Participants array is missing.');
      return null;
    }
    const receiverID = participants.find(id => id !== lastSender);
    if (!receiverID) {
      console.log('Receiver ID could not be determined.');
      return null;
    }

    // Get the receiver's role from the roles field.
    const roles = chatData.roles;
    if (!roles || !roles[receiverID]) {
      console.log('Receiver role not found.');
      return null;
    }
    const receiverRole = roles[receiverID]; // e.g., 'user' or 'store'

    // Build the path to the tokens collection based on receiverRole.
    // This follows the format: `${receiverRole}s/${receiverID}/tokens`
    const tokensCollectionPath = `${receiverRole}s/${receiverID}/tokens`;

    // Retrieve tokens for the receiver.
    const tokensSnapshot = await admin.firestore().collection(tokensCollectionPath).get();
    if (tokensSnapshot.empty) {
      console.log(`No tokens found for receiver: ${receiverID}`);
      return null;
    }
    const tokens = tokensSnapshot.docs
      .map(doc => doc.data().token)
      .filter(token => token && typeof token === 'string' && token.length > 0);

    if (tokens.length === 0) {
      console.log(`No valid tokens found for receiver: ${receiverID}`);
      return null;
    }

    console.log('Sending notification to tokens:', tokens);

    // Prepare the notification message payload.
    const messagePayload = {
      notification: {
        title: 'New Message Received',
        body: 'You have a new message.',
      },
    };

    // Send a notification to each token.
    const sendPromises = tokens.map(token => {
      const message = { ...messagePayload, token };
      return admin.messaging().send(message)
        .then(response => {
          console.log(`✅ Notification sent to token ${token}: ${response}`);
        })
        .catch(error => {
          console.error(`❌ Failed to send notification to token ${token}:`, error.message);
        });
    });

    return Promise.all(sendPromises);
  });

//TODO: Order Notification
exports.orderNotification = functions.firestore
  .document('active_orders/{orderId}')
  .onUpdate(async (change, context) => {
    // Exit if the document was deleted.
    if (!change.after.exists) {
      return null;
    }

    // Get the data before and after the change.
    const beforeData = change.before.exists ? change.before.data() : {};
    const afterData = change.after.data();
    const orderId = context.params.orderId;

    // Only proceed if the orderStatus has changed.
    if (beforeData.orderStatus === afterData.orderStatus) {
      return null;
    }

    const orderStatus = afterData.orderStatus;
    let tokensPath = '';
    let notificationTitle = '';
    let notificationBody = '';
    let notificationCollectionPath = '';

    // Build the notification based on orderStatus.
    switch (orderStatus) {
//      case 'Pending':
//        tokensPath = `stores/${afterData.storeID}/tokens`;
//        notificationTitle = 'New Order Received';
//        notificationBody = `Order #${orderId.toUpperCase()} was placed.`;
//        notificationCollectionPath = `stores/${afterData.storeID}/notifications`;
//        break;
      case 'Preparing':
        tokensPath = `users/${afterData.userID}/tokens`;
        notificationTitle = 'Store Accepted Your Order';
        notificationBody = `Store is preparing your order #${orderId.toUpperCase()}.`;
        notificationCollectionPath = `users/${afterData.userID}/notifications`;
        break;
      case 'Assigned':
        tokensPath = `stores/${afterData.storeID}/tokens`;
        notificationTitle = 'Rider Accepted Your Order';
        notificationBody = `Rider en route to pick up order #${orderId.toUpperCase()}.`;
        notificationCollectionPath = `stores/${afterData.storeID}/notifications`;
        break;
      case 'Delivering':
        tokensPath = `users/${afterData.userID}/tokens`;
        notificationTitle = 'Your Delivery is On Its Way!';
        notificationBody = `Your rider is arriving shortly with your order #${orderId.toUpperCase()}.`;
        notificationCollectionPath = `users/${afterData.userID}/notifications`;
        break;
      case 'Delivered':
        tokensPath = `stores/${afterData.storeID}/tokens`;
        notificationTitle = 'Order Delivered Successfully!';
        notificationBody = `Order #${orderId.toUpperCase()} has been successfully delivered by the rider.`;
        notificationCollectionPath = `stores/${afterData.storeID}/notifications`;
        break;
      default:
        // If the orderStatus doesn't match any of the above, do nothing.
        return null;
    }

    // Fetch tokens from the designated tokens collection.
    const tokensSnapshot = await db.collection(tokensPath).get();
    const tokens = tokensSnapshot.docs
      .map(doc => doc.data().token)
      .filter(token => token && typeof token === 'string' && token.length > 0);

    if (tokens.length === 0) {
      console.log(`No tokens found at ${tokensPath}`);
      return null;
    }

    // Send the notification to each token.
    for (const token of tokens) {
      const message = {
        token: token,
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
      };

      try {
        await admin.messaging().send(message);
        console.log(`Notification sent to token: ${token}`);
      } catch (error) {
        console.error(`Error sending notification to token ${token}:`, error.message);
      }
    }

      const notificationRef = db.collection(notificationCollectionPath).doc();
        const notificationData = {
          notificationID: notificationRef.id,
          orderID: orderId,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          title: notificationTitle,
          body: notificationBody,
          type: 'order',
          read: false,
        };

        await notificationRef.set(notificationData);
    return null;
  });
