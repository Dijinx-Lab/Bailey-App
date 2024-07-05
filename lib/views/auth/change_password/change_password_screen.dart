import 'package:bailey/models/args/change_password/change_password_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/misc/misc.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/inputs/text_field/m_text_field.dart';
import 'package:flutter/material.dart';
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
  @override
  void initState() {
    super.initState();
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
                      onPressed: () => Navigator.of(context).pop(),
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
                    () => (),
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
        MTextField(
          controller: _emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          icon: 'ic_mail',
        ),
      ],
    );
  }
}
