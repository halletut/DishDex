// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:final_project/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

//DishAddImage  is the screen that lets you upload an image to your dish
class DishAddImage extends StatefulWidget {
  final String dish;

  const DishAddImage({required this.dish, Key? key}) : super(key: key);

  @override
  State<DishAddImage> createState() => _DishAddImageState();
}

class _DishAddImageState extends State<DishAddImage> {
  String? imageFile;
  String? error;
  final Completer<void> _snackBarCompleter = Completer<void>();
  var storageRef = FirebaseStorage.instance.ref();

  @override
  void initState() {
    super.initState();
  }

  void _getDishImg(file) async {
    try {
      Reference dishImgRef = storageRef.child('DishImages/$file');

      String downloadUrl = await dishImgRef.getDownloadURL();
      setState(() {
        imageFile = downloadUrl;
        error = null;
      });
    } catch (e) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Create a new dish",
            style: GoogleFonts.mulish(),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageFile != null
                ? Image.network(
                    imageFile!,
                    width: 250,
                    height: 250,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          Text(
                            "Error loading image: $error",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      );
                    },
                  )
                : const Icon(
                    Icons.camera_alt_sharp,
                    size: 40,
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Color.fromARGB(255, 55, 72, 58)),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
                        shadowColor: WidgetStatePropertyAll(
                            Color.fromARGB(255, 40, 83, 46))),
                    onPressed: () =>
                        _getImage(ImageSource.gallery, widget.dish),
                    child: Text("Gallery",
                        style: GoogleFonts.mulish(
                            color: const Color.fromARGB(255, 207, 231, 216)))),
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                onTap: () async {
                  await _snackBarCompleter.future;

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                }),
          ]),
        ));
  }

  _getImage(ImageSource source, String id) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      String fileExtension = '';
      int period = image.path.lastIndexOf('.');
      if (period > -1) {
        fileExtension = image.path.substring(period);
      }
      final dishImgRef = storageRef.child('DishImages/$id$fileExtension');
      String file = id + fileExtension;
      try {
        await dishImgRef.putFile(File(image.path));

        imageFile = await dishImgRef.getDownloadURL();
        setState(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                const SnackBar(
                  content: Text("Your dish image was uploaded successfully"),
                  duration: Duration(seconds: 1),
                ),
              )
              .closed
              .then((_) {
            _snackBarCompleter.complete();
          });
        });
      } on FirebaseAuthException catch (err) {
        setState(() {
          error = err.message;
        });
      }

      setState(() {
        imageFile = image.path;
      });

      _getDishImg(file);
    }
  }
}
