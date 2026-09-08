class ThemePreset {
  final int? id;
  final String? slug;
  final String? name;

  final String? background;
  final String? waterColor;
  final String? parkColor;

  final Map<String, String>? roadColors;
  final Map<String, double>? roadWidths;

  final String? textPrimary;
  final String? textSecondary;
  final String? fontFamily;

  final int? width;
  final int? height;
  final int? dpi;

  const ThemePreset({
    this.id,
    this.slug,
    this.name,
    this.background,
    this.waterColor,
    this.parkColor,
    this.roadColors,
    this.roadWidths,
    this.textPrimary,
    this.textSecondary,
    this.fontFamily,
    this.width,
    this.height,
    this.dpi,
  });

  factory ThemePreset.fromJson(Map<String, dynamic>? json) {
    return ThemePreset(
      id: json?['id'] as int?,
      slug: json?['slug'] as String?,
      name: json?['name'] as String?,

      background: json?['background'] as String?,
      waterColor: json?['water_color'] as String?,
      parkColor: json?['park_color'] as String?,

      roadColors: (json?['road_colors'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),

      roadWidths: (json?['road_widths'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),

      textPrimary: json?['text_primary'] as String?,
      textSecondary: json?['text_secondary'] as String?,
      fontFamily: json?['font_family'] as String?,

      width: json?['width'] as int?,
      height: json?['height'] as int?,
      dpi: json?['dpi'] as int?,
    );
  }
}
