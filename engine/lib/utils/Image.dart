import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImageType { asset, network }
enum ImageFormat { png, svg }

class VersatileImage extends StatelessWidget {
  final String imagePath;
  final ImageType imageType;
  final ImageFormat imageFormat;
  final double? width;
  final double? height;

  const VersatileImage.assetPng(this.imagePath, {Key? key, this.width, this.height})
      : imageType = ImageType.asset,
        imageFormat = ImageFormat.png,
        super(key: key);

  const VersatileImage.assetSvg(this.imagePath, {Key? key, this.width, this.height})
      : imageType = ImageType.asset,
        imageFormat = ImageFormat.svg,
        super(key: key);

  const VersatileImage.networkPng(this.imagePath, {Key? key, this.width, this.height})
      : imageType = ImageType.network,
        imageFormat = ImageFormat.png,
        super(key: key);

  const VersatileImage.networkSvg(this.imagePath, {Key? key, this.width, this.height})
      : imageType = ImageType.network,
        imageFormat = ImageFormat.svg,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (imageType) {
      case ImageType.asset:
        return imageFormat == ImageFormat.svg
            ? SvgPicture.asset(imagePath, width: width, height: height)
            : Image.asset(imagePath, width: width, height: height);
      case ImageType.network:
        return imageFormat == ImageFormat.svg
            ? SvgPicture.network(imagePath, width: width, height: height)
            : Image.network(imagePath, width: width, height: height);
      default:
        return const SizedBox();
    }
  }
}
