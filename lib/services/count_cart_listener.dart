import 'package:cloud_firestore/cloud_firestore.dart';

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