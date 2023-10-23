import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:blur/blur.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:share_plus/share_plus.dart';

class EditingScreen extends StatefulWidget {
  EditingScreen({super.key, required this.selectedImage});

  File? selectedImage;

  @override
  State<EditingScreen> createState() => _EditingScreenState();
}

class _EditingScreenState extends State<EditingScreen> {
  Color color1 = const Color.fromARGB(0, 0, 0, 0);
  Color color2 = const Color.fromARGB(0, 0, 0, 0);
  bool isImageSave = false;

  Widget editingSection1 = Container(
    key: ValueKey(0),
  );

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
      color1 = selectedImageColorSheme.secondary;
      color2 = selectedImageColorSheme.primary;
    });
  }

  Widget setSaveButtonText() {
    if (!isImageSave) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Text(
          AppLocalizations.of(context)!.inTheGallery,
          style: const TextStyle(color: Color.fromARGB(255, 224, 224, 224)),
        ),
        const Icon(
          Icons.download,
          color: Color.fromARGB(255, 224, 224, 224),
        )
      ]);
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.saved,
            style: const TextStyle(color: Color.fromARGB(255, 224, 224, 224)),
          ),
          const Icon(
            Icons.check,
            color: Colors.green,
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: color2,
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
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      builder: (BuildContext context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return Container(
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: Color.fromARGB(255, 16, 15, 22),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    AppLocalizations.of(context)!.save,
                                    style: const TextStyle(
                                        color:
                                            Color.fromARGB(255, 224, 224, 224),
                                        fontSize: 20),
                                  ),
                                ),
                                OutlinedButton(
                                    style: const ButtonStyle(
                                        side: MaterialStatePropertyAll(
                                            BorderSide(
                                                color: Color.fromARGB(
                                                    255, 224, 224, 244)))),
                                    onPressed: () {
                                      GallerySaver.saveImage(
                                          widget.selectedImage!.path);
                                      isImageSave = true;
                                      setState(() {});
                                    },
                                    child: setSaveButtonText()),
                                OutlinedButton(
                                    style: const ButtonStyle(
                                        side: MaterialStatePropertyAll(
                                            BorderSide(
                                                color: Color.fromARGB(
                                                    255, 224, 224, 244)))),
                                    onPressed: () async {
                                      XFile file =
                                          XFile(widget.selectedImage!.path);
                                      final result = await Share.shareXFiles(
                                        [file],
                                      );
                                    },
                                    child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.share,
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 224, 224, 224)),
                                          ),
                                          const Icon(
                                            Icons.share,
                                            color: Color.fromARGB(
                                                255, 224, 224, 224),
                                          )
                                        ])),
                              ],
                            ),
                          );
                        });
                      });
                },
              ),
            ],
          ),
        ),
        body: Stack(children: [
          PhotoView(
            backgroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [color1, color2],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter)),
            maxScale: PhotoViewComputedScale.covered * 2,
            minScale: PhotoViewComputedScale.contained,
            loadingBuilder: (context, event) {
              return Container(
                color: const Color.fromARGB(255, 16, 15, 22),
                child: Center(
                    child:
                        Lottie.asset('assets/animations/logo_animation.json')),
              );
            },
            imageProvider: FileImage(widget.selectedImage!),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 120,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        child: EditingSection(),
                        onTap: () {
                          setState(() {
                            editingSection1 =
                                EditingSection.thisSectionFunctions;
                          });
                        },
                      ),
                      EditingSection(),
                      EditingSection(),
                    ],
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0, 1), // Slide from right to left
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
                child: editingSection1,
              )
            ],
          )
        ]));
  }
}

class EditingSection extends StatelessWidget {
  EditingSection({
    super.key,
  });

  static Widget thisSectionFunctions = SizedBox(
    height: 100,
    child: ListView(scrollDirection: Axis.horizontal, children: const [
      EditingFunctionWidget(),
      EditingFunctionWidget(),
      EditingFunctionWidget(),
      EditingFunctionWidget(),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20),
        child: Container(
            width: 100,
            height: 100,
            color: Colors.black,
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.style,
                    color: Color.fromARGB(255, 224, 224, 224),
                    size: 70,
                  ),
                  Text(
                    'Name',
                    style: TextStyle(color: Color.fromARGB(255, 224, 224, 224)),
                  )
                ],
              ),
            )),
      ),
    );
  }
}

class EditingFunctionWidget extends StatelessWidget {
  const EditingFunctionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
      child: Container(
          width: 100,
          height: 100,
          color: Colors.black,
          child: const Center(
            child: Column(
              children: [
                Icon(
                  Icons.style,
                  color: Color.fromARGB(255, 224, 224, 224),
                  size: 70,
                ),
                Text(
                  'Name',
                  style: TextStyle(color: Color.fromARGB(255, 224, 224, 224)),
                )
              ],
            ),
          )),
    );
  }
}
