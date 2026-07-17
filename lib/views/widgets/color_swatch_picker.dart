import 'package:flutter/cupertino.dart';
import 'package:vocabulaire/models/box_color.dart';

/// A generic color picker showing a title and a row of circular
/// swatches for the given [options]. The selected swatch is highlighted
/// with a ring.
class ColorSwatchPicker extends StatelessWidget {
  final String title;
  final List<BoxColor> options;
  final BoxColor selected;
  final ValueChanged<BoxColor> onChanged;

  const ColorSwatchPicker({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.0,
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey,
              context,
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final option in options)
              GestureDetector(
                onTap: () => onChanged(option),
                child: _ColorSwatch(
                  color: Color(option.argb),
                  selected: option == selected,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;

  const _ColorSwatch({required this.color, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.0,
      height: 36.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: selected
            ? Border.all(
                color: CupertinoDynamicColor.resolve(
                  CupertinoColors.label,
                  context,
                ),
                width: 2.0,
              )
            : null,
      ),
      child: Container(
        width: selected ? 26.0 : 32.0,
        height: selected ? 26.0 : 32.0,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
