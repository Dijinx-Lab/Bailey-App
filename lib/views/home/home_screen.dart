import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.maxFinite,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Home',
                        style: TypeStyle.h2,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/icons/ic_logo_white.png',
                        width: 60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildFreshView(),
            ],
          ),
        ),
      ),
    );
  }

  _buildFreshView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Center(
          child: SizedBox(
            width: (MediaQuery.of(context).size.width / 2),
            child: Image.asset(
              'assets/images/sign_image.png',
            ),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: Text(
            'Choose type of capture',
            style: TypeStyle.h1,
          ),
        ),
        const SizedBox(height: 30),
        _buildTileWidget('Hand Writing', 'ic_sign', () {
          Navigator.of(context).pushNamed(pickHandRoute);
        }),
        const SizedBox(height: 20),
        _buildTileWidget('Photo', 'ic_image', () {}),
        const SizedBox(height: 20),
        _buildTileWidget('Print', 'ic_print', () {}),
      ],
    );
  }

  _buildTileWidget(String title, String icon, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorStyle.borderColor),
        ),
        child: Row(children: [
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
