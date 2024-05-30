// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DishEditor extends StatefulWidget {
  final String dish;
  const DishEditor({required this.dish, Key? key}) : super(key: key);

  @override
  State<DishEditor> createState() => _DishEditorState();
}

class _DishEditorState extends State<DishEditor> {
  String? error;
  String? imageFile;
  void _getDishImg() async {
    try {
      ListResult result = await storageRef.child('DishImages').listAll();
      for (Reference ref in result.items) {
        if (ref.name.startsWith(widget.dish)) {
          imageFile = await ref.getDownloadURL();
          if (mounted) {
            setState(() {
              //redraw this bitch
            });
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
      });
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _getDish(
      String documentId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> dishSnapshot =
          await FirebaseFirestore.instance
              .collection('Dishes')
              .doc(documentId)
              .get();
      if (dishSnapshot.exists) return dishSnapshot;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong! $e"),
        ),
      );
    }
    return null;
  }

  Future<void> _deleteDish(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Dishes')
          .doc(documentId)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong! $e"),
        ),
      );
    }
    return;
  }

  var storageRef = FirebaseStorage.instance.ref();
  @override
  void initState() {
    super.initState();
    _getDish(widget.dish);
    _getDishImg();
  }

  Future<void> _deleteDishPop(name) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Are you sure you want to delete $name?"),
            content: const Text("You can't undo this action."),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("No")),
              TextButton(
                  onPressed: () {
                    _deleteDish(widget.dish);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ));
                  },
                  child: const Text("Yes"))
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      future: _getDish(widget.dish),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LinearProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Document not found');
        } else {
          var currDish = snapshot.data!.data();

          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(103, 29, 77, 45),
              title: Text(
                currDish!['dishName'].toUpperCase(),
                style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
                //Todo: add a pop up box on the right to edit or delete.
              ),
              actions: [
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        child: TextButton(
                            onPressed: () =>
                                {_deleteDishPop(currDish['dishName'])},
                            child: const Text("Delete")))
                  ],
                )
              ],
            ),
            body: ListView(
              children: [
                if (imageFile == null)
                  const ListTile(
                    title: Icon(Icons.lunch_dining_sharp, size: 72),
                  ),
                if (imageFile != null)
                  ListTile(
                    title: Align(
                      alignment: Alignment.center,
                      child: Hero(
                        tag: widget.dish,
                        child: CachedNetworkImage(
                          imageUrl: imageFile!,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          placeholder: (context, url) => (const Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator())),
                          width: 350,
                          height: 350,
                        ),
                      ),
                    ),
                  ),
                ListTile(
                  title: Text(
                    "Cooking Instructions:",
                    style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: Text(
                    currDish['directions'],
                    style: GoogleFonts.mulish(),
                  ),
                ),
                ListTile(
                  title: Text(
                    "Ingredients:",
                    style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currDish['ingredients'].length,
                  itemBuilder: (BuildContext context, int index) {
                    String ingredient = currDish['ingredients'][index];
                    return ListTile(
                      title: Text(ingredient, style: GoogleFonts.mulish()),
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
