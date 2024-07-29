import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/fingerprint/fingerprint/fingerprint.dart';
import 'package:bailey/models/api/fingerprint/list_response/fingerprint_list_response.dart';
import 'package:bailey/models/api/fingerprint/response/fingerprint_response.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/upload/response/upload_response.dart';
import 'package:bailey/models/args/process_print/process_print_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/picker/picker_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/bottom_sheets/media_source/media_source_sheet.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:bailey/widgets/m_picture/m_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

class ViewPrintsScreen extends StatefulWidget {
  const ViewPrintsScreen({super.key});

  @override
  State<ViewPrintsScreen> createState() => _ViewPrintsScreenState();
}

class _ViewPrintsScreenState extends State<ViewPrintsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isLoading = true;
  bool _allowEdit = false;

  List<String> fingerNames = [
    'Pinky',
    'Ring Finger',
    'Middle Finger',
    'Index Finger',
    'Thumb'
  ];
  List<String> fingerTypes = [
    "pinky",
    "ring",
    "middle",
    "index",
    "thumb",
  ];

  late List<Fingerprint?> originalLeftHandPrints;
  late List<Fingerprint?> originalRightHandPrints;

  late List<Fingerprint?> leftHandPrints;
  late List<Fingerprint?> rightHandPrints;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    leftHandPrints = List.filled(5, null);
    rightHandPrints = List.filled(5, null);
    _getPrints();
    super.initState();
  }

  _canEdit() {
    for (int i = 0; i < originalLeftHandPrints.length; i++) {
      if (originalLeftHandPrints[i]?.changeKey !=
          leftHandPrints[i]?.changeKey) {
        _allowEdit = true;
      }
    }
    if (!_allowEdit) {
      for (int i = 0; i < originalRightHandPrints.length; i++) {
        if (originalRightHandPrints[i]?.changeKey !=
            rightHandPrints[i]?.changeKey) {
          _allowEdit = true;
        }
      }
    }

    setState(() {});
  }

  _getPrints() {
    setState(() => _isLoading = true);
    ApiService.listPrints().then((value) async {
      FingerprintListResponse? apiResponse =
          ApiService.processResponse(value, context)
              as FingerprintListResponse?;
      setState(() => _isLoading = false);
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          for (Fingerprint fingerprint in apiResponse.data?.leftHand ?? []) {
            int foundIndex = fingerTypes.indexOf(fingerprint.finger ?? "");
            if (foundIndex != -1) {
              leftHandPrints[foundIndex] = fingerprint;
            }
          }
          for (Fingerprint fingerprint in apiResponse.data?.rightHand ?? []) {
            int foundIndex = fingerTypes.indexOf(fingerprint.finger ?? "");
            if (foundIndex != -1) {
              rightHandPrints[foundIndex] = fingerprint;
            }
          }
          originalLeftHandPrints = leftHandPrints
              .map((fp) => fp == null ? null : Fingerprint.copy(fp))
              .toList();
          originalRightHandPrints = rightHandPrints
              .map((fp) => fp == null ? null : Fingerprint.copy(fp))
              .toList();
          _allowEdit = false;
          setState(() {});
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    });
  }

  _updateChangeKey(String? file, bool leftHand, int index,
      {List<String>? files}) {
    if (files != null) {
      for (String? file in files) {
        if (file != null && file != '') {
          if (leftHand) {
            leftHandPrints[index]!.changeKey = file;
          } else {
            rightHandPrints[index]!.changeKey = file;
          }
        }
      }
    } else {
      if (file != null && file != '') {
        if (leftHand) {
          leftHandPrints[index]!.changeKey = file;
        } else {
          rightHandPrints[index]!.changeKey = file;
        }
      }
    }
    _canEdit();
  }

  Future<String?> _openSourceSheet() async {
    String? source = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18.0),
        ),
      ),
      backgroundColor: ColorStyle.backgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) => const MediaSourceSheet(),
    );
    return source;
  }

  _saveChanges() async {
    try {
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 5));
      for (int i = 0; i < originalLeftHandPrints.length; i++) {
        if (originalLeftHandPrints[i]?.changeKey !=
            leftHandPrints[i]?.changeKey) {
          if (leftHandPrints[i]?.changeKey == null) {
            await _deletePrint(leftHandPrints[i]!.id!);
          } else if (originalLeftHandPrints[i]?.changeKey == null &&
              leftHandPrints[i]?.changeKey != null) {
            await _addPrint(true, i);
          } else {
            await _editPrint(true, i);
          }
        }
      }

      for (int i = 0; i < originalRightHandPrints.length; i++) {
        if (originalRightHandPrints[i]?.changeKey !=
            rightHandPrints[i]?.changeKey) {
          if (rightHandPrints[i]?.changeKey == null) {
            await _deletePrint(rightHandPrints[i]!.id!);
          } else if (originalRightHandPrints[i]?.changeKey == null &&
              rightHandPrints[i]?.changeKey != null) {
            await _addPrint(false, i);
          } else {
            await _editPrint(false, i);
          }
        }
      }
      SmartDialog.dismiss();
      _getPrints();
    } catch (e) {
      print(e);
      SmartDialog.dismiss();
      _getPrints();
    }
  }

  Future<bool?> _deletePrint(String id) async {
    try {
      var value = await ApiService.deletePrint(printId: id);
      if (!mounted) return null;
      GenericResponse? apiResponse =
          ApiService.processResponse(value, context) as GenericResponse?;
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          return true;
        } else if (mounted) {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<bool?> _addPrint(bool leftHand, int index) async {
    try {
      String? uploadId;
      if (leftHand) {
        uploadId = leftHandPrints[index]?.changeKey == 'skip'
            ? 'skip'
            : await _makeUpload(leftHandPrints[index]?.changeKey ?? "");
      } else {
        uploadId = rightHandPrints[index]?.changeKey == 'skip'
            ? 'skip'
            : await _makeUpload(rightHandPrints[index]?.changeKey ?? "");
      }
      print(uploadId);

      if (uploadId == null) return null;
      var value = await ApiService.addPrint(
          hand: leftHand ? 'left' : 'right',
          finger: leftHand
              ? leftHandPrints[index]!.finger!
              : rightHandPrints[index]!.finger!,
          uploadId: uploadId);
      if (!mounted) return null;
      FingerprintResponse? apiResponse =
          ApiService.processResponse(value, context) as FingerprintResponse?;
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          return true;
        } else if (mounted) {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    } catch (e) {
      print("finger ${rightHandPrints[index]?.finger}");
      print(e);
    }
    return null;
  }

  Future<bool?> _editPrint(bool leftHand, int index) async {
    try {
      String? uploadId;
      if (leftHand) {
        uploadId = leftHandPrints[index]?.changeKey == 'skip'
            ? 'skip'
            : await _makeUpload(leftHandPrints[index]?.changeKey ?? "");
      } else {
        uploadId = rightHandPrints[index]?.changeKey == 'skip'
            ? 'skip'
            : await _makeUpload(rightHandPrints[index]?.changeKey ?? "");
      }

      if (uploadId == null) return null;
      var value = await ApiService.editPrint(
          printId: leftHand
              ? leftHandPrints[index]!.id!
              : rightHandPrints[index]!.id!,
          uploadId: uploadId);
      if (!mounted) return null;
      FingerprintResponse? apiResponse =
          ApiService.processResponse(value, context) as FingerprintResponse?;
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          return true;
        } else if (mounted) {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String?> _makeUpload(String path) async {
    try {
      final value =
          await ApiService.upload(folder: 'fingerprints', filePath: path);
      if (mounted) {
        UploadResponse? apiResponse =
            ApiService.processResponse(value, context) as UploadResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            String uploadId = apiResponse.data?.upload?.id ?? "";
            print(uploadId);
            return uploadId;
          } else {
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: apiResponse.message ?? "",
                type: "fail");
          }
        }
      }
    } catch (e) {
      ToastUtils.showCustomSnackbar(
          context: context,
          contentText: "An error occurred during upload",
          type: "fail");
    }
    return null;
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
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon: SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Fingerprints',
                        style: TypeStyle.h2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedContainer(
                  duration: Durations.medium1,
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: _isLoading
                        ? null
                        : Border.all(color: ColorStyle.borderColor),
                  ),
                  child: Column(
                    children: [
                      _buildTabBar(),
                      const SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        child: _isLoading
                            ? LoadingUtil.buildAdaptiveLoader()
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildPrintsList(true),
                                  _buildPrintsList(false),
                                ],
                              ),
                      ),
                      AnimatedCrossFade(
                        crossFadeState: (!_allowEdit || _isLoading)
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: Durations.medium1,
                        firstChild: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: MRoundedButton(
                              'Save',
                              () => _saveChanges(),
                            ),
                          ),
                        ),
                        secondChild: Container(),
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

  _buildTabBar() {
    return TabBar(
      controller: _tabController,
      dividerColor: Colors.transparent,
      tabs: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/ic_left_hand.svg'),
              const SizedBox(
                width: 8,
              ),
              Text(
                'Left Hand',
                style: TypeStyle.h3,
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/ic_right_hand.svg'),
              const SizedBox(
                width: 8,
              ),
              Text(
                'Right Hand',
                style: TypeStyle.h3,
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildPrintsList(bool leftHand) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          fingerNames.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildTileWidget(index, fingerNames[index], () async {
              if (_isNull(index, leftHand)) {
                String? source = await _openSourceSheet();
                if (source == 'gallery') {
                  String? file = await PickerUtil.pickImage(addCropper: false);
                  if (file != null && file != "" && mounted) {
                    Navigator.of(context)
                        .pushNamed(processPrintRoute,
                            arguments: ProcessPrintArgs(filePath: file))
                        .then((value) {
                      String? newPath = value as String?;
                      if (newPath != null) {
                        _updateChangeKey(newPath, leftHand, index);
                      }
                    });
                  }
                } else if (source == 'camera') {
                  String? file =
                      await PickerUtil.captureImage(addCropper: false);
                  if (file != null && file != "" && mounted) {
                    Navigator.of(context)
                        .pushNamed(processPrintRoute,
                            arguments: ProcessPrintArgs(filePath: file))
                        .then((value) {
                      String? newPath = value as String?;
                      if (newPath != null) {
                        _updateChangeKey(newPath, leftHand, index);
                      }
                    });
                  }
                }
              }
            }, leftHand),
          ),
        ),
      ),
    );
  }

  bool _isSkipped(int index, bool leftHand) {
    if (leftHand) {
      return leftHandPrints[index]?.isSkipped == true;
    } else {
      return rightHandPrints[index]?.isSkipped == true;
    }
  }

  bool _isNull(int index, bool leftHand) {
    if (leftHand) {
      return leftHandPrints[index]?.changeKey == null;
    } else {
      return rightHandPrints[index]?.changeKey == null;
    }
  }

  String _getUrl(bool leftHand, int index) {
    if (leftHand) {
      return leftHandPrints[index]?.changeKey ?? "";
    } else {
      return rightHandPrints[index]?.changeKey ?? "";
    }
  }

  _buildTileWidget(int index, String title, Function onTap, bool leftHand) {
    return GestureDetector(
      onLongPress: () {
        if (leftHand) {
          if (leftHandPrints[index]?.changeKey == null) {
            leftHandPrints[index]?.changeKey = 'skip';
            leftHandPrints[index]?.isSkipped = true;
          } else {
            leftHandPrints[index]?.changeKey = null;
            leftHandPrints[index]?.isSkipped = false;
          }
        } else {
          if (rightHandPrints[index]?.changeKey == null) {
            rightHandPrints[index]?.changeKey = 'skip';
            leftHandPrints[index]?.isSkipped = true;
          } else {
            rightHandPrints[index]?.changeKey = null;
            leftHandPrints[index]?.isSkipped = false;
          }
        }

        _canEdit();
      },
      onTap: () => onTap(),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorStyle.borderColor),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              (!_isNull(index, leftHand) && !_isSkipped(index, leftHand))
                  ? MPicture(
                      width: 25,
                      height: 25,
                      fit: BoxFit.scaleDown,
                      url: _getUrl(leftHand, index))
                  : SvgPicture.asset(
                      'assets/icons/ic_finger.svg',
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
                    Text("${leftHand ? 'Left' : 'Right'} Hand",
                        style: TypeStyle.label),
                    Text(title, style: TypeStyle.h3),
                  ],
                ),
              ),
              _isNull(index, leftHand)
                  ? SvgPicture.asset(
                      'assets/icons/ic_fingerprint.svg',
                      height: 20,
                    )
                  : !_isSkipped(index, leftHand)
                      ? GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  "${leftHand ? 'Left' : 'Right'} ${fingerNames[index]}",
                                  style: TypeStyle.h1,
                                ),
                                titlePadding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 20),
                                backgroundColor: ColorStyle.backgroundColor,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                actionsAlignment: MainAxisAlignment.center,
                                buttonPadding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 20),
                                actions: [
                                  SizedBox(
                                    width: double.maxFinite,
                                    height: 50,
                                    child: MRoundedButton('Done', () {
                                      Navigator.of(context).pop();
                                    }),
                                  )
                                ],
                                content: MPicture(
                                    url: leftHand
                                        ? leftHandPrints[index]
                                                ?.upload
                                                ?.accessUrl ??
                                            ""
                                        : rightHandPrints[index]
                                                ?.upload
                                                ?.accessUrl ??
                                            ""),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 30,
                            child: SvgPicture.asset('assets/icons/ic_eye.svg'),
                          ),
                        )
                      : Text(
                          'Skipped',
                          style: TypeStyle.body,
                        ),
              Visibility(
                visible: !_isNull(index, leftHand),
                child: GestureDetector(
                  onTap: () {
                    if (leftHand) {
                      leftHandPrints[index]?.changeKey = null;
                    } else {
                      rightHandPrints[index]?.changeKey = null;
                    }
                    _canEdit();
                  },
                  child: SizedBox(
                    width: 30,
                    child: SvgPicture.asset('assets/icons/ic_cancel.svg'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
