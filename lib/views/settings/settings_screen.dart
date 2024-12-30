import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/link/link_response.dart';
import 'package:bailey/models/api/user/response/user_response.dart';
import 'package:bailey/models/args/change_password/change_password_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/auth/auth_util.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late final bool canPop;

  @override
  initState() {
    canPop = Navigator.of(context).canPop();
    super.initState();
  }

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

  Future<String?> _getFcmToken() async {
    try {
      await _firebaseMessaging.requestPermission();
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  _editProfile(bool pref) async {
    try {
      String fcmToken = 'x';
      if (pref) {
        fcmToken = await _getFcmToken() ?? "x";
      }
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
      ApiService.editProfile(
        email: null,
        name: null,
        fcmToken: fcmToken,
        companyName: null,
        companyLocation: null,
      ).then((value) {
        SmartDialog.dismiss();
        UserResponse? apiResponse =
            ApiService.processResponse(value, context) as UserResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            PrefUtil().currentUser = apiResponse.data?.user;
            setState(() {});
          } else {
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: apiResponse.message ?? "",
                type: "fail");
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _deleteSession(String id) async {
    try {
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
      ApiService.deleteSession(id: id).then((value) {
        SmartDialog.dismiss();
        GenericResponse? apiResponse =
            ApiService.processResponse(value, context) as GenericResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            PrefUtil().currentSession = null;
            Navigator.of(context)
                .pushNamedAndRemoveUntil(newSessionRoute, (e) => false);
          } else {
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: apiResponse.message ?? "",
                type: "fail");
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _getTermsLink() async {
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    ApiService.getTermsLink().then((value) async {
      SmartDialog.dismiss();
      LinkResponse? apiResponse =
          ApiService.processResponse(value, context) as LinkResponse?;
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          String? link = apiResponse.data?.link;
          if (link != null && await canLaunch(link)) {
            await launch(link); // Open link in browser
          } else {
            if (mounted) {
              ToastUtils.showCustomSnackbar(
                context: context,
                contentText: "Unable to open the link",
                type: "fail",
              );
            }
          }
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    });
  }

  _getMyData() async {
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    ApiService.userCompleteDetail().then((value) async {
      SmartDialog.dismiss();
      Map<String, dynamic>? apiResponse =
          ApiService.processResponse(value, context) as Map<String, dynamic>?;
      if (apiResponse != null) {
        Directory tempDir = await getTemporaryDirectory();
        String filePath = '${tempDir.path}/my-data.json';
        String formattedJson =
            const JsonEncoder.withIndent('  ').convert(apiResponse);
        File file = File(filePath);
        await file.writeAsString(formattedJson);
        await Share.shareFiles([filePath]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: canPop,
        bottom: canPop,
        child: Padding(
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
                      canPop
                          ? Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  visualDensity: VisualDensity.compact,
                                  icon: SvgPicture.asset(
                                      'assets/icons/ic_chevron_back.svg'),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Settings',
                                      style: TypeStyle.h2,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 40,
                                )
                              ],
                            )
                          : Center(
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
                canPop
                    ? Container()
                    : GestureDetector(
                        onTapDown: (TapDownDetails details) {
                          _showSessionActions(context, details.globalPosition);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                              color: ColorStyle.blackColor,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorStyle.whiteColor.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ]),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_history_outlined,
                                          size: 15,
                                          color: ColorStyle.whiteColor,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${PrefUtil().currentSession?.firstName} ${PrefUtil().currentSession?.lastName}",
                                          style: TypeStyle.h3,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.date_range,
                                          size: 15,
                                          color: ColorStyle.secondaryTextColor,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          DateFormat('dd MMM, yyyy').format(
                                              PrefUtil()
                                                  .currentSession!
                                                  .dateOfBirth!),
                                          style: TypeStyle.body,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.more_vert,
                              )
                            ],
                          ),
                        ),
                      ),
                const SizedBox(height: 10),
                _buildTileWidget('Profile', 'Edit Profile', 'ic_mail', () {
                  Navigator.of(context).pushNamed(
                    changePasswordRoute,
                    arguments: ChangePasswordArgs(action: 'change_profile'),
                  );
                }),
                Visibility(
                  visible: PrefUtil().currentUser?.googleId == null &&
                      PrefUtil().currentUser?.appleId == null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildTileWidget('Password', 'Change Password', 'ic_lock',
                          () {
                        Navigator.of(context).pushNamed(
                          changePasswordRoute,
                          arguments: ChangePasswordArgs(action: 'change_pass'),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTileWidget(
                    'Notifications', 'Enable Notifications', 'ic_bell', () {
                  _editProfile(
                      !(PrefUtil().currentUser?.notificationsEnabled ?? false));
                },
                    switchState:
                        (PrefUtil().currentUser?.notificationsEnabled ??
                            false)),
                const SizedBox(height: 20),
                _buildTileWidget('Legal', 'Terms and Conditions ', 'ic_logout',
                    () => _getTermsLink()),
                const SizedBox(height: 20),
                _buildTileWidget('Data', 'Request My Data', 'ic_download',
                    () => _getMyData()),
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
      ),
    );
  }

  void _showSessionActions(BuildContext context, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, 0),
      color: Colors.grey[900],
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: Text(
            "Close Session",
            style: TypeStyle.h3,
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Text(
            "Delete Session",
            style: TypeStyle.h3.copyWith(color: ColorStyle.red100Color),
          ),
        ),
      ],
    ).then((value) async {
      if (value != null) {
        if (value == 1) {
          PrefUtil().currentSession = null;
          Navigator.of(context)
              .pushNamedAndRemoveUntil(newSessionRoute, (e) => false);
        } else if (value == 2) {
          OkCancelResult result = await showOkCancelAlertDialog(
            context: context,
            title: "Confirm",
            message:
                "This action is irreversible and all your data for ONLY THIS SESSION will be permanently deleted including\n\n• Your photos\n• Your handwritings\n• Your fingerprints",
            isDestructiveAction: true,
            okLabel: 'Delete',
          );
          if (result == OkCancelResult.ok) {
            _deleteSession(PrefUtil().currentSession!.id!);
          } else {
            return;
          }
        }
      }
    });
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
            Transform.flip(
              flipX: title == "Legal",
              child: SvgPicture.asset(
                'assets/icons/$icon.svg',
                color: (icon == 'ic_remove')
                    ? ColorStyle.red100Color
                    : ColorStyle.whiteColor,
                height: 25,
              ),
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
            (icon == 'ic_logout' ||
                    icon == 'ic_remove' ||
                    icon == 'ic_download')
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
                              _editProfile(!(PrefUtil()
                                      .currentUser
                                      ?.notificationsEnabled ??
                                  false));
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
