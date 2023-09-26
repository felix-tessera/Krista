import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:blur/blur.dart';

class EditingScreen extends StatefulWidget {
  EditingScreen({super.key, required this.selectedImage});

  File? selectedImage;

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  Color dominationColor = const Color.fromARGB(0, 0, 0, 0);

  @override
  void initState() {
    super.initState();
    setBackgroundDominationColor();
  }

  setBackgroundDominationColor() async {
    final ColorScheme selectedImageColorSheme =
        await ColorScheme.fromImageProvider(
            provider: FileImage(widget.selectedImage!));
    setState(() {
      dominationColor = selectedImageColorSheme.secondary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: dominationColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
          backgroundColor: const Color.fromARGB(0, 0, 0, 0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Blur(
                  overlay: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SvgPicture.asset(
                        'assets/images/vector_back.svg',
                        width: 20,
                      ),
                      SvgPicture.asset(
                        'assets/images/vector_forward.svg',
                        width: 20,
                      )
                    ],
                  ),
                  blur: 3,
                  child: Container(
                    decoration:
                        const BoxDecoration(color: Color.fromARGB(39, 0, 0, 0)),
                    width: 140,
                    height: 40,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.done),
                onPressed: () {},
              ),
            ],
          ),
        ),
        body: PhotoView(
          backgroundDecoration: BoxDecoration(
            color: dominationColor,
          ),
          maxScale: PhotoViewComputedScale.covered * 2,
          minScale: PhotoViewComputedScale.contained,
          loadingBuilder: (context, event) {
            return Container(
              color: const Color.fromARGB(255, 16, 15, 22),
              child: Center(
                  child: Lottie.asset('assets/animations/logo_animation.json')),
            );
          },
          imageProvider: FileImage(widget.selectedImage!),
        ));
  }
}
