import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedIndex = 0;

  // Placeholder widgets for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Store', style: TextStyle(fontSize: 24))),
    Center(child: Text('Rider', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('messages'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? Icon(
              PhosphorIcons.storefront(PhosphorIconsStyle.fill),
              size: 24,
            )
                : Icon(
              PhosphorIcons.storefront(PhosphorIconsStyle.regular),
              size: 24,
            ),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? Icon(
              PhosphorIcons.personSimpleBike(PhosphorIconsStyle.fill),
              size: 24,
            )
                : Icon(
              PhosphorIcons.personSimpleBike(PhosphorIconsStyle.regular),
              size: 24,
            ),
            label: 'Rider',
          ),
        ],
      ),
    );
  }
}
