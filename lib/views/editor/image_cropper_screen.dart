import 'dart:typed_data';
import 'dart:ui';
import 'package:bailey/models/args/editor/editor_args/editor_args.dart';
import 'package:bailey/models/args/editor/image_editor_tab/image_editor_tab.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/views/editor/action_bar.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:native_image_cropper/native_image_cropper.dart';

class ImageCropperScreen extends StatefulWidget {
  final EditorArgs arguments;
  const ImageCropperScreen({super.key, required this.arguments});

  @override
  State<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends State<ImageCropperScreen> {
  late Uint8List data;
  late List<ImageEditorTab> tabs = [];

  late CropController _controller;
  final CropMode _mode = CropMode.rect;
  double? _aspectRatio;

  @override
  void initState() {
    _controller = CropController();
    data = widget.arguments.imageData;
    tabs = [
      ImageEditorTab(name: 'Left', icon: Icons.rotate_left_sharp),
      ImageEditorTab(name: 'Right', icon: Icons.rotate_right_sharp),
      ImageEditorTab(name: 'Flip X', icon: Icons.flip_rounded),
      ImageEditorTab(name: 'Flip Y', icon: Icons.flip_rounded),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cropPreview = CropPreview(
      controller: _controller,
      bytes: data,
      mode: _mode,
      hitSize: 30,
      loadingWidget: LoadingUtil.buildAdaptiveLoader(),
      maskOptions: MaskOptions(
        aspectRatio: _aspectRatio,
        backgroundColor: Colors.black.withOpacity(0.5),
        borderColor: ColorStyle.whiteColor.withOpacity(0.7),
        minSize: 100,
        strokeWidth: 3,
      ),
      dragPointBuilder: _buildCropDragPoints,
    );
    return Scaffold(
      appBar: ActionBar(
        onBack: () => Navigator.of(context).pop(),
        onOk: () async {
          var croppedData = await _controller.crop();
          if (context.mounted) {
            Navigator.of(context).pop(croppedData);
          }
        },
        aspectRatio: _aspectRatio,
        onAspectRatio: (value) {
          setState(() {
            _aspectRatio = value;
          });
        },
      ),
      backgroundColor: ColorStyle.blackColor,
      body: SafeArea(
        child: cropPreview,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          children: List.generate(
            tabs.length,
            (index) => Expanded(
              child: TextButton(
                onPressed: () {
                  img.Image? image = img.decodeImage(data);
                  if (image == null) return;

                  switch (index) {
                    case 0:
                      {
                        image = img.copyRotate(image, angle: 270);
                        break;
                      }
                    case 1:
                      {
                        image = img.copyRotate(image, angle: 90);
                        break;
                      }
                    case 2:
                      {
                        image = img.flipHorizontal(image);
                        break;
                      }
                    case 3:
                      {
                        image = img.flipVertical(image);
                        break;
                      }
                  }
                  data = Uint8List.fromList(img.encodePng(image));
                  setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabs[index].icon,
                      size: 18,
                      color: ColorStyle.customSwatchColor[800]!,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      tabs[index].name,
                      style: TextStyle(
                        color: ColorStyle.customSwatchColor[800]!,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  CustomPaint _buildCropDragPoints(
    double size,
    CropDragPointPosition position,
  ) {
    List<Offset> points;
    switch (position) {
      case CropDragPointPosition.topLeft:
        points = [
          Offset(0, size),
          Offset.zero,
          Offset(size, 0),
        ];
      case CropDragPointPosition.topRight:
        points = [
          Offset(-size, 0),
          Offset.zero,
          Offset(0, size),
        ];
      case CropDragPointPosition.bottomLeft:
        points = [
          Offset(0, -size),
          Offset.zero,
          Offset(size, 0),
        ];
      case CropDragPointPosition.bottomRight:
        points = [
          Offset(0, -size),
          Offset.zero,
          Offset(-size, 0),
        ];
    }

    return CustomPaint(
      foregroundPainter: _CropDragPointPainter(
        points: points,
        color: ColorStyle.primaryColor,
      ),
    );
  }
}

class _CropDragPointPainter extends CustomPainter {
  const _CropDragPointPainter({
    required this.points,
    required this.color,
  });

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    canvas.drawPoints(PointMode.polygon, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
