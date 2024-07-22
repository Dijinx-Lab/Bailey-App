// import 'dart:io';

// import 'package:bailey/models/args/scan_prints/scan_prints_args.dart';
// import 'package:bailey/style/color/color_style.dart';
// import 'package:bailey/style/type/type_style.dart';
// import 'package:bailey/utility/toast/toast_utils.dart';
// import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:image/image.dart' as img;

// class ScanPrintsScreen extends StatefulWidget {
//   final ScanPrintsArgs arguments;
//   const ScanPrintsScreen({super.key, required this.arguments});

//   @override
//   State<ScanPrintsScreen> createState() => _ScanPrintsScreenState();
// }

// class _ScanPrintsScreenState extends State<ScanPrintsScreen> {
//   final GlobalKey _cameraPreviewKey = GlobalKey();
//   List<String> fingerNames = [
//     'Pinky',
//     'Ring Finger',
//     'Middle Finger',
//     'Index Finger',
//     'Thumb'
//   ];

//   List<String?> printFiles = [];
//   int _currentIndex = 0;

//   CameraController? _controller;
//   Future<void>? _initializeControllerFuture;
//   bool isCaptured = false;
//   bool showFocusCircle = false;
//   double x = 0;
//   double y = 0;

//   @override
//   void initState() {
//     printFiles = widget.arguments.scans;
//     int index = widget.arguments.initIndex ??
//         printFiles.indexWhere((element) => element == null);
//     if (index == -1) {
//       Navigator.of(context).pop();
//     } else {
//       _currentIndex = index;
//     }
//     _initializeCamera();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     if (cameras.isEmpty ||
//         !cameras.any(
//             (element) => element.lensDirection == CameraLensDirection.back)) {
//       if (!mounted) return;
//       Navigator.of(context).pop();
//       ToastUtils.showCustomSnackbar(
//           context: context,
//           contentText: 'Your device doesn\'t have a back camera to scan prints',
//           type: 'error');
//     }
//     final firstCamera = cameras.firstWhere(
//         (element) => element.lensDirection == CameraLensDirection.back);
//     _controller = CameraController(
//       firstCamera,
//       ResolutionPreset.max,
//       enableAudio: false,
//     );
//     _initializeControllerFuture = _controller!.initialize();
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   // void _onCameraTap(
//   //   TapDownDetails details,
//   // ) async {
//   //   print('Global Position: ${details.globalPosition}');
//   //   print('Local Position: ${details.localPosition}');

//   //   if (_controller?.value.isInitialized ?? false) {
//   //     final RenderBox renderBox =
//   //         _cameraPreviewKey.currentContext!.findRenderObject() as RenderBox;
//   //     final position = renderBox.localToGlobal(Offset.zero);
//   //     print('Key Position: ${position}');
//   //     final relativeOffset = Offset(
//   //       (details.globalPosition.dx - position.dx) / renderBox.size.width,
//   //       (details.globalPosition.dy - position.dy) / renderBox.size.height,
//   //     );

//   //     print('Relative Offset: $relativeOffset');
//   //     await _controller!.setFocusPoint(relativeOffset);
//   //   }
//   // }

//   Future<void> _onCameraTap(TapDownDetails details) async {
//     if (_controller?.value.isInitialized ?? false) {
//       showFocusCircle = true;
//       x = details.localPosition.dx;
//       y = details.localPosition.dy;

//       double fullWidth = MediaQuery.of(context).size.width;
//       double cameraHeight = fullWidth * _controller!.value.aspectRatio;

//       double xp = x / fullWidth;
//       double yp = y / cameraHeight;

//       Offset point = Offset(xp, yp);

//       await _controller!.setFocusPoint(point);

//       setState(() {
//         Future.delayed(const Duration(seconds: 2)).whenComplete(() {
//           setState(() {
//             showFocusCircle = false;
//           });
//         });
//       });
//     }
//   }

//   Future<void> _capturePicture() async {
//     try {
//       await _initializeControllerFuture;
//       final image = await _controller!.takePicture();
//       final File imageFile = File(image.path);
//       final img.Image originalImage =
//           img.decodeImage(imageFile.readAsBytesSync())!;
//       final img.Image greyscaleImage = img.grayscale(originalImage);
//       final img.Image highContrastImage =
//           img.adjustColor(greyscaleImage, contrast: 3);
//       imageFile.writeAsBytesSync(img.encodeJpg(highContrastImage));
//       printFiles[_currentIndex] = image.path;
//       isCaptured = true;
//       setState(() {});
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 15),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(printFiles),
//                     visualDensity: VisualDensity.compact,
//                     icon: SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
//                   ),
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         'Scan Finger Print',
//                         style: TypeStyle.h2,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 40,
//                   )
//                 ],
//               ),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: Container(
//                   width: double.maxFinite,
//                   padding: const EdgeInsets.all(15),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(6),
//                     border: Border.all(color: ColorStyle.borderColor),
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 20),
//                       Center(
//                         child: Text(
//                           fingerNames[_currentIndex],
//                           style: TypeStyle.h1,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(
//                           fingerNames.length,
//                           (index) => Container(
//                             width: 30,
//                             height: 5,
//                             margin: const EdgeInsets.symmetric(horizontal: 2),
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 color: printFiles[index] == null
//                                     ? ColorStyle.borderColor
//                                     : ColorStyle.whiteColor),
//                           ),
//                         ),
//                       ),
//                       Container(
//                           width: double.maxFinite,
//                           margin: const EdgeInsets.all(15),
//                           padding: const EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: ColorStyle.borderColor),
//                           ),
//                           child: IntrinsicHeight(
//                             child: Row(
//                               children: [
//                                 SvgPicture.asset(
//                                   'assets/icons/ic_info.svg',
//                                   height: 25,
//                                 ),
//                                 const SizedBox(width: 10),
//                                 const VerticalDivider(
//                                   thickness: 1,
//                                   width: 1,
//                                   color: ColorStyle.borderColor,
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Expanded(
//                                     child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                         isCaptured
//                                             ? "Successfully Scanned"
//                                             : "Keep your hand steady",
//                                         style: TypeStyle.h3),
//                                     Text(
//                                         isCaptured
//                                             ? "Move to other finger"
//                                             : "Try not to move camera while scanning",
//                                         style: TypeStyle.label),
//                                   ],
//                                 )),
//                               ],
//                             ),
//                           )),
//                       Center(
//                         child: _buildScanPage(),
//                       ),
//                       const Spacer(),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15),
//                         child: isCaptured
//                             ? SizedBox(
//                                 height: 50,
//                                 width: double.infinity,
//                                 child: MRoundedButton(
//                                   widget.arguments.singleScan
//                                       ? 'Done'
//                                       : 'Continue',
//                                   () {
//                                     if (widget.arguments.singleScan) {
//                                       Navigator.of(context)
//                                           .pop([printFiles[_currentIndex]]);
//                                     } else {
//                                       int index = printFiles.indexWhere(
//                                           (element) => element == null);
//                                       if (index != -1) {
//                                         _currentIndex++;
//                                         isCaptured = false;
//                                         setState(() {});
//                                       } else {
//                                         Navigator.of(context).pop(printFiles);
//                                       }
//                                     }
//                                   },
//                                 ),
//                               )
//                             : Row(
//                                 children: [
//                                   Expanded(
//                                     child: SizedBox(
//                                       height: 50,
//                                       width: double.infinity,
//                                       child: MRoundedButton(
//                                         'Skip',
//                                         () {
//                                           printFiles[_currentIndex] = 'skip';
//                                           int index = printFiles.indexWhere(
//                                               (element) => element == null);
//                                           if (index != -1) {
//                                             _currentIndex++;
//                                             setState(() {});
//                                           } else {
//                                             Navigator.of(context)
//                                                 .pop(printFiles);
//                                           }
//                                         },
//                                         borderColor: ColorStyle.whiteColor,
//                                         textColor: ColorStyle.whiteColor,
//                                         buttonBackgroundColor:
//                                             ColorStyle.backgroundColor,
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     width: 10,
//                                   ),
//                                   Expanded(
//                                     child: SizedBox(
//                                       height: 50,
//                                       width: double.infinity,
//                                       child: MRoundedButton(
//                                         'Capture',
//                                         () => _capturePicture(),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   _buildScanPage() {
//     return Container(
//       //width: double.maxFinite,
//       margin: const EdgeInsets.all(15),
//       decoration: isCaptured
//           ? null
//           : BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: ColorStyle.whiteColor),
//             ),
//       child: isCaptured
//           ? Image.file(
//               File(printFiles[_currentIndex]!),
//               fit: BoxFit.contain,
//             )
//           : FutureBuilder<void>(
//               future: _initializeControllerFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Stack(
//                       children: [
//                         GestureDetector(
//                           onTapDown: (details) => _onCameraTap(details),
//                           child: CameraPreview(
//                               key: _cameraPreviewKey, _controller!),
//                         ),
//                         if (showFocusCircle)
//                           Positioned(
//                               top: y - 20,
//                               left: x - 20,
//                               child: Container(
//                                 height: 40,
//                                 width: 40,
//                                 decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                         color: ColorStyle.secondaryTextColor,
//                                         width: 1.5)),
//                               ))
//                       ],
//                     ),
//                   );
//                 } else {
//                   return Container();
//                 }
//               },
//             ),
//     );
//   }
// }
