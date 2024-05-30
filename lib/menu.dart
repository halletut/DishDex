import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/DishEditor.dart';
import 'package:final_project/add_to_menu.dart';
import 'package:final_project/signin_login.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final dishRef = FirebaseFirestore.instance.collection('Dishes');
  String? error;

  var storageRef = FirebaseStorage.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, String> imageFiles = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: dishRef
          .where('menu', isEqualTo: true)
          .where('user', isEqualTo: auth.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(103, 29, 77, 45),
                title: Text("MENU",
                    style: GoogleFonts.mulish(
                        fontWeight: FontWeight.bold, fontSize: 25)),
                actions: [
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                          child: TextButton(
                              onPressed: () => {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    )
                                  },
                              child: const Text("Logout"))),
                      PopupMenuItem(
                          child: TextButton(
                              onPressed: () => {clear()},
                              child: const Text("Clear Menu")))
                    ],
                  ),
                ],
              ),
              body: Align(
                alignment: Alignment.bottomCenter,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AddToMenuDishGrid(),
                    ));
                  },
                  icon: const Icon(
                    Icons.add_circle,
                    color: Color.fromARGB(255, 45, 58, 42),
                    size: 40,
                  ),
                ),
              ));
        }

        var dishesDocuments = snapshot.data!.docs;

        return Column(
          children: [
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color.fromARGB(103, 29, 77, 45),
                  title: Text("MENU",
                      style: GoogleFonts.mulish(
                          fontWeight: FontWeight.bold, fontSize: 25)),
                  actions: [
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                            child: TextButton(
                                onPressed: () => {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                      )
                                    },
                                child: const Text("Logout"))),
                        PopupMenuItem(
                            child: TextButton(
                                onPressed: () => {clear()},
                                child: const Text("Clear Menu"))),
                      ],
                    ),
                  ],
                ),
                body: GridView.builder(
                  itemCount: dishesDocuments.length,
                  padding: const EdgeInsets.all(9),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  itemBuilder: (context, index) {
                    String dishId = dishesDocuments[index].id;
                    _getDishImg(dishId);
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DishEditor(dish: dishId),
                        ));
                      },
                      child: Card(
                        child: Center(
                          child: GridTile(
                            child: Column(
                              children: [
                                imageCache.containsKey(dishId)
                                    ? Hero(
                                        tag: dishId,
                                        child: Container(
                                            margin: const EdgeInsets.all(7),
                                            height: 130,
                                            width: 150,
                                            child: CachedNetworkImage(
                                              imageUrl: imageCache[dishId]!,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                              fit: BoxFit.cover,
                                            )))
                                    : const CircularProgressIndicator(),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "${dishesDocuments[index].get('dishName')}",
                                          style: GoogleFonts.mulish()),
                                    ]),
                                if (error != null)
                                  Text(
                                    "Error: $error",
                                    style: TextStyle(
                                        color: Colors.red[800], fontSize: 12),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddToMenuDishGrid(),
                ));
              },
              icon: const Icon(
                Icons.add_circle,
                color: Color.fromARGB(255, 48, 63, 44),
                size: 40,
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, String> imageCache = {};

  Future<void> _getDishImg(String id) async {
    if (imageCache.containsKey(id)) return;

    try {
      ListResult result = await storageRef.child('DishImages').listAll();
      for (Reference ref in result.items) {
        if (ref.name.startsWith(id)) {
          String imageUrl = await ref.getDownloadURL();
          imageCache[id] = imageUrl;

          if (mounted) {
            setState(() {});
          }
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
      });
    }
  }

  Future<void> clear() async {
    try {
      CollectionReference dishRef =
          FirebaseFirestore.instance.collection('Dishes');
      QuerySnapshot querySnapshot = await dishRef.get();
      // ignore: avoid_function_literals_in_foreach_calls
      querySnapshot.docs.forEach((doc) async {
        await dishRef.doc(doc.id).update({'menu': false});
      });
    } catch (e) {
      setState(() {
        error = e as String?;
      });
    }
  }
}
