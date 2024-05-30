// ignore_for_file: use_build_context_synchronously
import 'package:firebase_auth/firebase_auth.dart';
import 'DishAddImage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DishDetail extends StatefulWidget {
  const DishDetail({Key? key}) : super(key: key);

  @override
  State<DishDetail> createState() => _DishDetailState();
}

class _DishDetailState extends State<DishDetail> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? ingredients;
  String? dishName;
  String? directions;
  String? id;
  String? imageFile;
  String? user;

  var storageRef = FirebaseStorage.instance.ref();
  final _formKey = GlobalKey<FormState>();

  final dishRef = FirebaseFirestore.instance.collection('Dishes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create a new dish",
          style: GoogleFonts.mulish(),
        ),
      ),
      body: Expanded(
        child: Form(
          key: _formKey,
          child: Container(
            color: const Color.fromARGB(255, 255, 255, 255),
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  heightFactor: 2,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Dish Name:",
                    style: GoogleFonts.mulish(
                        color: const Color.fromARGB(255, 98, 98, 98),
                        fontSize: 15),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Hamburger',
                    hintStyle: GoogleFonts.mulish(
                        color: const Color.fromARGB(255, 166, 166, 166)),
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                    fillColor: const Color.fromARGB(255, 238, 243, 237),
                    filled: true,
                  ),
                  onChanged: (value) => dishName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                Align(
                  heightFactor: 2,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ingredients:",
                    style: GoogleFonts.mulish(
                        color: const Color.fromARGB(255, 98, 98, 98),
                        fontSize: 15),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'leave a comma between items: eggs, milk,',
                    hintStyle: GoogleFonts.mulish(
                        color: const Color.fromARGB(255, 166, 166, 166)),
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                    fillColor: const Color.fromARGB(255, 238, 243, 237),
                    filled: true,
                  ),
                  onChanged: (value1) => ingredients = value1,
                  validator: (value1) {
                    if (value1 == null || value1.isEmpty) {
                      return 'What kind of dish doesn\'t have ingredients??';
                    }
                    return null;
                  },
                ),
                Align(
                  heightFactor: 2,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Cooking directions:",
                    style: GoogleFonts.mulish(
                        color: const Color.fromARGB(255, 98, 98, 98),
                        fontSize: 15),
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Preheat oven to...',
                    hintStyle: GoogleFonts.mulish(
                        color: const Color.fromARGB(255, 166, 166, 166)),
                    border:
                        const OutlineInputBorder(borderSide: BorderSide.none),
                    fillColor: const Color.fromARGB(255, 238, 243, 237),
                    filled: true,
                  ),
                  onChanged: (value2) => directions = value2,
                  validator: (value2) {
                    if (value2 == null || value2.isEmpty) {
                      return "how do i make this?";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
                child: Row(
                  children: [
                    Text(
                      "Continue",
                      style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 30,
                    ),
                  ],
                ),
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    _tryAddDish(dishName!, ingredients!, directions!,
                        auth.currentUser!.uid, false, context);
                  }
                }),
          ],
        ),
      ),
    );
  }

  void _tryAddDish(String dishName, String ingredients, String directions,
      String user, bool menu, BuildContext context) async {
    try {
      final List<String> ingredientList = ingredients.split(',');

      DocumentReference doc = await dishRef.add({
        'dishName': dishName,
        'ingredients': ingredientList,
        'directions': directions,
        'user': user,
        'menu': false
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DishAddImage(dish: doc.id),
        ),
      );
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong! ${e.message}"),
        ),
      );
    }
  }
}
