import 'package:final_project/groceryList.dart';
import 'package:final_project/menu.dart';
import 'package:final_project/signin_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dishCollection_add.dart';
import 'firebase_options.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MaterialApp(title: "Menu Application", home: LoginScreen()));
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const MenuScreen(),
    const DishGrid(),
    const GroceryList()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_sharp), label: "Menu"),
            BottomNavigationBarItem(
                icon: Icon(Icons.fastfood_sharp), label: "Dishes"),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_grocery_store_sharp),
                label: "Grocery List")
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(255, 9, 5, 71),
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
            });
          }),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: const Text("This app was created by Halle Tuttle"),
    );
  }
}
