import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/args/code/code_args.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/misc/misc.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/inputs/text_field/m_text_field.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:flutter_svg/svg.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool valid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => _checkValidity());
  }

  _checkValidity() {
    valid = _emailController.text != "";
    setState(() {});
  }

  _sendVerification() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));

      ApiService.sendVerificationCode(
        email: _emailController.text.trim(),
        type: "password",
      ).then((value) {
        SmartDialog.dismiss();
        GenericResponse? apiResponse =
            ApiService.processResponse(value, context) as GenericResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            Navigator.of(context).pushNamed(
              verifyCodeRoute,
              arguments: CodeArgs(
                email: _emailController.text.trim(),
                code: null,
                forPassword: true,
              ),
            );
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
                          'Forgot Password',
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
                    'assets/images/forgotpass_image.png',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Forgot Password',
                  style: TypeStyle.h1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'No worries, we will send you reset code',
                  style: TypeStyle.body,
                ),
                const SizedBox(
                  height: 20,
                ),
                MTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: 'ic_mail',
                  keyboardType: TextInputType.emailAddress,
                ),
                const Spacer(),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MRoundedButton(
                    'Continue',
                    () => _sendVerification(),
                    isEnabled: valid,
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
