import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/models/api/session/list_response/session_list_response.dart';
import 'package:bailey/models/api/session/session/session.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SessionHistorySheet extends StatefulWidget {
  const SessionHistorySheet({super.key});

  @override
  State<SessionHistorySheet> createState() => _SessionHistorySheetState();
}

class _SessionHistorySheetState extends State<SessionHistorySheet> {
  bool isLoading = true;
  List<Session> sessions = [];

  @override
  initState() {
    _getSessions();
    super.initState();
  }

  _getSessions() async {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      ApiService.listSessions().then((value) {
        setState(() {
          isLoading = false;
        });
        SessionListResponse? apiResponse =
            ApiService.processResponse(value, context) as SessionListResponse?;
        if (apiResponse != null) {
          if (apiResponse.success == true) {
            sessions = apiResponse.data?.sessions ?? [];
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * .6,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
          color: ColorStyle.backgroundColor,
          borderRadius: BorderRadius.circular(18)),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Sessions',
                style: TypeStyle.h1,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? LoadingUtil.buildAdaptiveLoader(
                      color: ColorStyle.whiteColor,
                    )
                  : sessions.isEmpty
                      ? Center(
                          child: Text(
                            'No previous sessions',
                            style: TypeStyle.body,
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: List.generate(
                              sessions.length,
                              (index) => InkWell(
                                onTap: () {
                                  PrefUtil().currentSession = sessions[index];
                                  Navigator.of(context).pop(true);
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
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .location_history_outlined,
                                                  size: 15,
                                                  color: ColorStyle.whiteColor,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "${sessions[index].firstName} ${sessions[index].lastName}",
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
                                                  color: ColorStyle
                                                      .secondaryTextColor,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  DateFormat('dd MMM, yyyy')
                                                      .format(sessions[index]
                                                          .dateOfBirth!),
                                                  style: TypeStyle.body,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
            )
          ],
        ),
      ),
    );
  }
}
