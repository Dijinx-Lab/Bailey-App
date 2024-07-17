import 'dart:io';

import 'package:bailey/style/color/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomLoading extends StatefulWidget {
  const CustomLoading({Key? key, this.type = 0}) : super(key: key);

  final int type;

  @override
  _CustomLoadingState createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading>
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
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LoadingUtil {
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
                  )));
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
