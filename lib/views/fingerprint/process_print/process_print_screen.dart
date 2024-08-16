import 'dart:io';
import 'dart:typed_data';

import 'package:bailey/api/delegate/api_service.dart';
import 'package:bailey/models/api/fingerprint/processing_response/fingerprint_processing_response.dart';
import 'package:bailey/models/args/process_print/process_print_args.dart';
import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/picker/picker_util.dart';
import 'package:bailey/utility/toast/toast_utils.dart';
import 'package:bailey/widgets/bottom_sheets/media_source/media_source_sheet.dart';
import 'package:bailey/widgets/loading/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:local_rembg/local_rembg.dart';
import 'package:convert/convert.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ProcessPrintScreen extends StatefulWidget {
  final ProcessPrintArgs arguments;
  const ProcessPrintScreen({super.key, required this.arguments});

  @override
  State<ProcessPrintScreen> createState() => _ProcessPrintScreenState();
}

class _ProcessPrintScreenState extends State<ProcessPrintScreen> {
  late String imagePath;
  Uint8List? imageBytes;
  bool _isLoadingBgRemoval = false;
  bool _isLoadingPythonEnhance = false;

  @override
  initState() {
    imagePath = widget.arguments.filePath;
    super.initState();
    Future.delayed(Durations.long1).then((val) => _removeImageBg());
  }

  _removeImageBg() async {
    try {
      setState(() {
        _isLoadingBgRemoval = true;
      });
      LocalRembgResultModel localRembgResultModel =
          await LocalRembg.removeBackground(
        imagePath: imagePath,
      );
      if (localRembgResultModel.status == 1) {
        imageBytes = Uint8List.fromList(localRembgResultModel.imageBytes!);

        final file = File(imagePath);

        await file.writeAsBytes(imageBytes!);
      } else {
        // ToastUtils.showCustomSnackbar(
        //     context: context,
        //     contentText: localRembgResultModel.errorMessage ?? "",
        //     type: "fail");
      }
    } catch (e) {
      // ToastUtils.showCustomSnackbar(
      //     context: context, contentText: e.toString(), type: "fail");
      print(e);
    }
    setState(() {
      _isLoadingBgRemoval = false;
    });
    await Future.delayed(Durations.long1);
    _processFingerprint();
  }

  _processFingerprint() async {
    setState(() => _isLoadingPythonEnhance = true);
    ApiService.prcoessPrint(
            fileBytes: imageBytes ?? (await File(imagePath).readAsBytes()))
        .then((value) async {
      FingerprintProcessingResponse? apiResponse =
          value.snapshot as FingerprintProcessingResponse?;
      setState(() => _isLoadingPythonEnhance = false);
      if (apiResponse != null) {
        if (apiResponse.success == true) {
          String hexImage = apiResponse.data?.processedImage ?? "";
          imageBytes = Uint8List.fromList(hex.decode(hexImage));
          setState(() {});
        } else {
          ToastUtils.showCustomSnackbar(
              context: context,
              contentText: apiResponse.message ?? "",
              type: "fail");
        }
      } else {
        ToastUtils.showCustomSnackbar(
            context: context,
            contentText: "Unable to process your fingerprints, please retry",
            type: "fail");
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

  Future<String> convertUint8ListToFile(Uint8List data) async {
    var uuid = const Uuid();
    String uniqueId = uuid.v4();
    final directory = await getTemporaryDirectory();
    String directoryPath = directory.path;

    // Determine the mime type from the bytes
    String? mimeType = lookupMimeType('', headerBytes: data);

    // Determine the file extension from the mime type
    String fileExtension = '';
    if (mimeType != null) {
      var ext = extensionFromMime(mimeType);
      fileExtension = '.$ext';
    }

    // Construct the file path using the unique ID and optional extension
    String filePath =
        '$directoryPath/$uniqueId${DateTime.now().toIso8601String()}$fileExtension';

    print(filePath);

    final file = File(filePath);
    try {
      await file.writeAsBytes(data);
      return file.path;
    } catch (e) {
      print('Error writing to file: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon: SvgPicture.asset('assets/icons/ic_chevron_back.svg'),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Enhance Fingerprint',
                        style: TypeStyle.h2,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      String filePath =
                          await convertUint8ListToFile(imageBytes!);
                      CroppedFile? xfile =
                          await PickerUtil.crop(filePath: filePath);
                      print(xfile?.path);
                      if (xfile != null) {
                        imagePath = xfile.path;
                        imageBytes = null;
                        setState(() {});
                      }
                    },
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.crop,
                      color: ColorStyle.whiteColor,
                      size: 20,
                    ),
                  ),
                ]),
                Expanded(
                  child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(15),
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(6),
                      //   border: Border.all(color: ColorStyle.borderColor),
                      // ),
                      child: Center(
                        child: imageBytes != null
                            ? Image.memory(
                                imageBytes!,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                File(imagePath),
                                fit: BoxFit.contain,
                              ),
                      )),
                ),
                Container(
                    width: double.maxFinite,
                    margin: const EdgeInsets.all(15),
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
                              Text("Successfully Extracted",
                                  style: TypeStyle.h3),
                              Text(
                                  "Please make sure the fingerprint is visible in the final image, if it isn't please retake the photo in good lighting against a neutral background",
                                  style: TypeStyle.body),
                            ],
                          )),
                        ],
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const SizedBox(
                              width: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    color: ColorStyle.red100Color,
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: ColorStyle.red100Color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              String? source = await _openSourceSheet();
                              if (source == 'gallery') {
                                String? file = await PickerUtil.pickImage(
                                    addCropper: false);
                                if (file != null && file != "") {
                                  setState(() {
                                    imageBytes = null;
                                    imagePath = file;
                                  });
                                  _removeImageBg();
                                }
                              } else if (source == 'camera') {
                                String? file = await PickerUtil.captureImage(
                                    addCropper: false);
                                if (file != null && file != "") {
                                  setState(() {
                                    imageBytes = null;
                                    imagePath = file;
                                  });
                                  _removeImageBg();
                                }
                              }
                            },
                            child: SizedBox(
                              width: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 18,
                                    color: ColorStyle.customSwatchColor[800]!,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Retake',
                                    style: TextStyle(
                                      color: ColorStyle.customSwatchColor[800]!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (imageBytes != null) {
                                String filePath =
                                    await convertUint8ListToFile(imageBytes!);
                                if (context.mounted) {
                                  Navigator.of(context).pop(filePath);
                                }
                              } else {
                                Navigator.of(context).pop(imagePath);
                              }
                            },
                            child: const SizedBox(
                              width: 70,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: ColorStyle.whiteColor,
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Done',
                                    style: TextStyle(
                                      color: ColorStyle.whiteColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
          if (_isLoadingPythonEnhance || _isLoadingBgRemoval) _buildLoader()
        ],
      ),
    ));
  }

  _buildLoader() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingUtil.buildAdaptiveLoader(),
            const SizedBox(height: 20),
            Text(
              _isLoadingBgRemoval
                  ? 'Removing Background'
                  : 'Extracting fingerprint using our AI',
              textAlign: TextAlign.center,
              style: TypeStyle.info,
            ),
            SizedBox(height: _isLoadingBgRemoval ? 0 : 5),
            _isLoadingBgRemoval
                ? Container()
                : Text(
                    'This may take a while',
                    textAlign: TextAlign.center,
                    style: TypeStyle.info,
                  ),
          ],
        ),
      ),
    );
  }
}
