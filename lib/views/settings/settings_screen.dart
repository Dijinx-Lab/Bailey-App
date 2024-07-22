import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/args/change_password/change_password_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/auth/auth_util.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _signOut() async {
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    if (PrefUtil().currentUser?.googleId != null ||
        PrefUtil().currentUser?.googleId != '') {
      await AuthUtil.signOut();
    }

    ApiService.signOut().then((value) {
      SmartDialog.dismiss();
      GenericResponse? apiResponse =
          ApiService.processResponse(value, context) as GenericResponse?;
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          PrefUtil().isLoggedIn = false;
          PrefUtil().rememberMe = false;
          PrefUtil().currentUser = null;

          Navigator.of(context)
              .pushNamedAndRemoveUntil(signinRoute, (route) => false);
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    });
  }

  _deleteAccount() async {
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    if (PrefUtil().currentUser?.googleId != null ||
        PrefUtil().currentUser?.googleId != '') {
      await AuthUtil.deleteAccount();
    }
    ApiService.deleteAccount().then((value) {
      SmartDialog.dismiss();
      GenericResponse? apiResponse =
          ApiService.processResponse(value, context) as GenericResponse?;
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          PrefUtil().isLoggedIn = false;
          PrefUtil().rememberMe = false;
          PrefUtil().currentUser = null;

          Navigator.of(context)
              .pushNamedAndRemoveUntil(signinRoute, (route) => false);
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    });
  }

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
                  PrefUtil().currentUser?.notificationsEnabled =
                      !(PrefUtil().currentUser?.notificationsEnabled ?? false);
                });
              },
                  switchState:
                      (PrefUtil().currentUser?.notificationsEnabled ?? false)),
              const SizedBox(height: 20),
              _buildTileWidget(
                  'Exit', 'Log Out ', 'ic_logout', () => _signOut()),
              const SizedBox(height: 20),
              _buildTileWidget('Delete', 'Delete Account ', 'ic_remove',
                  () async {
                OkCancelResult result = await showOkCancelAlertDialog(
                  context: context,
                  title: "Confirm",
                  message:
                      "This action is irreversible and all your data will be permanently deleted including\n\n• Your photos\n• Your handwritings\n• Your fingerprints",
                  isDestructiveAction: true,
                  okLabel: 'Delete',
                );
                if (result == OkCancelResult.ok) {
                  _deleteAccount();
                } else {
                  return;
                }
              }),
              const SizedBox(height: 60),
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
          border: Border.all(
            color: (icon == 'ic_remove')
                ? ColorStyle.red100Color.withOpacity(0.4)
                : ColorStyle.borderColor,
          ),
        ),
        child: IntrinsicHeight(
          child: Row(children: [
            SvgPicture.asset(
              'assets/icons/$icon.svg',
              color: (icon == 'ic_remove')
                  ? ColorStyle.red100Color
                  : ColorStyle.whiteColor,
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
                  Text(
                    subTitle,
                    style: TypeStyle.h3.copyWith(
                      color: (icon == 'ic_remove')
                          ? ColorStyle.red100Color
                          : ColorStyle.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            (icon == 'ic_logout' || icon == 'ic_remove')
                ? Container()
                : switchState == null
                    ? Transform.flip(
                        flipX: true,
                        child: SvgPicture.asset(
                            'assets/icons/ic_chevron_back.svg'),
                      )
                    : FlutterSwitch(
                        width: 40.0,
                        height: 20.0,
                        toggleSize: 13.0,
                        value: PrefUtil().currentUser?.notificationsEnabled ??
                            false,
                        borderRadius: 20.0,
                        showOnOff: false,
                        toggleColor: ColorStyle.secondaryTextColor,
                        activeColor: ColorStyle.whiteColor,
                        inactiveColor: ColorStyle.borderColor,
                        onToggle: (val) {
                          setState(
                            () {
                              PrefUtil().currentUser?.notificationsEnabled =
                                  !(PrefUtil()
                                          .currentUser
                                          ?.notificationsEnabled ??
                                      false);
                            },
                          );
                        },
                      ),
          ]),
        ),
      ),
    );
  }
}
