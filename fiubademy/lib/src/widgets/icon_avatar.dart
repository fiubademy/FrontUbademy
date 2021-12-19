import 'package:flutter/material.dart';

class IconAvatar extends StatelessWidget {
  final int avatarID;
  final double? width;
  final double? height;

  const IconAvatar({Key? key, required this.avatarID, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageAsset = 'images/avatar_${avatarID + 1}.png';
    return Image(
      height: width,
      width: width,
      image: AssetImage(imageAsset),
    );
  }
}
