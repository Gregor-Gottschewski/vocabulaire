import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/vocabulary_box.dart';

class BoxTile extends StatelessWidget {
  final VocabularyBox box;
  final VoidCallback onTap;

  const BoxTile({super.key, required this.box, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoDynamicColor.resolve(
              CupertinoColors.tertiarySystemBackground,
              context,
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                box.name,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.label,
                    context,
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                box.description,
                style: TextStyle(
                  fontSize: 14.0,
                  color: CupertinoDynamicColor.resolve(
                    CupertinoColors.systemGrey,
                    context,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
