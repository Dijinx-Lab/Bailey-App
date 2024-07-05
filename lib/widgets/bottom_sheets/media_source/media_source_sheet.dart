import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MediaSourceSheet extends StatelessWidget {
  const MediaSourceSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
          color: ColorStyle.backgroundColor,
          borderRadius: BorderRadius.circular(18)),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: (MediaQuery.of(context).size.width / 2),
                child: Image.asset(
                  'assets/images/print_image.png',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Select import',
                style: TypeStyle.h1,
              ),
            ),
            const SizedBox(height: 30),
            _buildTileWidget(
              'Take a photo',
              'ic_camera',
              () => Navigator.of(context).pop('camera'),
            ),
            const SizedBox(height: 20),
            _buildTileWidget(
              'Upload a photo',
              'ic_image',
              () => Navigator.of(context).pop('gallery'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _buildTileWidget(
    String subTitle,
    String icon,
    Function onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorStyle.borderColor),
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            SvgPicture.asset(
              'assets/icons/$icon.svg',
              height: 25,
              width: 25,
            ),
            const SizedBox(width: 10),
            const VerticalDivider(
              thickness: 1,
              width: 1,
              color: ColorStyle.borderColor,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(subTitle, style: TypeStyle.h2)),
            Transform.flip(
              flipX: true,
              child: SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
            )
          ]),
        ),
      ),
    );
  }
}
