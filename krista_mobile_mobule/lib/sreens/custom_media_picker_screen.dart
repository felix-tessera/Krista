import 'dart:io';

import 'package:flutter/material.dart';
import 'package:krista_mobile_mobule/sreens/editing_screen.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MediaGrid extends StatefulWidget {
  const MediaGrid({super.key});

  @override
  State<MediaGrid> createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  List<Widget> _mediaList = [];
  int currentPage = 0;
  int lastPage = 0;
  dynamic allAlbums = [];
  List<String> allAlbumsNames = [];

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          type: RequestType.image, onlyAll: true);
      debugPrint(albums.toString());
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(page: currentPage, size: 60);
      List<Widget> temp = [];
      for (var asset in media) {
        temp.add(
          FutureBuilder(
            future: asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Stack(
                  children: <Widget>[
                    Positioned.fill(
                        child: GestureDetector(
                      onTap: () async {
                        File? selectedImage = await asset.file;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditingScreen(
                                      selectedImage: selectedImage,
                                    )));
                      },
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        child: Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ))
                  ],
                );
              }
              return Container();
            },
          ),
        );
      }

      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 20,
        toolbarHeight: 60,
        backgroundColor: const Color.fromARGB(255, 16, 15, 22),
        title: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset(
                'assets/images/krista_icon.svg',
                color: const Color.fromARGB(255, 224, 224, 224),
                width: 40,
              ),
              Column(
                children: [
                  const Text(
                    'Krista',
                    style: TextStyle(
                        color: Color.fromARGB(255, 224, 224, 224),
                        fontWeight: FontWeight.bold),
                  ),
                  Text(AppLocalizations.of(context)!.makingTtBetter,
                      style: const TextStyle(
                        color: Color.fromARGB(155, 224, 224, 224),
                        fontSize: 15,
                      ))
                ],
              ),
              const Icon(
                Icons.settings,
                color: Color.fromARGB(255, 224, 224, 224),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 16, 15, 22),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scroll) {
          _handleScrollEvent(scroll);
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: GridView.builder(
              itemCount: _mediaList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                crossAxisCount: 3,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _mediaList[index];
              }),
        ),
      ),
    );
  }
}
