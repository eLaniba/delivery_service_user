import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/models/address.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SelectAddressScreen extends StatefulWidget {
  SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  Address? selectedAddress;

  void _selectAddress() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select an address'),
        foregroundColor: Colors.white,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseFirestore
            .collection('users')
            .doc('${sharedPreferences!.getString('uid')}')
            .collection('address')
            .snapshots(),
        builder: (context, addressSnapshot) {
          if(addressSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          } else if(addressSnapshot.hasError) {
            return Center(child: Text('Error: ${addressSnapshot.error}'),);
          } else if(addressSnapshot.hasData && addressSnapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: addressSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Address address = Address.fromJson(
                  addressSnapshot.data!.docs[index].data()!
                  as Map<String, dynamic>,
                );

                return InkWell(
                  onTap: () async {
                    Navigator.pop(context, address);
                  },
                  child: ListTile(
                    leading: Icon(
                      PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text('${address.addressEng}',),
                    trailing: Icon(PhosphorIcons.circle(PhosphorIconsStyle.regular)),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No address found'),);
          }
        },
      ),
    );
  }
}
