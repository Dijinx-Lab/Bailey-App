import 'dart:typed_data';
import 'package:bailey/models/args/editor/edit_history/edit_history.dart';
import 'package:bailey/models/args/editor/editor_args/editor_args.dart';
import 'package:bailey/models/args/editor/image_editor_tab/image_editor_tab.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/utility/data_structures/stack_structure.dart';
import 'package:bailey/views/editor/action_bar.dart';
import 'package:bailey/views/editor/image_cropper_screen.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageEditorScreen extends StatefulWidget {
  final EditorArgs arguments;
  const ImageEditorScreen({super.key, required this.arguments});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  late Uint8List data;
  late img.Image originalImage;
  late img.Image baseImage;
  late img.Image editedImage;
  StackStructure<EditHistory> editHistory = StackStructure<EditHistory>();
  late List<ImageEditorTab> tabs = [];
  final ScrollController _scrollController = ScrollController();

  //Selected Tab
  int? tabIndex;

  // Sliders values
  late double brightness;
  late double contrast;
  late double exposure;
  late double saturation;
  late double blacks;
  late double whites;

  // Tint
  late double red;
  late double green;
  late double blue;

  //Light Related Sliders
  List<Widget> _getLightWidgets() {
    return [
      _buildSlider("Contrast", contrast, 0, 2, (value) {
        updateImage();
      }, (value) {
        setState(() {
          contrast = value;
        });
      }),
      _buildSlider("Brightness", brightness, 0, 2, (value) {
        updateImage();
      }, (value) {
        setState(() {
          brightness = value;
        });
      }),
      _buildSlider("Exposure", exposure, 0, 1, (value) {
        updateImage();
      }, (value) {
        setState(() {
          exposure = value;
        });
      }),
      _buildSlider("Shadows", blacks, 0, 1, (value) {
        updateImage();
      }, (value) {
        setState(() {
          blacks = value;
        });
      }),
      _buildSlider("Highlights", whites, 0, 1, (value) {
        updateImage();
      }, (value) {
        setState(() {
          whites = value;
        });
      }),
    ];
  }

  //Color Related Sliders
  List<Widget> _getColorWidgets() {
    return [
      _buildSlider("Saturation", saturation, 0, 2, (value) {
        updateImage();
      }, (value) {
        setState(() {
          saturation = value;
        });
      }),
      _buildSlider("Red", red, 0, 255, (value) {
        updateImage();
      }, (value) {
        setState(() {
          red = value;
        });
      }),
      _buildSlider("Green", green, 0, 255, (value) {
        updateImage();
      }, (value) {
        setState(() {
          green = value;
        });
      }),
      _buildSlider("Blue", blue, 0, 255, (value) {
        updateImage();
      }, (value) {
        setState(() {
          blue = value;
        });
      }),
    ];
  }

  @override
  void initState() {
    _initEditorValues();
    tabs = [
      ImageEditorTab(name: 'Light', icon: Icons.light_mode_outlined),
      ImageEditorTab(name: 'Color', icon: Icons.color_lens_outlined),
      ImageEditorTab(name: 'Adjust', icon: Icons.crop),
    ];
    super.initState();
  }

  _initEditorValues() {
    data = widget.arguments.imageData;
    originalImage = img.decodeImage(data)!;
    baseImage = originalImage.clone();
    editedImage = originalImage.clone();

    brightness = 1;
    contrast = 1;
    exposure = 0;
    saturation = 1;
    blacks = 0;
    whites = 0;
    red = 0;
    green = 0;
    blue = 0;

    editHistory.clearStack();
    setState(() {});
  }

  img.Color toImageColor(Color flutterColor) {
    return img.ColorRgb8(
        flutterColor.red, flutterColor.green, flutterColor.blue);
  }

  void updateImage() {
    try {
      editedImage = baseImage.clone();

      editedImage = img.adjustColor(
        editedImage,
        brightness: brightness,
        contrast: contrast,
        exposure: exposure,
        saturation: saturation,
        gamma: 1.0 + (blacks * 0.5) - (whites * 0.5),
      );

      editedImage = img.colorOffset(
        editedImage,
        red: red,
        green: green,
        blue: blue,
      );

      data = Uint8List.fromList(img.encodePng(editedImage));
      editHistory.push(EditHistory(
        params: _getParams(),
        data: Uint8List.fromList(data),
      ));
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  List<double> _getParams() {
    return [
      brightness,
      contrast,
      exposure,
      saturation,
      blacks,
      whites,
      red,
      green,
      blue,
    ];
  }

  _setParams(List<double> params) {
    brightness = params[0];
    contrast = params[1];
    exposure = params[2];
    saturation = params[3];
    blacks = params[4];
    whites = params[5];
    red = params[6];
    green = params[7];
    blue = params[8];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ActionBar(
        canUndo: editHistory.canPop(),
        onBack: () => Navigator.of(context).pop(),
        onOk: () => Navigator.of(context).pop(data),
        onReset: _initEditorValues,
        onUndo: () {
          if (editHistory.canPop()) {
            editHistory.pop();
            if (editHistory.canPop()) {
              var history = editHistory.peak();
              data = Uint8List.fromList(history.data);
              _setParams(history.params);
            } else {
              _initEditorValues();
            }
            setState(() {});
          }
        },
      ),
      backgroundColor: ColorStyle.blackColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Image.memory(data, fit: BoxFit.contain),
            ),
            AnimatedContainer(
              duration: Durations.medium1,
              height: tabIndex == null || tabIndex == 2 ? 0 : 245,
              child: SizedBox(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 220,
                        decoration: const BoxDecoration(
                          color: ColorStyle.backgroundColor,
                        ),
                        child: RawScrollbar(
                          radius: const Radius.circular(10),
                          thumbColor: ColorStyle.whiteColor.withOpacity(0.6),
                          thickness: 3,
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView(
                            controller: _scrollController,
                            children: tabIndex == 0
                                ? _getLightWidgets()
                                : _getColorWidgets(),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Visibility(
                        visible: tabIndex != null && tabIndex != 2,
                        child: GestureDetector(
                          onTap: () => setState(() => tabIndex = null),
                          child: Container(
                            decoration: BoxDecoration(
                                color: ColorStyle.backgroundColor,
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(
                              Icons.arrow_downward,
                              color: ColorStyle.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Row(
          children: List.generate(
            tabs.length,
            (index) => Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    tabIndex = index;
                  });
                  if (tabIndex == 2) {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => ImageCropperScreen(
                          arguments: EditorArgs(imageData: data),
                        ),
                      ),
                    )
                        .then((res) {
                      Uint8List? croppedData = res as Uint8List?;
                      if (croppedData != null) {
                        data = Uint8List.fromList(croppedData);
                        baseImage = img.decodeImage(data)!;
                        editHistory.push(EditHistory(
                          params: _getParams(),
                          data: Uint8List.fromList(data),
                        ));
                        setState(() {});
                      }
                    });
                  }
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

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double value) onChangedEnds,
    Function(double value) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 5,
            child: Slider(
              value: value,
              min: min,
              max: max,
              inactiveColor: ColorStyle.borderColor,
              onChangeEnd: onChangedEnds,
              onChanged: onChanged,
            ),
          ),
          Text(value.toStringAsFixed(2)),
        ],
      ),
    );
  }
}
