import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/args/pick_finger/pick_finger_args.dart';
import 'package:bailey/models/args/pick_hand/pick_hand_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PickHandScreen extends StatefulWidget {
  final PickHandArgs arguments;
  const PickHandScreen({super.key, required this.arguments});

  @override
  State<PickHandScreen> createState() => _PickHandScreenState();
}

class _PickHandScreenState extends State<PickHandScreen> {
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
                        widget.arguments.mode == 'gallery'
                            ? 'Upload Finger Prints'
                            : 'Finger Print Scanner',
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
                        widget.arguments.mode == 'gallery'
                            ? 'Select which hand images you will upload'
                            : 'Select which hand you scanning',
                        textAlign: TextAlign.center,
                        style: TypeStyle.h1,
                      ),
                      const SizedBox(height: 20),
                      _buildTileWidget('Left Hand', 'ic_left_hand', () {
                        Navigator.of(context).pushNamed(
                          pickFingerRoute,
                          arguments: PickFingerArgs(
                              previousHandScanned: false,
                              currentHand: 'Left',
                              mode: widget.arguments.mode),
                        );
                      }, true),
                      const SizedBox(height: 20),
                      _buildTileWidget('Right Hand', 'ic_right_hand', () {
                        Navigator.of(context).pushNamed(
                          pickFingerRoute,
                          arguments: PickFingerArgs(
                              previousHandScanned: false,
                              currentHand: 'Right',
                              mode: widget.arguments.mode),
                        );
                      }, false)
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

  _buildTileWidget(String title, String icon, Function onTap, bool filled) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorStyle.borderColor),
        ),
        child: Row(children: [
          SvgPicture.asset(
            filled ? 'assets/icons/ic_done.svg' : 'assets/icons/ic_radio.svg',
            width: 18,
          ),
          const SizedBox(width: 10),
          SvgPicture.asset('assets/icons/$icon.svg'),
          const SizedBox(width: 20),
          Expanded(child: Text(title, style: TypeStyle.h3)),
          Transform.flip(
              flipX: true,
              child: SvgPicture.asset('assets/icons/ic_chevron_back.svg')),
        ]),
      ),
    );
  }
}
