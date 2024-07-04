import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/misc.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/inputs/text_field/m_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
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
                          'Change Password',
                          style: TypeStyle.h2,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    )
                  ],
                ),
                const Spacer(),
                AnimatedContainer(
                  duration: Durations.medium1,
                  width: MediaQuery.of(context).viewInsets.bottom > 0
                      ? 50
                      : (MediaQuery.of(context).size.width / 2),
                  child: Image.asset(
                    'assets/images/changepass_image.png',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Change your password',
                  style: TypeStyle.h1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Please enter your new passowrd to reset it',
                  style: TypeStyle.body,
                ),
                const SizedBox(
                  height: 20,
                ),
                MTextField(
                  controller: _passwordController,
                  obscuretext: !_showPassword,
                  label: 'Password',
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
                const Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MRoundedButton(
                    'Change password',
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
}
