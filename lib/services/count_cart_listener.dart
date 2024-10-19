import 'package:cloud_firestore/cloud_firestore.dart';

// Future<int> countAllItems(String userUID) async {
//
//   // Step 1: Reference the Cart Collection
//   CollectionReference cartCollection = FirebaseFirestore.instance.collection('users').doc(userUID).collection('cart');
//   // Step 2: Get all the Store documents
//   QuerySnapshot storeSnapshot = await cartCollection.get();
//
//   int totalItemCount = 0;
//
//   // Step 3: Iterate over each Store document
//   for (QueryDocumentSnapshot storeDoc in storeSnapshot.docs) {
//     // Reference the items collection for the current store
//     CollectionReference itemsCollection = cartCollection.doc(storeDoc.id).collection('items');
//
//
//     // Step 4: Get all item documents in the current store
//     QuerySnapshot itemSnapshot = await itemsCollection.get();
//
//     //Count item documents
//     totalItemCount += itemSnapshot.docs.length;
//   }
//
//   return totalItemCount;
// }

Stream<int> countAllItems(String userUID) {
  //Reference the Cart collection
  CollectionReference cartCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(userUID)
      .collection('cart');

  //Listen to changes in the 'cart' collection
  return cartCollection.snapshots().asyncMap((storeSnapshot) async{
    int totalItemCount = 0;

    //Iterate over each store and get items count
    for (QueryDocumentSnapshot storeDoc in storeSnapshot.docs) {
      CollectionReference itemsCollection = cartCollection.doc(storeDoc.id).collection('items');
      QuerySnapshot itemSnapshot = await itemsCollection.get();
      totalItemCount += itemSnapshot.docs.length;
    }

    return totalItemCount;
  });
}