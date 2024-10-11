import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/user/response/user_response.dart';
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

class CompanyDetailScreen extends StatefulWidget {
  const CompanyDetailScreen({super.key});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => _checkValidity());
    _locationController.addListener(() => _checkValidity());
  }

  _checkValidity() {
    isValid = _nameController.text != "" && _locationController.text != "";

    setState(() {});
  }

  _editProfile() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));

      ApiService.editProfile(
        email: null,
        name: null,
        fcmToken: null,
        companyName: _nameController.text.trim(),
        companyLocation: _locationController.text.trim(),
      ).then((value) {
        SmartDialog.dismiss();
        UserResponse? apiResponse =
            ApiService.processResponse(value, context) as UserResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            PrefUtil().currentUser = apiResponse.data?.user;
            Navigator.of(context)
                .pushNamedAndRemoveUntil(newSessionRoute, (route) => false);
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
                    Expanded(
                      child: Center(
                        child: Text(
                          'Company Details',
                          style: TypeStyle.h2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                    width: double.maxFinite,
                    // margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorStyle.borderColor),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/ic_info.svg',
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
                              Text("Just missing a few details",
                                  style: TypeStyle.h3),
                              Text(
                                  "Please provide your company details below, to complete the registration process",
                                  style: TypeStyle.body),
                            ],
                          )),
                        ],
                      ),
                    )),
                const SizedBox(
                  height: 40,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        MTextField(
                          controller: _nameController,
                          label: 'Company Name',
                          keyboardType: TextInputType.text,
                          iconWidget: const Icon(
                            Icons.location_history_outlined,
                            color: ColorStyle.whiteColor,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        MTextField(
                          controller: _locationController,
                          label: 'Company Location',
                          keyboardType: TextInputType.text,
                          iconWidget: const Icon(
                            Icons.location_on_outlined,
                            color: ColorStyle.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MRoundedButton(
                    'Save',
                    () {
                      _editProfile();
                    },
                    isEnabled: isValid,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
