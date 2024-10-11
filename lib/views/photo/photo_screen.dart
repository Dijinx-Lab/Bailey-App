import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/api/entities/upload/upload_service.dart';
import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/photo/list_response/photo_list_response.dart';
import 'package:bailey/models/api/photo/photo/photo.dart';
import 'package:bailey/models/api/photo/response/photo_response.dart';
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
import 'package:bailey/widgets/bottom_sheets/media_source/media_source_sheet.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:bailey/widgets/m_picture/m_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  List<Photo> _photos = [];
  bool _isLoading = true;

  @override
  initState() {
    super.initState();
    _getPhotos();
  }

  _getPhotos() {
    ApiService.listPhotos().then((value) async {
      PhotoListResponse? apiResponse =
          ApiService.processResponse(value, context) as PhotoListResponse?;
      setState(() => _isLoading = false);
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          setState(() {
            _photos = apiResponse.data?.photos ?? [];
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
      uploadType: UploadType.photo,
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
            _addPhoto(uploadId);
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

  _addPhoto(String uploadId) async {
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    ApiService.addPhoto(
      uploadId: uploadId,
    ).then((value) async {
      PhotoResponse? apiResponse =
          ApiService.processResponse(value, context) as PhotoResponse?;
      SmartDialog.dismiss();

      if (apiResponse != null) {
        if (apiResponse.success == true) {
          _photos.add(apiResponse.data!.photo!);
          if (_photos.isNotEmpty) {
            Session? session = PrefUtil().currentSession;
            session?.photosAdded = true;
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

  _deletePhoto(String photoId) async {
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    ApiService.deletePhoto(
      photoId: photoId,
    ).then((value) async {
      GenericResponse? apiResponse =
          ApiService.processResponse(value, context) as GenericResponse?;
      SmartDialog.dismiss();
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          _photos.removeWhere((element) => element.id == photoId);
          if (_photos.isEmpty) {
            Session? session = PrefUtil().currentSession;
            session?.photosAdded = false;
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

  _deleteBySessionId() async {
    SmartDialog.showLoading(builder: (_) => const CustomLoading(type: 1));
    ApiService.deletePhotosBySession(
      sessionId: PrefUtil().currentSession!.id!,
    ).then((value) async {
      GenericResponse? apiResponse =
          ApiService.processResponse(value, context) as GenericResponse?;
      SmartDialog.dismiss();
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          _photos.clear();
          if (_photos.isEmpty) {
            Session? session = PrefUtil().currentSession;
            session?.photosAdded = false;
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

  Future<String?> _openSourceSheet() async {
    String? source = await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18.0),
        ),
      ),
      backgroundColor: ColorStyle.backgroundColor,
      isScrollControlled: true,
      builder: (BuildContext context) => const MediaSourceSheet(),
    );
    return source;
  }

  _onFabTap() async {
    String? path;
    String? source = await _openSourceSheet();
    if (source != null) {
      if (source == 'gallery' && mounted) {
        path = await PickerUtil.pickImage();
      } else {
        path = await PickerUtil.captureImage();
      }
    }
    if (path != null) {
      _makeUpload(path);
    }
  }

  _openPreview(Photo photo) {
    int index = _photos.indexWhere((e) => e.id == photo.id);
    List<String> paths = _photos.map((e) => e.upload?.accessUrl ?? "").toList();
    Navigator.of(context).pushNamed(
      previewImageRoute,
      arguments: PreviewImageArgs(
        initialIndex: index == -1 ? 0 : index,
        titles: [],
        imageUrls: paths,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isLoading
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10),
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () => _onFabTap(),
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
                        'Photos',
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
                            "This action is irreversible and will delete all your photos' data for this session. Do you wish to continue or create a new session instead?",
                        actions: [
                          const SheetAction(
                            icon: Icons.lock_clock,
                            label: 'New Session',
                            key: 'new',
                          ),
                          const SheetAction(
                              icon: Icons.delete,
                              label: "Delete Session's Photos",
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
                      : _photos.isEmpty
                          ? Center(
                              child: Text(
                                'Photos in your account appear here.\nClick the  +  button to add some',
                                textAlign: TextAlign.center,
                                style: TypeStyle.body,
                              ),
                            )
                          : SingleChildScrollView(
                              child: MasonryView(
                                listOfItem:
                                    List.generate(_photos.length, (index) {
                                  return _photos[index];
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
                                          onPressed: () => _deletePhoto(val.id),
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
