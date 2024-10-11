import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:flutter/material.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
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
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Tips',
                        style: TypeStyle.h2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close),
                  ),
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
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              _buildTipWidget(
                                'Ensure the photo captures the tip of your finger clearly and is well-focused',
                                Icons.filter_center_focus_outlined,
                              ),
                              const SizedBox(height: 20),
                              _buildTipWidget(
                                  'Please be sure to take a picture against a neutral background',
                                  Icons.photo_camera_back_outlined),
                              const SizedBox(height: 20),
                              _buildTipWidget(
                                'Use the flash while capturing your photo to make your contours more prominent and well-defined',
                                Icons.flash_on_outlined,
                              ),
                              const SizedBox(height: 20),
                              _buildTipWidget(
                                'Our in-house AI enhances and extracts the contours of your fingerprint. We do not share this data with any third parties',
                                Icons.grain,
                              ),
                              const SizedBox(height: 20),
                              _buildTipWidget(
                                'If the image is blurry, please retry capturing the image. The app will re-analyze the newly captured photo',
                                Icons.sync_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: !PrefUtil().showFingerprintTips,
                            visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              PrefUtil().showFingerprintTips =
                                  !PrefUtil().showFingerprintTips;
                              setState(() {});
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                "I understand, do not show these tips again",
                                style: TypeStyle.body,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: MRoundedButton(
                            'Continue',
                            () => Navigator.of(context).pop(true),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  _buildTipWidget(String text, IconData icon) {
    return Material(
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: ColorStyle.backgroundColor,
          border: Border.all(
            color: ColorStyle.borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: ColorStyle.whiteColor,
              size: 35,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TypeStyle.body.copyWith(color: ColorStyle.whiteColor),
              ),
            )
          ],
        ),
      ),
    );
  }
}
