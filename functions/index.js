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

//TODO: 1. User Place order, firebase deploy --only functions:newOrderNotification receive Notification
exports.newOrderNotification = functions.firestore
  .document('active_orders/{orderId}')
  .onCreate(async (snapshot, context) => {
    try {
      const newOrder = snapshot.data();
      const storeId = newOrder.storeID;
      const userName = newOrder.userName; // Retrieve userName from the order document

      if (!storeId) {
        console.log('No storeID specified in the order data.');
        return null;
      }

      if (!userName) {
        console.log('No userName specified in the order data.');
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

      // Compose the notification title and body using the userName field
      const notificationTitle = `You have a new order from ${userName}!`;
      const notificationBody = `You've received a new order from ${userName} --- check it out!`;

      console.log('Sending notification to tokens:', storeTokens);

      // Loop through each token and send notifications individually
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

      // Create a notification data object
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

    // Exit early if both storeStatus and orderStatus haven't changed or are already 'Completed'
    const storeCompleted = afterData.storeStatus === 'Completed' && beforeData.storeStatus !== 'Completed';
    const orderCompleted = afterData.orderStatus === 'Completed' && beforeData.orderStatus !== 'Completed';

    if (!storeCompleted && !orderCompleted) {
      return null;
    }

    // Retrieve necessary fields with fallback values
    const subTotal = afterData.subTotal || 0;
    const serviceFee = afterData.serviceFee || 0;
    const riderFee = afterData.riderFee || 0;
    const paymentMethod = afterData.paymentMethod;

    const serviceCommission = subTotal * 0.01;
    const serviceFeeTotal = serviceCommission + serviceFee;
    const storeEarnings = subTotal - serviceCommission;

    const promises = [];

    // Write to store transaction if storeStatus is 'Completed'
    if (storeCompleted) {
      const storeTransactionData = {
        orderID: afterData.orderID,
        orderCompleted: afterData.orderDelivered,
        paymentMethod: paymentMethod,
        serviceCommission: serviceCommission,
        serviceFee: serviceFee,
        serviceFeeTotal: serviceFeeTotal,
        earnings: storeEarnings
      };

      const storeTransactionRef = admin.firestore()
        .collection('stores')
        .doc(afterData.storeID)
        .collection('transactions')
        .doc();

      promises.push(storeTransactionRef.set(storeTransactionData));
    }

    // Write to rider transaction if orderStatus is 'Completed'
    if (orderCompleted) {
      const riderTransactionData = {
        orderID: afterData.orderID,
        orderCompleted: afterData.orderDelivered,
        paymentMethod: paymentMethod,
        earnings: riderFee
      };

      const riderTransactionRef = admin.firestore()
        .collection('riders')
        .doc(afterData.riderID)
        .collection('transactions')
        .doc();

      promises.push(riderTransactionRef.set(riderTransactionData));
    }

    // Only run if any transaction is being written
    return promises.length > 0 ? Promise.all(promises) : null;
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
    if (!change.after.exists) return null;

    const beforeData = change.before.exists ? change.before.data() : {};
    const afterData = change.after.data();
    const orderId = context.params.orderId;

    if (beforeData.orderStatus === afterData.orderStatus) return null;

    const orderStatus = afterData.orderStatus;
    const riderName = afterData.riderName || 'The rider'; // fallback
    const userName = afterData.userName || 'The customer'; // fallback
    let tokensPath = '';
    let notificationTitle = '';
    let notificationBody = '';
    let notificationCollectionPath = '';

    switch (orderStatus) {
      case 'Preparing':
        tokensPath = `users/${afterData.userID}/tokens`;
        notificationTitle = 'Store Accepted Your Order';
        notificationBody = `Store is preparing your order number ${orderId.toUpperCase()}.`;
        notificationCollectionPath = `users/${afterData.userID}/notifications`;
        break;

      case 'Assigned':
        tokensPath = `stores/${afterData.storeID}/tokens`;
        notificationTitle = `Rider ${riderName} Accepted Your Order`;
        notificationBody = `Rider ${riderName} is on the way to pick up order number ${orderId.toUpperCase()}.`;
        notificationCollectionPath = `stores/${afterData.storeID}/notifications`;
        break;

      case 'Picking up':
        tokensPath = `stores/${afterData.storeID}/tokens`;
        notificationTitle = `Rider ${riderName} is On Their Way!`;
        notificationBody = `Your rider is arriving shortly to pick up order number ${orderId.toUpperCase()}.`;
        notificationCollectionPath = `stores/${afterData.storeID}/notifications`;
        break;

      case 'Picked up':
        tokensPath = `stores/${afterData.storeID}/tokens`;
        notificationTitle = `Order Placed by ${userName} is Complete!`;
        notificationBody = `Congratulations! Order number ${orderId.toUpperCase()} has been completed.`;
        notificationCollectionPath = `stores/${afterData.storeID}/notifications`;
        break;

      case 'Delivering':
        tokensPath = `users/${afterData.userID}/tokens`;
        notificationTitle = `Rider ${riderName} is On Their Way!`;
        notificationBody = `Your rider is arriving shortly with your order #${orderId.toUpperCase()}.`;
        notificationCollectionPath = `users/${afterData.userID}/notifications`;
        break;

      case 'Delivered':
        tokensPath = `stores/${afterData.storeID}/tokens`;
        notificationTitle = `Delivery Successful!`;
        notificationBody = `Congratulations! Order #${orderId.toUpperCase()} has been delivered by ${userName}.`;
        notificationCollectionPath = `stores/${afterData.storeID}/notifications`;
        break;

      case 'Cancelled':
        tokensPath = `stores/${afterData.storeID}/tokens`;
        notificationTitle = `Customer ${userName} Cancelled Order #${orderId.toUpperCase()}`;
        notificationBody = `Please review this cancellation and ensure the order is not shipped and all pending processes are halted.`;
        notificationCollectionPath = `stores/${afterData.storeID}/notifications`;
        break;

      default:
        return null;
    }

    const tokensSnapshot = await db.collection(tokensPath).get();
    const tokens = tokensSnapshot.docs
      .map(doc => doc.data().token)
      .filter(token => token && typeof token === 'string' && token.length > 0);

    if (tokens.length === 0) {
      console.log(`No tokens found at ${tokensPath}`);
      return null;
    }

    for (const token of tokens) {
      const message = {
        token,
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

exports.copyCartImage = functions.firestore
  .document('users/{userId}/cart/{storeId}/items/{itemId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();

    // Only process items needing image copy
    if (!data.needsImageCopy || !data.originalImagePath) {
      console.log('Skipping - no image copy needed');
      return null;
    }

    const bucket = admin.storage().bucket();
    const newImagePath = `users/${context.params.userId}/cart/${context.params.storeId}/items/${context.params.itemId}.jpg`;

    try {
      // 1. Copy the image
      await bucket.file(data.originalImagePath).copy(newImagePath);
      console.log('Image copied to:', newImagePath);

      // 2. Get the new download URL
      const [newUrl] = await bucket.file(newImagePath).getSignedUrl({
        action: 'read',
        expires: '03-09-2491' // Far future date
      });

      // 3. Update Firestore with the NEW paths
      await snap.ref.update({
        itemImagePath: newImagePath,  // THIS MUST BE THE NEW PATH
        itemImageURL: newUrl,        // THIS MUST BE THE NEW URL
        needsImageCopy: false
      });

      console.log('Firestore document updated with new image references');
      return true;
    } catch (error) {
      console.error('Failed to copy image:', error);

      // Fallback - keep original image but mark as processed
      await snap.ref.update({
        needsImageCopy: false,
        // Explicitly keep original paths if copy fails
        itemImagePath: data.originalImagePath,
        itemImageURL: data.itemImageURL
      });

      throw error;
    }
  });

exports.cleanupCartImages = functions.firestore
.document('users/{userId}/cart/{storeId}/items/{itemId}')
.onDelete(async (snap, context) => {
  const data = snap.data();
  if (!data.itemImagePath || !data.itemImagePath.includes('users/')) return;

  try {
    await admin.storage().bucket().file(data.itemImagePath).delete();
    console.log('Deleted copied image:', data.itemImagePath);
  } catch (error) {
    console.error('Error deleting image:', error);
  }
});

//TODO: Cart Management for Modified Carts
exports.copyCartModifyImage = functions.firestore
  .document('users/{userId}/cart_modify/{storeId}/items/{itemId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();

    // Only process items needing image copy
    if (!data.needsImageCopy || !data.originalImagePath) {
      console.log('Skipping - no image copy needed');
      return null;
    }

    const bucket = admin.storage().bucket();
    const newImagePath = `users/${context.params.userId}/cart_modify/${context.params.storeId}/items/${context.params.itemId}.jpg`;

    try {
      // 1. Copy the image
      await bucket.file(data.originalImagePath).copy(newImagePath);
      console.log('Image copied to:', newImagePath);

      // 2. Get the new download URL
      const [newUrl] = await bucket.file(newImagePath).getSignedUrl({
        action: 'read',
        expires: '03-09-2491' // Far future date
      });

      // 3. Update Firestore with the NEW paths
      await snap.ref.update({
        itemImagePath: newImagePath,  // THIS MUST BE THE NEW PATH
        itemImageURL: newUrl,        // THIS MUST BE THE NEW URL
        needsImageCopy: false
      });

      console.log('Firestore document updated with new image references');
      return true;
    } catch (error) {
      console.error('Failed to copy image:', error);

      // Fallback - keep original image but mark as processed
      await snap.ref.update({
        needsImageCopy: false,
        // Explicitly keep original paths if copy fails
        itemImagePath: data.originalImagePath,
        itemImageURL: data.itemImageURL
      });

      throw error;
    }
  });

exports.cleanupCartModifyImages = functions.firestore
  .document('users/{userId}/cart_modify/{storeId}/items/{itemId}')
  .onDelete(async (snap, context) => {
    const data = snap.data();
    if (!data.itemImagePath || !data.itemImagePath.includes('users/')) return;

    try {
        await admin.storage().bucket().file(data.itemImagePath).delete();
        console.log('Deleted copied image:', data.itemImagePath);
    } catch (error) {
        console.error('Error deleting image:', error);
    }
});