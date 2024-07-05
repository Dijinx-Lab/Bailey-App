import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/args/pick_finger/pick_finger_args.dart';
import 'package:bailey/models/args/scan_prints/scan_prints_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PickFingerScreen extends StatefulWidget {
  final PickFingerArgs arguments;
  const PickFingerScreen({super.key, required this.arguments});

  @override
  State<PickFingerScreen> createState() => _PickFingerScreenState();
}

class _PickFingerScreenState extends State<PickFingerScreen> {
  late String handName;
  bool previousHandScanned = false;
  List<String> fingerNames = [
    'Pinky',
    'Ring Finger',
    'Middle Finger',
    'Index Finger',
    'Thumb'
  ];

  List<String?> printFiles = [];

  @override
  void initState() {
    printFiles = List.filled(5, null);
    handName = widget.arguments.currentHand;
    previousHandScanned = widget.arguments.previousHandScanned;
    super.initState();
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
                        'Step 1',
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
                                color: ColorStyle.borderColor),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      SvgPicture.asset('assets/icons/ic_hands.svg'),
                      const SizedBox(height: 10),
                      Text(
                        'Scan each finger print',
                        style: TypeStyle.h1,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'To scan fingerprint continue with “Scan” feature',
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
                                    fingerNames[index], () {}, true),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: MRoundedButton(
                          'Scan',
                          () {
                            Navigator.of(context)
                                .pushNamed(scanPrintsRoute,
                                    arguments:
                                        ScanPrintsArgs(scans: printFiles))
                                .then((value) {
                              List<String?>? prints = value as List<String?>?;

                              if (prints != null) {
                                printFiles = prints;
                              }
                            });
                          },
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

  _buildTileWidget(String title, Function onTap, bool filled) {
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
          child: Row(children: [
            SvgPicture.asset(
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
            )),
            SvgPicture.asset(
              'assets/icons/ic_fingerprint.svg',
              height: 20,
            ),
          ]),
        ),
      ),
    );
  }
}