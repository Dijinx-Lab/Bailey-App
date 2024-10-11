import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/api/entities/upload/upload_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/handwriting/handwriting/handwriting.dart';
import 'package:bailey/models/api/handwriting/list_response/handwriting_list_response.dart';
import 'package:bailey/models/api/handwriting/response/handwriting_response.dart';
import 'package:bailey/models/api/session/session/session.dart';
import 'package:bailey/models/api/upload/response/upload_response.dart';
import 'package:bailey/models/args/preview_image/preview_image_args.dart';
import 'package:bailey/models/events/refresh_home/refresh_home_event.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/picker/picker_util.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/views/base/base_screen.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:bailey/widgets/m_picture/m_picture.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({super.key});

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  List<Handwriting> _writings = [];
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    _getWritings();
  }

  _getWritings() {
    ApiService.listWriting().then((value) async {
      HandwritingListResponse? apiResponse =
          ApiService.processResponse(value, context)
              as HandwritingListResponse?;
      setState(() => _isLoading = false);
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          setState(() {
            _writings = apiResponse.data?.handwritings ?? [];
          });
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    });
  }

  _makeUpload(String path) async {
    bool sizeCheck = await PickerUtil.isFileSmallerThan(path, 10);
    if (!sizeCheck && mounted) {
      ToastUtils.showCustomSnackbar(
          context: context,
          contentText:
              "Media too large, please max sure your media is 10MBs or less",
          type: "fail");
      return;
    }
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 3));
    final paths = UploadService.getUploadFilePath(
      uploadType: UploadType.handwriting,
    );
    ApiService.upload(
      fileName: paths["filename"]!,
      folder: paths["folder"]!,
      filePath: path,
    ).then((value) async {
      UploadResponse? apiResponse =
          ApiService.processResponse(value, context) as UploadResponse?;

      if (apiResponse != null) {
        if (apiResponse.success == true) {
          String uploadId = apiResponse.data?.upload?.id ?? "";
          if (uploadId != "") {
            _addWriting(uploadId);
          }
        } else {
          SmartDialog.dismiss();
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      } else {
        SmartDialog.dismiss();
      }
    });
  }

  _addWriting(String uploadId) async {
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    ApiService.addWriting(
      uploadId: uploadId,
    ).then((value) async {
      HandwritingResponse? apiResponse =
          ApiService.processResponse(value, context) as HandwritingResponse?;
      SmartDialog.dismiss();

      if (apiResponse != null) {
        if (apiResponse.success == true) {
          _writings.add(apiResponse.data!.handwriting!);
          if (_writings.isNotEmpty) {
            Session? session = PrefUtil().currentSession;
            session?.handwritingsAdded = true;
            PrefUtil().currentSession = session;

            BaseScreen.eventBus.fire(RefreshHomeEvent());
          }
          setState(() {});
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    });
  }

  _deleteWriting(String writingId) async {
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    ApiService.deleteWriting(
      writingId: writingId,
    ).then((value) async {
      GenericResponse? apiResponse =
          ApiService.processResponse(value, context) as GenericResponse?;
      SmartDialog.dismiss();
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          _writings.removeWhere((element) => element.id == writingId);
          if (_writings.isEmpty) {
            Session? session = PrefUtil().currentSession;
            session?.handwritingsAdded = false;
            PrefUtil().currentSession = session;

            BaseScreen.eventBus.fire(RefreshHomeEvent());
          }
          setState(() {});
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      }
    });
  }

  _openPreview(Handwriting writing) {
    int index = _writings.indexWhere((e) => e.id == writing.id);
    List<String> paths =
        _writings.map((e) => e.upload?.accessUrl ?? "").toList();
    Navigator.of(context).pushNamed(
      previewImageRoute,
      arguments: PreviewImageArgs(
        initialIndex: index == -1 ? 0 : index,
        titles: [],
        imageUrls: paths,
      ),
    );
  }

  _deleteBySessionId() async {
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    ApiService.deleteWritingsBySession(
      sessionId: PrefUtil().currentSession!.id!,
    ).then((value) async {
      GenericResponse? apiResponse =
          ApiService.processResponse(value, context) as GenericResponse?;
      SmartDialog.dismiss();
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          _writings.clear();
          if (_writings.isEmpty) {
            Session? session = PrefUtil().currentSession;
            session?.handwritingsAdded = false;
            PrefUtil().currentSession = session;
            BaseScreen.eventBus.fire(RefreshHomeEvent());
          }
          setState(() {});
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 10),
        child: _isLoading
            ? null
            : FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  bool granted = false;
                  PermissionStatus permission = await Permission.camera.status;

                  if (permission == PermissionStatus.denied ||
                      permission == PermissionStatus.permanentlyDenied) {
                    permission = await Permission.camera.request();

                    if (permission != PermissionStatus.denied &&
                        permission != PermissionStatus.permanentlyDenied) {
                      granted = true;
                    }
                  } else {
                    granted = true;
                  }
                  if (granted) {
                    List<String>? imagePaths =
                        await CunningDocumentScanner.getPictures(
                            noOfPages: 1, isGalleryImportAllowed: true);
                    if (imagePaths != null && imagePaths.isNotEmpty) {
                      _makeUpload(imagePaths.first);
                    }
                  } else {
                    if (!mounted) return;
                    ToastUtils.showCustomSnackbar(
                        context: context,
                        contentText:
                            'Please grant this app camera permissions from your settings',
                        type: 'error');
                  }
                },
                shape: const CircleBorder(),
                elevation: 5,
                child: const Icon(
                  Icons.add,
                  color: ColorStyle.blackColor,
                ),
              ),
      ),
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
                    icon: SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Hand Writings',
                        style: TypeStyle.h2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      var result = await showModalActionSheet(
                        context: context,
                        title: "Confirm",
                        message:
                            "This action is irreversible and will delete all your handwritings' data for this session. Do you wish to continue or create a new session instead?",
                        actions: [
                          const SheetAction(
                            icon: Icons.lock_clock,
                            label: 'New Session',
                            key: 'new',
                          ),
                          const SheetAction(
                              icon: Icons.delete,
                              label: "Delete Session's Handwritings",
                              key: 'delete',
                              isDestructiveAction: true),
                          const SheetAction(
                              icon: Icons.close,
                              label: 'Cancel',
                              key: 'cancel',
                              isDefaultAction: true),
                        ],
                      );
                      if (result == "delete") {
                        _deleteBySessionId();
                      } else if (result == "new" && context.mounted) {
                        PrefUtil().currentSession = null;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            newSessionRoute, (e) => false);
                      }
                    },
                    visualDensity: VisualDensity.compact,
                    icon: SvgPicture.asset(
                      'assets/icons/ic_remove.svg',
                      color: ColorStyle.red100Color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedContainer(
                  duration: Durations.medium1,
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: _isLoading
                        ? null
                        : Border.all(color: ColorStyle.borderColor),
                  ),
                  child: _isLoading
                      ? LoadingUtil.buildAdaptiveLoader()
                      : _writings.isEmpty
                          ? Center(
                              child: Text(
                                'Handwritings in your account appear here.\nClick the  +  button to add some',
                                textAlign: TextAlign.center,
                                style: TypeStyle.body,
                              ),
                            )
                          : SingleChildScrollView(
                              child: MasonryView(
                                listOfItem:
                                    List.generate(_writings.length, (index) {
                                  return _writings[index];
                                }),
                                numberOfColumn: 2,
                                itemRadius: 6,
                                itemPadding: 4,
                                itemBuilder: (val) => Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _openPreview(val),
                                      child: MPicture(
                                        url: val.upload?.accessUrl ?? "",
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: IconButton.filled(
                                          onPressed: () =>
                                              _deleteWriting(val.id),
                                          visualDensity: VisualDensity.compact,
                                          icon: SvgPicture.asset(
                                            'assets/icons/ic_remove.svg',
                                            width: 15,
                                            height: 15,
                                          ),
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                ColorStyle.whiteColor,
                                            shadowColor:
                                                Colors.black.withOpacity(0.5),
                                            elevation: 4,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
