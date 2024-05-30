import 'package:cached_network_image/cached_network_image.dart';
import 'package:final_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AddToMenuDishGrid extends StatefulWidget {
  const AddToMenuDishGrid({super.key});

  @override
  State<AddToMenuDishGrid> createState() => _AddToMenuDishGridState();
}

class _AddToMenuDishGridState extends State<AddToMenuDishGrid> {
  final dishRef = FirebaseFirestore.instance.collection('Dishes');
  var storageRef = FirebaseStorage.instance.ref();
  String? error;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Map<String, String> imageFiles = {};
  List<String> tappedDishIds = [];
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('Dishes')
        .where('user', isEqualTo: auth.currentUser!.uid)
        .where('menu', isEqualTo: true)
        .get()
        .then((QuerySnapshot snapshot) {
      setState(() {
        tappedDishIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          dishRef.where('user', isEqualTo: auth.currentUser!.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text("ADD TO MENU",
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold, fontSize: 25)),
            ),
            body: Container(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text("ADD TO MENU",
                  style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold, fontSize: 25)),
            ),
            body: const Center(
              child: Text("You don't have any saved dishes!"),
            ),
          );
        }
        var dishesDocuments = snapshot.data!.docs;

        return Column(
          children: [
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text("ADD TO MENU",
                      style: GoogleFonts.mulish(
                          fontWeight: FontWeight.bold, fontSize: 25)),
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
                    return DishCard(
                      dishDocument: dishesDocuments[index],
                      onTap: () {},
                      imageCache: imageCache,
                      tappedDishIds: tappedDishIds,
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  for (var doc in snapshot.data!.docs) {
                    String dishId = doc.id;
                    if (!tappedDishIds.contains(dishId)) {
                      dishRef.doc(dishId).update({'menu': false});
                    }
                  }
                  for (var dishId in tappedDishIds) {
                    dishRef.doc(dishId).update({'menu': true});
                  }
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ));
                  setState(() {});
                },
                icon: const Icon(
                  Icons.check_box_sharp,
                  color: Color.fromARGB(255, 205, 235, 196),
                  size: 40,
                ),
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
}

class DishCard extends StatefulWidget {
  final DocumentSnapshot dishDocument;
  final Function onTap;
  final Map<String, String> imageCache;
  final List<String> tappedDishIds;

  const DishCard({
    super.key,
    required this.dishDocument,
    required this.onTap,
    required this.imageCache,
    required this.tappedDishIds,
  });

  @override
  State<DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<DishCard> {
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    String dishId = widget.dishDocument.id;
    _isTapped = widget.tappedDishIds.contains(dishId);
  }

  @override
  Widget build(BuildContext context) {
    String dishId = widget.dishDocument.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTapped = !_isTapped;
          String dishId = widget.dishDocument.id;
          if (_isTapped) {
            widget.tappedDishIds.add(dishId);
          } else {
            widget.tappedDishIds.remove(dishId);
          }
        });
        widget.onTap();
      },
      child: Card(
        elevation:
            (_isTapped || widget.tappedDishIds.contains(dishId)) ? 10 : 1,
        shadowColor: (_isTapped || widget.tappedDishIds.contains(dishId))
            ? const Color.fromARGB(255, 204, 0, 255)
            : null,
        child: Center(
          child: GridTile(
            child: Column(
              children: [
                widget.imageCache.containsKey(dishId)
                    ? Container(
                        margin: const EdgeInsets.all(7),
                        height: 130,
                        width: 150,
                        child: Hero(
                          tag: dishId,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
