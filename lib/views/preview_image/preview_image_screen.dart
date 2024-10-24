import 'dart:io';

import 'package:bailey/models/args/preview_image/preview_image_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share/share.dart';
import 'package:path/path.dart' as path;

class PreviewImageScreen extends StatefulWidget {
  final PreviewImageArgs arguments;
  const PreviewImageScreen({super.key, required this.arguments});

  @override
  State<PreviewImageScreen> createState() => _PreviewImageScreenState();
}

class _PreviewImageScreenState extends State<PreviewImageScreen> {
  late List<String> _images;
  late PageController _pageController;
  late int currentPageNumber;
  @override
  void initState() {
    _images = widget.arguments.imageUrls;
    _images.removeWhere((e) => e == "" || e == "skip");
    _pageController =
        PageController(initialPage: widget.arguments.initialIndex);
    currentPageNumber = widget.arguments.initialIndex + 1;
    super.initState();
  }

  Future<void> _downloadAndShare(String imageUrl) async {
    try {
      if (imageUrl.startsWith('http')) {
        SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
        final ext = path.extension(imageUrl);
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/shared_image$ext';
        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          await Share.shareFiles([filePath]);
        } else {
          if (mounted) {
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: "Failed to download image, please try again later",
                type: "fail");
          }
        }
        SmartDialog.dismiss();
      } else {
        await Share.shareFiles([imageUrl]);
      }
    } catch (e) {
      SmartDialog.dismiss();
      if (mounted) {
        ToastUtils.showCustomSnackbar(
            context: context,
            contentText: "Failed to download image, please try again later",
            type: "fail");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorStyle.blackColor,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              itemCount: _images.length,
              pageController: _pageController,
              onPageChanged: (value) {
                currentPageNumber = value + 1;
                setState(() {});
              },
              loadingBuilder: (context, event) => Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CircularProgressIndicator(
                    color: ColorStyle.borderColor,
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
                  ),
                ),
              ),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: _images[index].startsWith('http')
                      ? NetworkImage(_images[index]) as ImageProvider
                      : AssetImage(_images[index]) as ImageProvider,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  initialScale: PhotoViewComputedScale.contained,
                  heroAttributes: PhotoViewHeroAttributes(tag: _images[index]),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ColorStyle.whiteColor),
                child: Text(
                  '$currentPageNumber / ${_images.length}',
                  style: TypeStyle.info2,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                color: ColorStyle.blackColor.withOpacity(0.4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close),
                    ),
                    Expanded(
                      child: Text(
                        'Preview',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TypeStyle.h2,
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _downloadAndShare(_images[currentPageNumber - 1]),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.share),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
