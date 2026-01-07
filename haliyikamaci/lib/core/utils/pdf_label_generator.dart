import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/models.dart';
import 'package:intl/intl.dart';

class PdfLabelGenerator {
  /// Generates a PDF with [count] product labels and 1 customer receipt.
  /// [firmName] and [driverName] are used for identification.
  static Future<void> printLabels({
    required int count,
    required OrderModel order,
    required String firmName,
    String driverName = 'Şoför',
    required PdfPageFormat format,
  }) async {
    final doc = pw.Document();

    // Load fonts
    final labelTheme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.robotoRegular(),
      bold: await PdfGoogleFonts.robotoBold(),
    );

    // 1. PRODUCT LABELS (N times)
    for (int i = 1; i <= count; i++) {
      doc.addPage(
        pw.Page(
          pageFormat: format, 
          theme: labelTheme,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2),
                borderRadius: pw.BorderRadius.circular(5)
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(firmName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                  pw.SizedBox(height: 5),
                  pw.Text('Sipariş: #${order.id.substring(0, 8)}', style: const pw.TextStyle(fontSize: 14)),
                  pw.Text('Parça: $i / $count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                  pw.Text('Müşteri: ${order.customerName}', style: const pw.TextStyle(fontSize: 12)),
                  pw.Divider(),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: '${order.id}-$i',
                    height: 40,
                    width: 150,
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // 2. CUSTOMER RECEIPT (1 time)
    doc.addPage(
      pw.Page(
        pageFormat: format,
        theme: labelTheme,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(firmName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 20)),
                pw.SizedBox(height: 10),
                pw.Text('TESLİM FİŞİ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Tarih: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}'),
                      pw.Text('Sipariş No: #${order.id.substring(0, 8)}'),
                      pw.Text('Müşteri: ${order.customerName}'),
                      pw.Text('Şoför: $driverName'),
                      pw.SizedBox(height: 10),
                      pw.Text('Hizmet Detayı:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ...order.items.map((item) => pw.Text('• ${item.serviceName}: ${item.quantity} ${item.unit}')),
                      pw.SizedBox(height: 10),
                      pw.Text('Toplam: $count Adet Ürün Teslim Alındı.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Teşekkür Ederiz!', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: 'order:${order.id}',
                  height: 60,
                  width: 60,
                ),
              ],
            ),
          );
        },
      ),
    );

    // Print
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Etiketler_${order.id.substring(0, 8)}',
    );
  }
}
