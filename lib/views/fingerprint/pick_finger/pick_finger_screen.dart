import 'dart:io';
import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/api/entities/upload/upload_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/fingerprint/response/fingerprint_response.dart';
import 'package:bailey/models/api/session/session/session.dart';
import 'package:bailey/models/api/upload/response/upload_response.dart';
import 'package:bailey/models/args/pick_finger/pick_finger_args.dart';
import 'package:bailey/models/args/pick_hand/pick_hand_args.dart';
import 'package:bailey/models/args/process_print/process_print_args.dart';
import 'package:bailey/models/events/refresh_home/refresh_home_event.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/picker/picker_util.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/views/base/base_screen.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

class PickFingerScreen extends StatefulWidget {
  final PickFingerArgs arguments;
  const PickFingerScreen({super.key, required this.arguments});

  @override
  State<PickFingerScreen> createState() => _PickFingerScreenState();
}

class _PickFingerScreenState extends State<PickFingerScreen> {
  late String handName;
  late List<bool> handsScanned;
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

  List<String?> printFiles = [];
  bool isValid = false;

  @override
  void initState() {
    printFiles = List.filled(5, null);
    handName = widget.arguments.currentHand;
    handsScanned = widget.arguments.handsScanned;
    super.initState();
  }

  _checkValidity() {
    isValid = !printFiles.any((element) => element == null);
    setState(() {});
  }

  Future<String?> _makeUpload(String path, String fingerType) async {
    try {
      final paths = UploadService.getUploadFilePath(
        uploadType: UploadType.fingerprint,
        isLeftHand: widget.arguments.currentHand == "Left",
        fingerType: fingerType,
      );
      final value = await ApiService.upload(
        fileName: paths["filename"]!,
        folder: paths["folder"]!,
        filePath: path,
      );
      if (mounted) {
        UploadResponse? apiResponse =
            ApiService.processResponse(value, context) as UploadResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            String uploadId = apiResponse.data?.upload?.id ?? "";
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
      if (mounted) {
        ToastUtils.showCustomSnackbar(
            context: context,
            contentText: "An error occurred during upload",
            type: "fail");
      }
    }
    return null;
  }

  _uploadPrints() async {
    List<String?> uploadIds = List.filled(5, null);
    List<bool> sizeChecks = [];
    for (String? printPath in printFiles) {
      if (printPath != null && printPath != "skip") {
        sizeChecks.add(await PickerUtil.isFileSmallerThan(printPath, 10));
      }
    }
    if (mounted && sizeChecks.contains(false)) {
      ToastUtils.showCustomSnackbar(
          context: context,
          contentText:
              "One or more files are too large, please make sure your media is 10MB or less",
          type: "fail");
      return;
    }
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 4));
    for (int i = 0; i < printFiles.length; i++) {
      String? printPath = printFiles[i];
      if (printPath != null && printPath != "skip") {
        uploadIds[i] = await _makeUpload(printPath, fingerTypes[i]);
      } else {
        uploadIds[i] = printPath;
      }
    }
    for (int i = 0; i < printFiles.length; i++) {
      if (uploadIds[i] != null) {
        final value = await ApiService.addPrint(
            hand: widget.arguments.currentHand.toLowerCase(),
            finger: fingerTypes[i],
            uploadId: uploadIds[i]!);
        if (mounted) {
          FingerprintResponse? apiResponse =
              ApiService.processResponse(value, context)
                  as FingerprintResponse?;
          if (apiResponse != null) {
            if (apiResponse.success != true) {
              ToastUtils.showCustomSnackbar(
                  context: context,
                  contentText: apiResponse.message ?? "",
                  type: "fail");
            }
          }
        }
      }
    }
    Session? session = PrefUtil().currentSession;
    session?.fingerprintsAdded = true;
    PrefUtil().currentSession = session;

    BaseScreen.eventBus.fire(RefreshHomeEvent());
    SmartDialog.dismiss();
    if (mounted) {
      if (widget.arguments.currentHand == "Left") {
        handsScanned.first = true;
      } else {
        handsScanned.last = true;
      }
      if (handsScanned.any((element) => element == false)) {
        Navigator.of(context).pushNamed(
          pickHandRoute,
          arguments: PickHandArgs(
            handsScanned: handsScanned,
            mode: widget.arguments.mode,
          ),
        );
      } else {
        Navigator.of(context).pushNamed(successRoute);
      }
    }
  }

  _redirectToSource(bool fromGallery, int index) async {
    String? file;
    if (fromGallery) {
      file = await PickerUtil.pickImage(addCropper: false);
    } else {
      file = await PickerUtil.captureImage(addCropper: false);
    }

    if (file != null && file != "" && mounted) {
      Navigator.of(context)
          .pushNamed(processPrintRoute,
              arguments: ProcessPrintArgs(filePath: file))
          .then((value) {
        String? newPath = value as String?;
        if (newPath != null) {
          printFiles[index] = newPath;
          _checkValidity();
        }
      });
    }
  }

  _openSource(bool fromGallery, int index) {
    if (PrefUtil().showFingerprintTips) {
      Navigator.of(context).pushNamed(tipsRoute).then((value) async {
        bool? res = value as bool?;
        if (res == true) {
          _redirectToSource(fromGallery, index);
        }
      });
    } else {
      _redirectToSource(fromGallery, index);
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
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon: SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Finger Print Scanner',
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
                      Text(
                        'Step ${widget.arguments.handsScanned.where((element) => element == true).length + 1}',
                        style: TypeStyle.h2,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ColorStyle.whiteColor),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: widget.arguments.handsScanned
                                      .any((element) => element == true)
                                  ? ColorStyle.whiteColor
                                  : ColorStyle.borderColor,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      SvgPicture.asset(
                        'assets/icons/ic_fingerprint.svg',
                        width: 30,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.arguments.mode == 'gallery'
                            ? 'Upload finger prints'
                            : 'Scan each finger print',
                        style: TypeStyle.h1,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.arguments.mode == 'gallery'
                            ? 'To skip/unskip a finger long press on the tile'
                            : 'To scan each fingerprint continue by tapping on the finger\'s tile',
                        textAlign: TextAlign.center,
                        style: TypeStyle.body,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: List.generate(
                              fingerNames.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildTileWidget(
                                    index, fingerNames[index], () async {
                                  if (printFiles[index] == null) {
                                    _openSource(
                                        widget.arguments.mode == 'gallery',
                                        index);
                                  }
                                }, true),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: MRoundedButton(
                          'Continue',
                          () {
                            _uploadPrints();
                          },
                          isEnabled: isValid,
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

  _buildTileWidget(int index, String title, Function onTap, bool filled) {
    return GestureDetector(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              printFiles[index] != null && printFiles[index] != 'skip'
                  ? SizedBox(
                      width: 25,
                      height: 30,
                      child: Image.file(
                        File(printFiles[index]!),
                        fit: BoxFit.cover,
                      ),
                    )
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$handName Hand", style: TypeStyle.label),
                    Text(title, style: TypeStyle.h3),
                  ],
                ),
              ),
              printFiles[index] == null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: TextButton(
                        onPressed: () {
                          // if (widget.arguments.mode == 'gallery') {
                          if (printFiles[index] == 'skip') {
                            printFiles[index] = null;
                          } else {
                            printFiles[index] = 'skip';
                          }
                          _checkValidity();
                          // }
                        },
                        child: Text('Skip', style: TypeStyle.h3),
                      ),
                    )
                  : const SizedBox.shrink(),
              printFiles[index] == null
                  ? SvgPicture.asset(
                      widget.arguments.mode == 'gallery'
                          ? 'assets/icons/ic_upload.svg'
                          : 'assets/icons/ic_fingerprint.svg',
                      height: 20,
                    )
                  : printFiles[index] != 'skip'
                      ? GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  "${widget.arguments.currentHand} ${fingerNames[index]}",
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
                                content: Image.file(
                                  File(printFiles[index]!),
                                ),
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
                visible: printFiles[index] != null,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: SvgPicture.asset('assets/icons/ic_cancel.svg'),
                  onPressed: () {
                    printFiles[index] = null;
                    _checkValidity();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
