import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/DishEditor.dart';
import 'package:final_project/dishDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class DishGrid extends StatefulWidget {
  const DishGrid({super.key});

  @override
  State<DishGrid> createState() => _DishGridState();
}

class _DishGridState extends State<DishGrid> {
  final dishRef = FirebaseFirestore.instance.collection('Dishes');
  var storageRef = FirebaseStorage.instance.ref();
  String? error;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Map<String, String> imageFiles = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          dishRef.where('user', isEqualTo: auth.currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(103, 29, 77, 45),
              title: Text("DISHES",
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold, fontSize: 25)),
              actions: [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: TextButton(
                          onPressed: () => {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const DishDetail(),
                                ))
                              },
                          child: const Text("Create Dish")),
                    ),
                  ],
                )
              ],
            ),
            body: Container(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(103, 29, 77, 45),
              title: Text("DISHES",
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold, fontSize: 25)),
              actions: [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: TextButton(
                          onPressed: () => {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const DishDetail(),
                                ))
                              },
                          child: const Text("Create Dish")),
                    ),
                  ],
                )
              ],
            ),
            body: const Center(
              child: Text("You don't have any saved dishes!"),
            ),
          );
        }
        var dishesDocuments = snapshot.data!.docs;
        return Expanded(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(103, 29, 77, 45),
              title: Text("DISHES",
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold, fontSize: 25)),
              actions: [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: TextButton(
                          onPressed: () => {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const DishDetail(),
                                )),
                              },
                          child: const Text("Create Dish")),
                    )
                  ],
                )
              ],
            ),
            body: GridView.builder(
              itemCount: dishesDocuments.length,
              padding: const EdgeInsets.all(9),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
              itemBuilder: (context, index) {
                String dishId = dishesDocuments[index].id;
                _getDishImg(dishId);
                return DishCard(
                  dishDocument: dishesDocuments[index],
                  onTap: () {},
                  imageCache: imageCache,
                );
              },
            ),
          ),
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
}

class DishCard extends StatefulWidget {
  final DocumentSnapshot dishDocument;
  final Function onTap;
  final Map<String, String> imageCache;

  const DishCard({
    super.key,
    required this.dishDocument,
    required this.onTap,
    required this.imageCache,
  });

  @override
  State<DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<DishCard> {
  String? error;
  @override
  Widget build(BuildContext context) {
    String dishId = widget.dishDocument.id;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DishEditor(dish: dishId),
        ));
        widget.onTap();
      },
      child: Card(
        child: Center(
          child: GridTile(
            child: Column(
              children: [
                widget.imageCache.containsKey(dishId)
                    ? Hero(
                        tag: dishId,
                        child: Container(
                          margin: const EdgeInsets.all(7),
                          height: 130,
                          width: 150,
                          child: CachedNetworkImage(
                            imageUrl: widget.imageCache[dishId]!,
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${widget.dishDocument.get('dishName')}",
                      style: GoogleFonts.mulish(),
                    ),
                  ],
                ),
                if (error != null)
                  Text(
                    "Error: $error",
                    style: TextStyle(color: Colors.red[800], fontSize: 12),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
