enum ExportFormat { png, svg, pdf }

extension ExportFormatX on ExportFormat {
  String get value {
    switch (this) {
      case ExportFormat.png:
        return 'png';
      case ExportFormat.svg:
        return 'svg';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  String get label {
    switch (this) {
      case ExportFormat.png:
        return 'PNG';
      case ExportFormat.svg:
        return 'SVG';
      case ExportFormat.pdf:
        return 'PDF';
    }
  }
}
