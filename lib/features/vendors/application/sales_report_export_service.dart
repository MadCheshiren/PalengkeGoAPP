import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesReportData {
  const SalesReportData({
    required this.period,
    required this.total,
    required this.change,
    required this.payouts,
  });

  final String period;
  final String total;
  final String change;
  final List<SalesReportPayout> payouts;

  SalesReportData copyWith({
    String? period,
    String? total,
    String? change,
    List<SalesReportPayout>? payouts,
  }) {
    return SalesReportData(
      period: period ?? this.period,
      total: total ?? this.total,
      change: change ?? this.change,
      payouts: payouts ?? this.payouts,
    );
  }
}

class SalesReportPayout {
  const SalesReportPayout({
    required this.method,
    required this.amount,
    required this.date,
  });

  final String method;
  final String amount;
  final String date;
}

class SalesReportExportService {
  const SalesReportExportService._();

  static String buildFilename(SalesReportData report, DateTime timestamp) {
    final period = report.period
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final formattedTimestamp = DateFormat(
      'yyyy-MM-dd_HHmmss',
    ).format(timestamp);
    return 'sales_report_${period}_$formattedTimestamp';
  }

  static Future<Uint8List> buildPdf(SalesReportData report) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                color: const PdfColor.fromInt(0xFF0B372B),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'PalengkeGo',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Sales Report',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Period: ${report.period}',
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total Earnings: ${report.total}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Change: ${report.change}',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Recent Payouts:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0B372B),
                ),
                cellAlignment: pw.Alignment.centerLeft,
                data: <List<String>>[
                  ['Method', 'Amount', 'Date'],
                  ...report.payouts.map(
                    (payout) => [payout.method, payout.amount, payout.date],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Uint8List buildExcel(SalesReportData report) {
    final excel = Excel.createExcel();
    final sheet = excel['Sales Report'];
    excel.setDefaultSheet('Sales Report');

    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#0B372B'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    final boldStyle = CellStyle(bold: true);

    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('PalengkeGo Sales Report');
    titleCell.cellStyle = headerStyle;

    sheet.appendRow([TextCellValue('Period'), TextCellValue(report.period)]);
    sheet.appendRow([
      TextCellValue('Total Earnings'),
      TextCellValue(report.total),
    ]);
    sheet.appendRow([TextCellValue('Change'), TextCellValue(report.change)]);
    sheet.appendRow([TextCellValue('')]);

    final payoutHeaderCell = sheet.cell(CellIndex.indexByString('A6'));
    payoutHeaderCell.value = TextCellValue('Recent Payouts');
    payoutHeaderCell.cellStyle = boldStyle;

    sheet.appendRow([
      TextCellValue('Method'),
      TextCellValue('Amount'),
      TextCellValue('Date'),
    ]);
    sheet.cell(CellIndex.indexByString('A7')).cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByString('B7')).cellStyle = headerStyle;
    sheet.cell(CellIndex.indexByString('C7')).cellStyle = headerStyle;

    for (final payout in report.payouts) {
      sheet.appendRow([
        TextCellValue(payout.method),
        TextCellValue(payout.amount),
        TextCellValue(payout.date),
      ]);
    }

    sheet.setColumnWidth(0, 20);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 15);

    return Uint8List.fromList(excel.encode() ?? const []);
  }
}
