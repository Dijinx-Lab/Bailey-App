import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/user/response/user_response.dart';
import 'package:bailey/models/args/change_password/change_password_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/misc/misc.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/inputs/text_field/m_text_field.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

class ChangePasswordScreen extends StatefulWidget {
  final ChangePasswordArgs arguments;
  const ChangePasswordScreen({super.key, required this.arguments});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _showPassword = false;
  bool isValid = false;

  @override
  void initState() {
    _nameController.text = PrefUtil().currentUser?.contactName ?? "";
    _emailController.text = PrefUtil().currentUser?.email ?? "";
    super.initState();

    _nameController.addListener(() => _checkValidity());
    _emailController.addListener(() => _checkValidity());
    _oldPasswordController.addListener(() => _checkValidity());
    _passwordController.addListener(() => _checkValidity());
    _confirmPasswordController.addListener(() => _checkValidity());
  }

  @override
  dispose() {
    super.dispose();
  }

  _checkValidity() {
    bool isNameValid =
        _nameController.text != PrefUtil().currentUser?.companyName;
    bool isEmailValid = _emailController.text != PrefUtil().currentUser?.email;
    bool isPwdValid = _oldPasswordController.text != "" &&
        _passwordController.text != "" &&
        _confirmPasswordController.text != "";
    isValid = widget.arguments.action == 'change_profile'
        ? (isNameValid || isEmailValid)
        : widget.arguments.action == 'forgot_pass'
            ? _passwordController.text != "" &&
                _confirmPasswordController.text != ""
            : isPwdValid;
    setState(() {});
  }

  _editProfile() async {
    try {
      String? email = _emailController.text == PrefUtil().currentUser?.email
          ? null
          : _emailController.text;
      String name = _nameController.text;
      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));

      ApiService.editProfile(
              email: email,
              name: name,
              fcmToken: null,
              companyName: null,
              companyLocation: null)
          .then((value) {
        SmartDialog.dismiss();
        UserResponse? apiResponse =
            ApiService.processResponse(value, context) as UserResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            PrefUtil().currentUser = apiResponse.data?.user;

            _checkValidity();
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: "Profile updated",
                type: "success");
          } else {
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: apiResponse.message ?? "",
                type: "fail");
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _changePassword() async {
    try {
      String oldPassword = _oldPasswordController.text;
      String newPassword = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;

      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));

      ApiService.changePassword(
        oldPass: oldPassword,
        newPass: newPassword,
        confirmPass: confirmPassword,
      ).then((value) {
        SmartDialog.dismiss();
        GenericResponse? apiResponse =
            ApiService.processResponse(value, context) as GenericResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            _checkValidity();
            _oldPasswordController.text = "";
            _passwordController.text = "";
            _confirmPasswordController.text = "";
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: "Password Updated",
                type: "success");
          } else {
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: apiResponse.message ?? "",
                type: "fail");
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _forgotPassword() async {
    try {
      String newPassword = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;

      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));

      ApiService.forgotPassword(
        email: widget.arguments.email!,
        newPass: newPassword,
        confirmPass: confirmPassword,
      ).then((value) {
        SmartDialog.dismiss();
        GenericResponse? apiResponse =
            ApiService.processResponse(value, context) as GenericResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            Navigator.of(context)
                .popUntil((e) => e.settings.name == signinRoute);
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: "Password Updated",
                type: "success");
          } else {
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: apiResponse.message ?? "",
                type: "fail");
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unfocusScreen(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        Navigator.of(context).pop();
                      },
                      visualDensity: VisualDensity.compact,
                      icon:
                          SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.arguments.action == 'change_profile'
                              ? 'Edit Profile'
                              : 'Change Password',
                          style: TypeStyle.h2,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    )
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: Durations.medium1,
                          width: MediaQuery.of(context).viewInsets.bottom > 0
                              ? 50
                              : (MediaQuery.of(context).size.width / 2),
                          child: Image.asset(
                            widget.arguments.action == 'change_profile'
                                ? 'assets/images/email_image.png'
                                : 'assets/images/changepass_image.png',
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          widget.arguments.action == 'change_profile'
                              ? 'Edit your profile'
                              : 'Change your password',
                          style: TypeStyle.h1,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: widget.arguments.action != 'change_profile',
                          child: Text(
                            'Please enter your new passowrd to reset it',
                            style: TypeStyle.body,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        widget.arguments.action == 'change_profile'
                            ? _buildProfileFields()
                            : _buildPasswordFields()
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MRoundedButton(
                    widget.arguments.action == 'change_profile'
                        ? 'Save'
                        : 'Change password',
                    () {
                      if (widget.arguments.action == 'change_profile') {
                        _editProfile();
                      } else if (widget.arguments.action == 'forgot_pass') {
                        _forgotPassword();
                      } else {
                        _changePassword();
                      }
                    },
                    isEnabled: isValid,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildPasswordFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.arguments.action == 'change_pass',
          child: MTextField(
            controller: _oldPasswordController,
            obscuretext: !_showPassword,
            label: 'Current Password',
            keyboardType: TextInputType.text,
            icon: 'ic_lock',
            trailing: IconButton(
              onPressed: () {
                setState(() => _showPassword = !_showPassword);
              },
              icon: SvgPicture.asset(
                'assets/icons/ic_eye.svg',
                color: _showPassword ? ColorStyle.whiteColor : null,
              ),
            ),
          ),
        ),
        Visibility(
            visible: widget.arguments.action == 'change_pass',
            child: const SizedBox(height: 20)),
        MTextField(
          controller: _passwordController,
          obscuretext: !_showPassword,
          label: 'New Password',
          keyboardType: TextInputType.text,
          icon: 'ic_lock',
          trailing: IconButton(
            onPressed: () {
              setState(() => _showPassword = !_showPassword);
            },
            icon: SvgPicture.asset(
              'assets/icons/ic_eye.svg',
              color: _showPassword ? ColorStyle.whiteColor : null,
            ),
          ),
        ),
        const SizedBox(height: 20),
        MTextField(
          controller: _confirmPasswordController,
          obscuretext: !_showPassword,
          label: 'Repeat Password',
          keyboardType: TextInputType.text,
          icon: 'ic_lock_alt',
          trailing: IconButton(
            onPressed: () {
              setState(() => _showPassword = !_showPassword);
            },
            icon: SvgPicture.asset(
              'assets/icons/ic_eye.svg',
              color: _showPassword ? ColorStyle.whiteColor : null,
            ),
          ),
        ),
      ],
    );
  }

  _buildProfileFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MTextField(
          controller: _nameController,
          label: 'Name',
          keyboardType: TextInputType.text,
          icon: 'ic_mail',
        ),
        const SizedBox(height: 20),
        Visibility(
          visible: PrefUtil().currentUser?.googleId == null &&
              PrefUtil().currentUser?.appleId == null,
          child: MTextField(
            controller: _emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            icon: 'ic_mail',
          ),
        ),
      ],
    );
  }
}
