const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const express = require("express");
const bodyParser = require("body-parser");

admin.initializeApp();
const db = admin.firestore();

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

// Deployable Firebase Cloud Function
exports.expireCartItem = onRequest(app);
