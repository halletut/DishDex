import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/signin_login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({Key? key}) : super(key: key);

  @override
  GroceryListState createState() => GroceryListState();
}

class GroceryListState extends State<GroceryList> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool iconPressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(103, 29, 77, 45),
          title: Text(
            "GROCERY LIST",
            style:
                GoogleFonts.mulish(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: TextButton(
                    onPressed: () => {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      )
                    },
                    child: const Text("Logout"),
                  ),
                )
              ],
            )
          ],
        ),
        body: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Dishes')
                  .where('menu', isEqualTo: true)
                  .where('user', isEqualTo: auth.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('You havent added any dishes to the menu!'));
                }

                Set<String> menuIngredients = <String>{};

                for (var doc in snapshot.data!.docs) {
                  List<dynamic> ingredients = doc['ingredients'];
                  menuIngredients.addAll(ingredients.cast<String>());
                }

                List<String> ingredientsList = menuIngredients.toList();

                return ListView.builder(
                  itemCount: ingredientsList.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredientsList[index];
                    final even = index % 2 == 0 ? true : false;

                    return MyCard(
                      ingredient: ingredient,
                      even: even,
                    );
                  },
                );
              }),
        ));
  }
}

class MyCard extends StatefulWidget {
  final String ingredient;
  final bool even;

  const MyCard({Key? key, required this.ingredient, required this.even})
      : super(key: key);

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.even
        ? const Color.fromARGB(129, 194, 195, 192)
        : const Color.fromARGB(224, 251, 253, 248);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 2),
      color: color,
      child: ListTile(
        onTap: () {
          setState(() {
            isPressed = !isPressed;
          });
        },
        title: Text(widget.ingredient.toUpperCase()),
        trailing: Icon(
          isPressed ? Icons.check_circle : Icons.circle_outlined,
          color:
              isPressed ? const Color.fromARGB(255, 47, 68, 48) : Colors.grey,
        ),
      ),
    );
  }
}
