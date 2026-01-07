import 'package:pdf/pdf.dart';

class PrintOptions {
  final int count;
  final PdfPageFormat format;
  final String formatName;

  PrintOptions({required this.count, required this.format, required this.formatName});
}
