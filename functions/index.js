const { onRequest } = require("firebase-functions/v2/https");
const functions = require("firebase-functions"); // For Firestore trigger
const admin = require("firebase-admin");
const express = require("express");
const bodyParser = require("body-parser");

admin.initializeApp();
const db = admin.firestore();

// HTTP Function: expireCartItem
const app = express();
app.use(bodyParser.json());

/**
 * Cloud Function to expire cart items after 2 hours.
 * 1️⃣ Deletes the item from the user's cart.
 * 2️⃣ Restores the stock in the store's inventory.
 */
app.post("/expireCartItem", async (req, res) => {
  try {
    const { userID, storeID, itemID, itemQnty } = req.body;

    if (!userID || !storeID || !itemID || itemQnty === undefined) {
      return res.status(400).send({ error: "Missing required fields" });
    }

    const cartItemRef = db.collection("users").doc(userID)
                          .collection("cart").doc(storeID)
                          .collection("items").doc(itemID);

    const storeItemRef = db.collection("stores").doc(storeID)
                           .collection("items").doc(itemID);

    // Remove item from cart
    await cartItemRef.delete();

    // Restore stock to store's inventory
    await db.runTransaction(async (transaction) => {
      const storeItemDoc = await transaction.get(storeItemRef);
      if (!storeItemDoc.exists) {
        throw new Error("Store item not found");
      }
      const currentStock = storeItemDoc.data().itemStock || 0;
      transaction.update(storeItemRef, { itemStock: currentStock + itemQnty });
    });

    console.log(`✅ Cart item ${itemID} expired, stock restored`);
    return res.status(200).send({ message: "Cart item expired successfully" });
  } catch (error) {
    console.error("❌ Error expiring cart item:", error);
    return res.status(500).send({ error: "Internal Server Error" });
  }
});

// Deploy the expireCartItem Cloud Function
exports.expireCartItem = onRequest(app);

// Firestore Trigger: autoValidateUser
exports.autoValidateUser = functions.firestore
  .document("users/{userID}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Check if both emailVerified and phoneVerified are true.
    if (afterData.emailVerified === true && afterData.phoneVerified === true) {
      // Only update if the status is not already 'registered'
      if (afterData.status !== "registered") {
        try {
          await change.after.ref.update({ status: "registered" });
          console.log(`User ${context.params.userID} validated and status updated to 'registered'.`);
          return null;
        } catch (error) {
          console.error("Error updating status:", error);
          throw new Error("Failed to update status.");
        }
      }
    }
    return null;
  });

//TODO: Will push this to the server soon, if the user changes the name, all chat history will be replaced

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

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
