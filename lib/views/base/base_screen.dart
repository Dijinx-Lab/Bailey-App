import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/views/home/home_screen.dart';
import 'package:bailey/views/settings/settings_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;
  late PageController _controller;

  final List<Widget> _widgets = const [
    HomeScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    _controller = PageController(initialPage: _index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
          child: PageView.builder(
        controller: _controller,
        itemCount: _widgets.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _widgets[index];
        },
      )),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent, // Removes the ripple effect
          highlightColor: Colors.transparent, // Removes the highlight effect
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              label: '',
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _index == 0
                      ? ColorStyle.whiteColor
                      : ColorStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorStyle.secondaryTextColor),
                ),
                child: SvgPicture.asset(
                  'assets/icons/ic_home.svg',
                  color: _index == 0
                      ? ColorStyle.blackColor
                      : ColorStyle.whiteColor,
                ),
              ),
            ),
            BottomNavigationBarItem(
              label: '',
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _index == 1
                      ? ColorStyle.whiteColor
                      : ColorStyle.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorStyle.secondaryTextColor),
                ),
                child: SvgPicture.asset(
                  'assets/icons/ic_settings.svg',
                  color: _index == 1
                      ? ColorStyle.blackColor
                      : ColorStyle.whiteColor,
                ),
              ),
            ),
          ],
          type: BottomNavigationBarType.fixed,
          elevation: 3,
          currentIndex: _index,
          showUnselectedLabels: true,
          unselectedFontSize: 0,
          selectedFontSize: 0,
          onTap: (value) {
            _controller.animateToPage(value,
                duration: Durations.medium1, curve: Curves.decelerate);
            _index = value;
            setState(() {});
          },
          backgroundColor: ColorStyle.backgroundColor,
          selectedItemColor: ColorStyle.primaryColor,
          unselectedItemColor: ColorStyle.secondaryTextColor,
        ),
      ),
    );
  }
}
