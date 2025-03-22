import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_user/authentication/auth_screen_remake.dart';
import 'package:delivery_service_user/global/global.dart';
import 'package:delivery_service_user/mainScreens/profile_screen/address_screen.dart';
import 'package:delivery_service_user/mainScreens/profile_screen/edit_profile_screen.dart';
import 'package:delivery_service_user/models/users.dart';
import 'package:delivery_service_user/services/auth_service.dart';
import 'package:delivery_service_user/widgets/confirmation_dialog.dart';
import 'package:delivery_service_user/widgets/circle_image_avatar.dart';
import 'package:delivery_service_user/widgets/loading_dialog.dart';
import 'package:delivery_service_user/widgets/status_widget.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  void logout() async {
    await firebaseAuth.signOut();
    // await sharedPreferences!.clear();
    await _authService.setLoginState(false);
    await sharedPreferences!.clear();

    // Navigate to the Auth Screen if the logout was successful
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreenRemake()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // First Container with round corners and white background
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Pressable Avatar, Name (bold), and Number (grey)
                  StreamBuilder<DocumentSnapshot>(
                    stream: firebaseFirestore
                        .collection('users')
                        .doc(sharedPreferences!.getString('uid'))
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      Users user = Users.fromJson(snapshot.data!.data() as Map<String, dynamic>);
                      return Column(
                        children: [
                          CircleImageAvatar(
                            imageUrl: user.userProfileURL,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.userName ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.userPhone ?? '',
                                style: const TextStyle(color: gray),
                              ),
                              const SizedBox(width: 4),
                              verifiedStatusWidget(user.phoneVerified ?? false),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: Colors.black.withOpacity(0.05),
                    indent: 32,
                    endIndent: 32,
                    height: 18,
                  ),
                  // Pressable ListTile with Edit Icon, Title and Arrow
                  ListTile(
                    leading: PhosphorIcon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill), color: Theme.of(context).primaryColor,),
                    title: const Text('Edit Profile'),
                    trailing: PhosphorIcon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular),),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    },
                  ),
                  // Divider with 20% opacity
                  // Divider(
                  //   color: Colors.black.withOpacity(0.05),
                  //   indent: 32,
                  //   height: 0,
                  // ),
                  // Pressable ListTile with Heart Icon, Title and Arrow
                  //TODO: Enable Favorites after Final defense
                  // ListTile(
                  //   leading: PhosphorIcon(PhosphorIcons.heart(PhosphorIconsStyle.fill), color: Theme.of(context).primaryColor,),
                  //   title: const Text('Favorites'),
                  //   trailing: PhosphorIcon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular),),
                  //   onTap: () {
                  //     // Handle favorites tap
                  //   },
                  // ),
                ],
              ),
            ),
            // Second Container with round corners
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  // Address ListTile
                  ListTile(
                    leading: PhosphorIcon(PhosphorIcons.mapPin(PhosphorIconsStyle.fill), color: Theme.of(context).primaryColor,),
                    title: const Text('Address'),
                    trailing: PhosphorIcon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular),),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddressScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(
                    color: Colors.black.withOpacity(0.05),
                    indent: 32,
                    height: 0,
                  ),
        
                  // Logout ListTile with text colored by the primary color from the context
                  ListTile(
                    leading: PhosphorIcon(PhosphorIcons.signOut(PhosphorIconsStyle.fill), color: Theme.of(context).primaryColor,),
                    title: Text('Logout', style: TextStyle(color: Theme.of(context).primaryColor),),
                    trailing: PhosphorIcon(PhosphorIcons.caretRight(PhosphorIconsStyle.regular), color: Theme.of(context).primaryColor,),
                    onTap: () async {
                      final bool? isLogout = await ConfirmationDialog.show(context, 'Are you sure you want to logout?');

                      if(isLogout == true) {
                        logout();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
