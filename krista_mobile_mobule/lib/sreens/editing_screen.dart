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

class _EditingScreenState extends State<EditingScreen>
    with SingleTickerProviderStateMixin {
  Color color1 = const Color.fromARGB(0, 0, 0, 0);
  Color color2 = const Color.fromARGB(0, 0, 0, 0);
  bool isImageSave = false;

  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  bool _isEditingMenuItemActive = false;

  @override
  void initState() {
    super.initState();
    setBackgroundDominationColor();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _sizeAnimation = Tween<double>(begin: 20.0, end: 20.0).animate(_controller);
    _controller.addListener(() {
      setState(() {});
    });
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
                child: Padding(
                  padding: EdgeInsets.only(bottom: _sizeAnimation.value),
                  child: SizedBox(
                    height: 100,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _isEditingMenuItemActive =
                                !_isEditingMenuItemActive;
                            if (_isEditingMenuItemActive) {
                              _controller.forward();
                              setState(() {
                                currentFilterList = styleFilters;
                              });
                            } else {
                              _controller.reverse();
                              setState(() {
                                currentFilterList = filtersMock;
                              });
                            }
                          },
                          child: EditingMenuItem(
                            menuItemIcon: Icons.style_outlined,
                            menuItemName: AppLocalizations.of(context)!.style,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _isEditingMenuItemActive =
                                !_isEditingMenuItemActive;
                            if (_isEditingMenuItemActive) {
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                          },
                          child: EditingMenuItem(
                            menuItemIcon: Icons.color_lens_outlined,
                            menuItemName: AppLocalizations.of(context)!.color,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _isEditingMenuItemActive =
                                !_isEditingMenuItemActive;
                            if (_isEditingMenuItemActive) {
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                          },
                          child: EditingMenuItem(
                            menuItemIcon: Icons.auto_awesome,
                            menuItemName: AppLocalizations.of(context)!.quality,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: currentFilterList,
              )
            ],
          )
        ]));
  }
}

class EditingMenuItem extends StatefulWidget {
  EditingMenuItem(
      {super.key, required this.menuItemIcon, required this.menuItemName});

  final String menuItemName;
  final IconData menuItemIcon;

  @override
  State<EditingMenuItem> createState() => _EditingMenuItemState();
}

class _EditingMenuItemState extends State<EditingMenuItem> {
  static const double iconSize = 50.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        width: 100,
        height: 100,
        // color: Colors.black,
        child: Column(children: [
          Icon(
            widget.menuItemIcon,
            color: const Color.fromARGB(255, 224, 224, 224),
            size: iconSize,
            shadows: const [
              Shadow(
                color: Colors.white,
                blurRadius: 5.0,
              )
            ],
          ),
          Text(
            widget.menuItemName,
            style: const TextStyle(
                color: Color.fromARGB(255, 224, 224, 224),
                fontWeight: FontWeight.w700),
          )
        ]),
      ),
    );
  }
}

class MenuItemFilter extends StatefulWidget {
  const MenuItemFilter({super.key, required this.filterName});

  final filterName;

  @override
  State<MenuItemFilter> createState() => _MenuItemFilterState();
}

class _MenuItemFilterState extends State<MenuItemFilter> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      child: Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  'https://i.pinimg.com/564x/35/ba/25/35ba25c1966a6df120294d495dc21b28.jpg'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              widget.filterName,
              style: const TextStyle(
                  color: Color.fromARGB(255, 224, 224, 224),
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

Widget currentFilterList = filtersMock;

Widget styleFilters = SizedBox(
  height: 110,
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: const [
      MenuItemFilter(filterName: 'filterName'),
      MenuItemFilter(filterName: 'filterName'),
      MenuItemFilter(filterName: 'filterName'),
      MenuItemFilter(filterName: 'filterName'),
    ],
  ),
);

Widget filtersMock = Container();
