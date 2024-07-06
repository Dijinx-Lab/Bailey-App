import 'dart:io';

import 'package:bailey/models/args/scan_prints/scan_prints_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image/image.dart' as img;

class ScanPrintsScreen extends StatefulWidget {
  final ScanPrintsArgs arguments;
  const ScanPrintsScreen({super.key, required this.arguments});

  @override
  State<ScanPrintsScreen> createState() => _ScanPrintsScreenState();
}

class _ScanPrintsScreenState extends State<ScanPrintsScreen> {
  List<String> fingerNames = [
    'Pinky',
    'Ring Finger',
    'Middle Finger',
    'Index Finger',
    'Thumb'
  ];

  List<String?> printFiles = [];
  int _currentIndex = 0;

  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool isCaptured = false;

  @override
  void initState() {
    printFiles = widget.arguments.scans;
    int index = printFiles.indexWhere((element) => element == null);
    if (index == -1) {
      Navigator.of(context).pop();
    } else {
      _currentIndex = index;
    }
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.last;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _capturePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      final File imageFile = File(image.path);
      final img.Image originalImage =
          img.decodeImage(imageFile.readAsBytesSync())!;
      final img.Image greyscaleImage = img.grayscale(originalImage);
      final img.Image highContrastImage =
          img.adjustColor(greyscaleImage, contrast: 3);
      imageFile.writeAsBytesSync(img.encodeJpg(highContrastImage));
      printFiles[_currentIndex] = image.path;
      isCaptured = true;
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(printFiles),
                    visualDensity: VisualDensity.compact,
                    icon: SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Scan Finger Print',
                        style: TypeStyle.h2,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 40,
                  )
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
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          fingerNames[_currentIndex],
                          style: TypeStyle.h1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          fingerNames.length,
                          (index) => Container(
                            width: 30,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: printFiles[index] == null
                                    ? ColorStyle.borderColor
                                    : ColorStyle.whiteColor),
                          ),
                        ),
                      ),
                      Container(
                          width: double.maxFinite,
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ColorStyle.borderColor),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ic_info.svg',
                                  height: 25,
                                ),
                                const SizedBox(width: 10),
                                const VerticalDivider(
                                  thickness: 1,
                                  width: 1,
                                  color: ColorStyle.borderColor,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        isCaptured
                                            ? "Successfully Scanned"
                                            : "Keep your hand steady",
                                        style: TypeStyle.h3),
                                    Text(
                                        isCaptured
                                            ? "Move to other finger"
                                            : "Try not to move camera while scanning",
                                        style: TypeStyle.label),
                                  ],
                                )),
                              ],
                            ),
                          )),
                      Expanded(
                        child: _buildScanPage(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: isCaptured
                            ? SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: MRoundedButton(
                                  'Continue',
                                  () {
                                    int index = printFiles.indexWhere(
                                        (element) => element == null);
                                    if (index != -1) {
                                      _currentIndex++;
                                      isCaptured = false;
                                      setState(() {});
                                    } else {
                                      Navigator.of(context).pop(printFiles);
                                    }
                                  },
                                ),
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: MRoundedButton(
                                        'Amputated',
                                        () {
                                          printFiles[_currentIndex] =
                                              'amputated';
                                          int index = printFiles.indexWhere(
                                              (element) => element == null);
                                          if (index != -1) {
                                            _currentIndex++;
                                            setState(() {});
                                          } else {
                                            Navigator.of(context)
                                                .pop(printFiles);
                                          }
                                        },
                                        borderColor: ColorStyle.whiteColor,
                                        textColor: ColorStyle.whiteColor,
                                        buttonBackgroundColor:
                                            ColorStyle.backgroundColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: MRoundedButton(
                                        'Capture',
                                        () => _capturePicture(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildScanPage() {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.all(15),
      decoration: isCaptured
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorStyle.whiteColor),
            ),
      child: isCaptured
          ? Image.file(
              File(printFiles[_currentIndex]!),
              fit: BoxFit.contain,
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CameraPreview(_controller!));
                } else {
                  return Container();
                }
              },
            ),
    );
  }
}
