import 'package:flutter/cupertino.dart';

/// A tappable row showing a small secondary label above a primary content
/// widget, with a trailing chevron indicating navigation to another screen.
/// Wrap one or more rows in a [NavigationRowGroup] for the grouped,
/// rounded-corner card look.
class NavigationRow extends StatelessWidget {
  final String secondaryLabel;
  final Widget primaryContent;
  final VoidCallback onTap;

  const NavigationRow({
    super.key,
    required this.secondaryLabel,
    required this.primaryContent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      onPressed: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  secondaryLabel,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.systemGrey,
                      context,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 17.0,
                    color: CupertinoDynamicColor.resolve(
                      CupertinoColors.label,
                      context,
                    ),
                  ),
                  child: primaryContent,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Icon(
            CupertinoIcons.chevron_right,
            size: 18.0,
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.systemGrey,
              context,
            ),
          ),
        ],
      ),
    );
  }
}

/// Groups multiple [NavigationRow]s (or any widgets) into a single card with
/// rounded corners and thin separators between the children
class NavigationRowGroup extends StatelessWidget {
  final List<Widget> children;

  const NavigationRowGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.tertiarySystemBackground,
          context,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  color: CupertinoColors.separator.resolveFrom(context),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
