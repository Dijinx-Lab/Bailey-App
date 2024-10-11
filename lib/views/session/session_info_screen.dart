import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/session/response/session_response.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/misc/misc.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/bottom_sheets/session_history/session_history_sheet.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:bailey/widgets/inputs/text_field/m_text_field.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class SessionInfoScreen extends StatefulWidget {
  const SessionInfoScreen({super.key});

  @override
  State<SessionInfoScreen> createState() => _SessionInfoScreenState();
}

class _SessionInfoScreenState extends State<SessionInfoScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  DateTime? dateOfBirth;
  bool isValid = false;

  @override
  void initState() {
    super.initState();

    _firstNameController.addListener(() => _checkValidity());
    _lastNameController.addListener(() => _checkValidity());
    _dateOfBirthController.addListener(() => _checkValidity());
  }

  _checkValidity() {
    isValid = _firstNameController.text != "" &&
        _lastNameController.text != "" &&
        dateOfBirth != null;

    setState(() {});
  }

  _openSessionHistorySheet() async {
    print('tapped');
    bool? res = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18.0),
        ),
      ),
      backgroundColor: ColorStyle.backgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) => const SessionHistorySheet(),
    );
    if (res == true && mounted) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(baseRoute, (route) => false);
    }
  }

  _createSession() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));

      ApiService.addSession(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        dateOfBirth: dateOfBirth!.toIso8601String(),
      ).then((value) {
        SmartDialog.dismiss();
        SessionResponse? apiResponse =
            ApiService.processResponse(value, context) as SessionResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            PrefUtil().currentSession = apiResponse.data?.session;
            Navigator.of(context)
                .pushNamedAndRemoveUntil(baseRoute, (route) => false);
            ToastUtils.showCustomSnackbar(
                context: context,
                contentText: "Session created",
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
                          'New Session',
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
                                  "Please provide the details below, to create a new session. This session will only last till the app is open",
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
                          controller: _firstNameController,
                          label: 'First Name',
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
                          controller: _lastNameController,
                          label: 'Last Name',
                          keyboardType: TextInputType.text,
                          iconWidget: const Icon(
                            Icons.location_history_outlined,
                            color: ColorStyle.whiteColor,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () => _openDatePicker(context),
                          child: AbsorbPointer(
                            absorbing: true,
                            child: MTextField(
                              controller: _dateOfBirthController,
                              label: 'Date of Birth',
                              keyboardType: TextInputType.text,
                              iconWidget: const Icon(
                                Icons.date_range,
                                color: ColorStyle.whiteColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: ColorStyle.borderColor,
                                ),
                              ),
                              Text(
                                '\t\tor open a previous session\t\t',
                                style: TypeStyle.body,
                              ),
                              const Expanded(
                                child: Divider(
                                  color: ColorStyle.borderColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => _openSessionHistorySheet(),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_clock,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'My Previous Sessions',
                                style: TypeStyle.body,
                              ),
                            ],
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
                    'Continue',
                    () {
                      _createSession();
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

  Future<void> _openDatePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorStyle.secondaryTextColor,
              onPrimary: Colors.white,
              onSurface: Colors.white,
              surface: ColorStyle.backgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd MMM, yyyy').format(pickedDate);

      setState(() {
        dateOfBirth = pickedDate;
        _dateOfBirthController.text = formattedDate;
      });
    }
  }
}
