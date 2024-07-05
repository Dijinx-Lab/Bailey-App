import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/args/change_password/change_password_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
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
                        'Settings',
                        style: TypeStyle.h2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width / 2),
                  child: Image.asset(
                    'assets/images/settings_image.png',
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Settings page',
                  style: TypeStyle.h1,
                ),
              ),
              const SizedBox(height: 30),
              _buildTileWidget('Profile', 'Edit Profile', 'ic_mail', () {
                Navigator.of(context).pushNamed(
                  changePasswordRoute,
                  arguments: ChangePasswordArgs(action: 'change_profile'),
                );
              }),
              const SizedBox(height: 20),
              _buildTileWidget('Password', 'Change Password', 'ic_lock', () {
                Navigator.of(context).pushNamed(
                  changePasswordRoute,
                  arguments: ChangePasswordArgs(action: 'change_pass'),
                );
              }),
              const SizedBox(height: 20),
              _buildTileWidget(
                  'Notifications', 'Enable Notifications', 'ic_bell', () {
                setState(() {
                  _notificationsEnabled = !_notificationsEnabled;
                });
              }, switchState: _notificationsEnabled),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  _buildTileWidget(String title, String subTitle, String icon, Function onTap,
      {bool? switchState}) {
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
                Text(title, style: TypeStyle.label),
                Text(subTitle, style: TypeStyle.h3),
              ],
            )),
            switchState == null
                ? Transform.flip(
                    flipX: true,
                    child: SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
                  )
                : FlutterSwitch(
                    width: 40.0,
                    height: 20.0,
                    toggleSize: 13.0,
                    value: _notificationsEnabled,
                    borderRadius: 20.0,
                    showOnOff: false,
                    toggleColor: ColorStyle.secondaryTextColor,
                    activeColor: ColorStyle.whiteColor,
                    inactiveColor: ColorStyle.borderColor,
                    onToggle: (val) {
                      setState(() {
                        _notificationsEnabled = !_notificationsEnabled;
                      });
                    }),
          ]),
        ),
      ),
    );
  }
}
