import 'dart:io';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/args/pick_finger/pick_finger_args.dart';
import 'package:bailey/models/args/pick_hand/pick_hand_args.dart';
import 'package:bailey/models/args/scan_prints/scan_prints_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/picker/picker_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

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
                            ? 'To mark/unmark a finger as amputated long press on the tile'
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
                                  if (widget.arguments.mode == 'gallery') {
                                    String? file = await PickerUtil.pickImage();
                                    if (file != null && file != '') {
                                      printFiles[index] = file;
                                      _checkValidity();
                                    }
                                  } else {
                                    bool granted = false;
                                    PermissionStatus permission =
                                        await Permission.camera.status;
                                    print(permission);
                                    if (permission == PermissionStatus.denied ||
                                        permission ==
                                            PermissionStatus
                                                .permanentlyDenied) {
                                      permission =
                                          await Permission.camera.request();
                                      if (permission !=
                                              PermissionStatus.denied &&
                                          permission !=
                                              PermissionStatus
                                                  .permanentlyDenied) {
                                        granted = true;
                                      }
                                    } else {
                                      granted = true;
                                    }
                                    if (granted) {
                                      Navigator.of(context)
                                          .pushNamed(scanPrintsRoute,
                                              arguments: ScanPrintsArgs(
                                                  scans: printFiles))
                                          .then((value) {
                                        List<String?>? prints =
                                            value as List<String?>?;
                                        if (prints != null) {
                                          printFiles = prints;
                                          _checkValidity();
                                        }
                                      });
                                    } else {
                                      ToastUtils.showCustomSnackbar(
                                          context: context,
                                          contentText:
                                              'Please grant this app camera permissions from your settings',
                                          type: 'error');
                                    }
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
                            if (widget.arguments.currentHand == "Left") {
                              handsScanned.first = true;
                            } else {
                              handsScanned.last = true;
                            }
                            if (handsScanned
                                .any((element) => element == false)) {
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
      onLongPress: () {
        if (widget.arguments.mode == 'gallery') {
          if (printFiles[index] == 'amputated') {
            printFiles[index] = null;
          } else {
            printFiles[index] = 'amputated';
          }
          _checkValidity();
        }
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
              printFiles[index] != null && printFiles[index] != 'amputated'
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$handName Hand", style: TypeStyle.label),
                    Text(title, style: TypeStyle.h3),
                  ],
                ),
              ),
              printFiles[index] == null
                  ? SvgPicture.asset(
                      widget.arguments.mode == 'gallery'
                          ? 'assets/icons/ic_upload.svg'
                          : 'assets/icons/ic_fingerprint.svg',
                      height: 20,
                    )
                  : printFiles[index] != 'amputated'
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
                          'Amputated',
                          style: TypeStyle.body,
                        ),
              Visibility(
                visible: printFiles[index] != null,
                child: GestureDetector(
                  onTap: () {
                    printFiles[index] = null;
                    _checkValidity();
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
