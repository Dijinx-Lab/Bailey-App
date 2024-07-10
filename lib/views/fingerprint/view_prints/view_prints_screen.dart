import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/args/scan_prints/scan_prints_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/picker/picker_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/bottom_sheets/media_source/media_source_sheet.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

class ViewPrintsScreen extends StatefulWidget {
  const ViewPrintsScreen({super.key});

  @override
  State<ViewPrintsScreen> createState() => _ViewPrintsScreenState();
}

class _ViewPrintsScreenState extends State<ViewPrintsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool canEdit = false;
  List<String> fingerNames = [
    'Pinky',
    'Ring Finger',
    'Middle Finger',
    'Index Finger',
    'Thumb'
  ];

  List<String?> leftPrintFiles = [];
  List<String?> rightPrintFiles = [];

  List<String?> prevLeftPrintFiles = [
    'assets/images/temp_prints.png',
    'skip',
    'assets/images/temp_prints.png',
    'assets/images/temp_prints.png',
    'assets/images/temp_prints.png',
  ];
  List<String?> prevRightPrintFiles = [
    'assets/images/temp_prints.png',
    'assets/images/temp_prints.png',
    'assets/images/temp_prints.png',
    'skip',
    'assets/images/temp_prints.png',
  ];

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

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    leftPrintFiles.addAll(prevLeftPrintFiles);
    rightPrintFiles.addAll(prevRightPrintFiles);
    super.initState();
  }

  _canEdit() {
    canEdit = leftPrintFiles != prevLeftPrintFiles ||
        rightPrintFiles != prevRightPrintFiles;
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
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ColorStyle.borderColor),
                  ),
                  child: Column(
                    children: [
                      _buildTabBar(),
                      const SizedBox(
                        height: 30,
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildPrintsList(true),
                            _buildPrintsList(false),
                          ],
                        ),
                      ),
                      AnimatedCrossFade(
                        crossFadeState: canEdit
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: Durations.medium1,
                        firstChild: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: MRoundedButton('Save', () {}),
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
                  String? file = await PickerUtil.pickImage();
                  if (file != null && file != '') {
                    if (leftHand) {
                      leftPrintFiles[index] = file;
                    } else {
                      rightPrintFiles[index] = file;
                    }
                  }
                  _canEdit();
                } else {
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
                    Navigator.of(context)
                        .pushNamed(scanPrintsRoute,
                            arguments: ScanPrintsArgs(
                                scans: leftHand
                                    ? leftPrintFiles
                                    : rightPrintFiles))
                        .then((value) {
                      List<String?>? prints = value as List<String?>?;
                      if (prints != null) {
                        leftHand
                            ? leftPrintFiles = prints
                            : rightPrintFiles = prints;
                        _canEdit();
                      }
                    });
                  } else {
                    if (!mounted) return;
                    ToastUtils.showCustomSnackbar(
                        context: context,
                        contentText:
                            'Please grant this app camera permissions from your settings',
                        type: 'error');
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
      return leftPrintFiles[index] == 'skip';
    } else {
      return rightPrintFiles[index] == 'skip';
    }
  }

  bool _isNull(int index, bool leftHand) {
    if (leftHand) {
      return leftPrintFiles[index] == null;
    } else {
      return rightPrintFiles[index] == null;
    }
  }

  _buildTileWidget(int index, String title, Function onTap, bool leftHand) {
    return GestureDetector(
      onLongPress: () {
        if (leftHand) {
          if (leftPrintFiles[index] == 'skip') {
            leftPrintFiles[index] = null;
          } else {
            leftPrintFiles[index] = 'skip';
          }
        } else {
          if (rightPrintFiles[index] == 'skip') {
            rightPrintFiles[index] = null;
          } else {
            rightPrintFiles[index] = 'skip';
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
                  ? SizedBox(
                      width: 25,
                      height: 30,
                      child: Image.asset(
                        leftHand
                            ? leftPrintFiles[index]!
                            : rightPrintFiles[index]!,
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
                                content: Image.asset(
                                  leftHand
                                      ? leftPrintFiles[index]!
                                      : rightPrintFiles[index]!,
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
                visible: !_isNull(index, leftHand),
                child: GestureDetector(
                  onTap: () {
                    if (leftHand) {
                      leftPrintFiles[index] = null;
                    } else {
                      rightPrintFiles[index] = null;
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
