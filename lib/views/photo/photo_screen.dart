import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/models/api/generic/generic_response.dart';
import 'package:bailey/models/api/photo/list_response/photo_list_response.dart';
import 'package:bailey/models/api/photo/photo/photo.dart';
import 'package:bailey/models/api/photo/response/photo_response.dart';
import 'package:bailey/models/api/upload/response/upload_response.dart';
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
    ApiService.upload(
      folder: 'photos',
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
          if (_photos.length == 1) {
            PrefUtil().currentUser?.photosAdded = true;
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
            PrefUtil().currentUser?.photosAdded = false;
            print(PrefUtil().currentUser?.photosAdded);
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
                  const SizedBox(width: 40),
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
                                    MPicture(
                                      url: val.upload?.accessUrl ?? "",
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
