import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({super.key});

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 10),
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () async {
            bool granted = false;
            PermissionStatus permission = await Permission.camera.status;

            if (permission == PermissionStatus.denied ||
                permission == PermissionStatus.permanentlyDenied) {
              permission = await Permission.camera.request();
              print(permission);
              if (permission != PermissionStatus.denied &&
                  permission != PermissionStatus.permanentlyDenied) {
                granted = true;
              }
            } else {
              granted = true;
            }
            if (granted) {
              final imagesPath = await CunningDocumentScanner.getPictures(
                  noOfPages: 5, isGalleryImportAllowed: true);
            } else {
              if (!mounted) return;
              ToastUtils.showCustomSnackbar(
                  context: context,
                  contentText:
                      'Please grant this app camera permissions from your settings',
                  type: 'error');
            }
          },
          shape: const CircleBorder(),
          elevation: 5,
          child: const Icon(
            Icons.add,
            color: ColorStyle.blackColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon: SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Hand Writings',
                        style: TypeStyle.h2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ColorStyle.borderColor),
                  ),
                  child: SingleChildScrollView(
                    child: MasonryView(
                      listOfItem: List.generate(5, (index) {
                        if (index % 3 == 0) {
                          return "assets/images/temp_writing_1.jpg";
                        } else {
                          return "assets/images/temp_writing_2.jpeg";
                        }
                      }),
                      numberOfColumn: 2,
                      itemRadius: 6,
                      itemPadding: 4,
                      itemBuilder: (val) => Image.asset(
                        val,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
