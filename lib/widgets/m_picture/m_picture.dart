import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MPicture extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const MPicture(
      {super.key, required this.url, this.width, this.height, this.fit});

  @override
  State<MPicture> createState() => _MPictureState();
}

class _MPictureState extends State<MPicture> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.url,
      fit: widget.fit,
      height: widget.height,
      width: widget.width,
      // placeholder: (context, url) => Image.asset(
      //   'assets/images/default_image.jpg',
      //   fit: BoxFit.cover,
      // ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/images/default_image.jpg',
        fit: BoxFit.cover,
      ),
    );
  }
}
