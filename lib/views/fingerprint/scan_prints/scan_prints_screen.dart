import 'package:bailey/models/args/scan_prints/scan_prints_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

  final int _currentIndex = 0;

  @override
  void initState() {
    printFiles = widget.arguments.scans;

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
                    border: Border.all(
                        color: printFiles[_currentIndex] == null
                            ? ColorStyle.borderColor
                            : ColorStyle.whiteColor),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
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
                                color: ColorStyle.borderColor),
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
                                    Text("Keep your hand steady",
                                        style: TypeStyle.h3),
                                    Text(
                                        "Try not to move camera while scanning",
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
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: MRoundedButton(
                                'Scan',
                                () {},
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: MRoundedButton(
                                'Amputated',
                                () {},
                                borderColor: ColorStyle.whiteColor,
                                textColor: ColorStyle.whiteColor,
                                buttonBackgroundColor:
                                    ColorStyle.backgroundColor,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorStyle.whiteColor),
      ),
    );
  }
}
