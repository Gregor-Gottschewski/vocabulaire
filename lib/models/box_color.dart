/// Color palette for boxes.
enum BoxColor {
  purple(0xFF8E7CC3),
  orange(0xFFD98A4E),
  teal(0xFF4F9B8E),
  blue(0xFF5B84B1),
  rose(0xFFC77B90),
  sage(0xFF8AA06B);

  final int argb;

  const BoxColor(this.argb);

  static BoxColor fromName(String name) {
    return BoxColor.values.firstWhere(
      (c) => c.name == name,
      orElse: () => BoxColor.purple,
    );
  }
}
