import 'package:flutter/material.dart';
import 'package:vocabulaire/views/widgets/app_text_field.dart';
import 'package:vocabulaire/views/widgets/section_title.dart';

import '../../theme/app_spacing.dart';

/// [LabelTextField] is a widget containing a text field with a title.
/// The title style cannot be changed, while any type of [AppTextField] can
/// be used as text field.
class LabelTextField extends StatelessWidget {
  final String label;
  final AppTextField textField;

  const LabelTextField({
    super.key,
    required this.label,
    required this.textField,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(text: label),
          const SizedBox(height: AppSpacing.gapSmall),
          textField
        ]
    );
  }
}