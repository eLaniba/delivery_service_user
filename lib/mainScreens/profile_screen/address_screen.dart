import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/profile_screen/add_new_address_screen.dart';
import 'package:delivery_service_user/models/address.dart';
import 'package:delivery_service_user/services/geopoint_json.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/show_floating_toast.dart';
import 'package:delivery_service_user/widgets/show_map_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Future<void> _deleteAddress(String addressId) async {
    bool? isConfirm = await ConfirmationDialog.show(context, 'Are you sure you want to delete this address?');

    if(isConfirm == true) {
      showFloatingToast(context: context, message: 'Deleting address...', duration: const Duration(seconds: 25));
      try {
        await firebaseFirestore
            .collection('users')
            .doc(sharedPreferences!.getString('uid'))
            .collection('address')
            .doc(addressId)
            .delete();
        showFloatingToast(context: context, message: 'Address deleted successfully', backgroundColor: Colors.green);
      } catch (e) {
        showFloatingToast(context: context, message: 'Failed to delete address: $e');
      }
    }


  }

  void _showAddressOnMap(Address address) {
    showDialog(
      context: context,
      builder: (context) => ShowMapDialog(address: address),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: StreamBuilder<QuerySnapshot>(
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
                itemCount: addressSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Address address = Address.fromJson(
                    addressSnapshot.data!.docs[index].data()!
                        as Map<String, dynamic>,
                  );

                  return Column(
                    children: [
                      Slidable(
                        key: ValueKey(address.addressID),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => _deleteAddress(address.addressID!),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                            color: Theme.of(context).primaryColor,
                          ),
                          title: Text('${address.addressEng}'),
                          trailing: Icon(
                              PhosphorIcons.caretRight(PhosphorIconsStyle.regular)),
                          onTap: () => _showAddressOnMap(address),
                        ),
                      ),
                      const Divider(
                        color: gray5,
                      ),
                    ],
                  );

                },
              );
            } else {
              return const Center(child: Text('No address found'),);
            }
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).primaryColor,
          ),
          height: 60,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => AddNewAddressScreen(),),);
            },
            child: const Text(
              'Add New Address',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
