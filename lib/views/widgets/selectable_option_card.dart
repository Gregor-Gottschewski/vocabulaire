import 'package:flutter/cupertino.dart';

/// A selectable card showing a square icon badge, a title, a subtitle and a
/// checkbox on the trailing side.
class SelectableOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const SelectableOptionCard({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.tertiarySystemBackground,
            context,
          ),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: selected ? selectedColor : CupertinoColors.transparent,
            width: 2.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.0,
              height: 48.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: CupertinoColors.white),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: CupertinoDynamicColor.resolve(
                        CupertinoColors.label,
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: CupertinoDynamicColor.resolve(
                        CupertinoColors.systemGrey,
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            _RoundCheckbox(selected: selected, color: selectedColor),
          ],
        ),
      ),
    );
  }
}

class _RoundCheckbox extends StatelessWidget {
  final bool selected;
  final Color color;

  const _RoundCheckbox({required this.selected, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.0,
      height: 24.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : CupertinoColors.transparent,
        border: Border.all(
          color: selected
              ? color
              : CupertinoDynamicColor.resolve(
                  CupertinoColors.systemGrey3,
                  context,
                ),
          width: 2.0,
        ),
      ),
      child: selected
          ? const Icon(
              CupertinoIcons.check_mark,
              size: 14.0,
              color: CupertinoColors.white,
            )
          : null,
    );
  }
}
