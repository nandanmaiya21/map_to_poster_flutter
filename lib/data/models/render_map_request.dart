class RenderMapRequest {
  final String theme;
  final String title;
  final String subtitle;
  final String coordinates;
  final String layout;
  final String exportFormat;

  const RenderMapRequest({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.coordinates,
    required this.layout,
    required this.exportFormat,
  });

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'title': title,
      'subtitle': subtitle,
      'coordinates': coordinates,
      'width': 2000,
      'height': 3000,
      'dpi': 300,
      'map_padding': 0.00,
      'map_coverage': 1.4,
      'map_offset_x': 0,
      'map_offset_y': -0.2,
      'title_size': 52,
      'subtitle_size': 20,
      'coordinates_size': 14,
      'font_weight': 'bold',
      'show_top_gradient': true,
      'show_bottom_gradient': true,
      'gradient_height': 0.30,
      'gradient_strength': 0.9,
      'show_divider': true,
      'divider_width': 0.5,
      'show_title': true,
      'show_subtitle': true,
      'show_coordinates': true,
      'show_attribution': true,
      'layout': layout,
      'export_format': exportFormat,
    };
  }
}
