import 'dart:io';

import 'package:bailey/style/color/color_style.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomLoading extends StatefulWidget {
  const CustomLoading({Key? key, this.type = 0}) : super(key: key);

  final int type;

  @override
  State<CustomLoading> createState() => CustomLoadingState();
}

class CustomLoadingState extends State<CustomLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Visibility(
          visible: widget.type == 1, child: LoadingUtil.buildAdaptiveLoader()),
      Visibility(
          visible: widget.type == 2, child: LoadingUtil.buildLoadingTwo()),
      Visibility(
          visible: widget.type == 3,
          child: LoadingUtil.buildUploadLoader(context)),
      Visibility(
          visible: widget.type == 4,
          child: LoadingUtil.buildUploadLoader(context, multiple: true)),
      Visibility(
          visible: widget.type == 5,
          child: LoadingUtil.buildEditPrintsLoader(
            context,
          )),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LoadingUtil {
  static Widget buildUploadLoader(BuildContext context,
      {Color color = ColorStyle.blackColor, bool multiple = false}) {
    return Center(
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
                color: ColorStyle.whiteColor,
                borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              const Icon(
                Icons.cloud_upload_outlined,
                color: ColorStyle.backgroundColor,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                multiple
                    ? "Uploading your media, this may take a few minutes\nDo not close this screen"
                    : 'Uploading your media, this may take some time\nDo not close this screen',
                textAlign: TextAlign.center,
                style: TypeStyle.info2,
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  child: buildLineLoader())
            ]),
          )),
    );
  }

  static Widget buildEditPrintsLoader(BuildContext context,
      {Color color = ColorStyle.blackColor}) {
    return Center(
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(
                color: ColorStyle.whiteColor,
                borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              const Icon(
                Icons.cloud_upload_outlined,
                color: ColorStyle.blackColor,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Processing your changes, this may take some time\nDo not close this screen',
                textAlign: TextAlign.center,
                style: TypeStyle.info2,
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width - 100,
                  child: buildLineLoader())
            ]),
          )),
    );
  }

  static Widget buildAdaptiveLoader({Color color = ColorStyle.whiteColor}) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Platform.isAndroid
            ? CircularProgressIndicator(
                color: color,
              )
            : CupertinoActivityIndicator(
                radius: 15,
                color: color,
              ),
      ),
    );
  }

  static Widget buildLineLoader({Color color = ColorStyle.whiteColor}) {
    return Center(
      child: LinearProgressIndicator(
        color: color,
      ),
    );
  }

  static Widget buildLoadingTwo() {
    return const Align(
      alignment: Alignment.center,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 10,
            ),
            Text(
              'Paiement en cours...',
              style: TextStyle(color: Colors.white),
            )
          ]),
    );
  }
}
