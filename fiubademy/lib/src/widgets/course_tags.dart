import 'package:flutter/material.dart';

class CourseTags extends StatelessWidget {
  final List<String> _tags;
  const CourseTags({Key? key, required List<String> tags})
      : _tags = tags,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.0,
      child: ShaderMask(
        shaderCallback: (Rect rect) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.purple,
              Colors.transparent,
              Colors.transparent,
              Colors.purple
            ],
            stops: [
              0.0,
              0.025,
              0.975,
              1.0,
            ],
          ).createShader(rect);
        },
        // The color channel is irrelevant using dstOut.
        blendMode: BlendMode.dstOut,
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(width: 4.0),
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: _tags.length,
          itemBuilder: (BuildContext context, int index) => Chip(
            label: Text(
              _tags[index],
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).colorScheme.secondaryVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}
