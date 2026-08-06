import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/features/vendors/application/sales_report_export_service.dart';

void main() {
  const stallName = 'Diosa Fruit Stand';
  final timestamp = DateTime(2026, 6, 25, 9, 8, 7);

  group('SalesReportExportService', () {
    test('buildFilename normalizes the report period and stall name', () {
      final name = SalesReportExportService.buildFilename(
        'This Week',
        timestamp,
        stallName,
      );

      expect(
        name,
        'diosa_fruit_stand_earnings_report_this week_2026-06-25_090807',
      );
    });

    test('buildPdf returns a valid PDF byte stream', () async {
      final bytes = await SalesReportExportService.buildPdf('Week', stallName);
      final header = ascii.decode(bytes.take(4).toList());

      expect(bytes, isNotEmpty);
      expect(header, '%PDF');
      expect(bytes.length, greaterThan(1000));
    });

    test('buildExcel returns a decodable workbook with report rows', () {
      final bytes = SalesReportExportService.buildExcel('Week', stallName);
      final workbook = Excel.decodeBytes(bytes);
      final sheet = workbook['Sales Report'];

      String? textAt(String cell) {
        return sheet.cell(CellIndex.indexByString(cell)).value?.toString();
      }

      expect(bytes, isNotEmpty);
      expect(textAt('A1'), 'PalengkeGo - Stall Earnings Report');
      expect(textAt('A4'), 'Summary Category');
      expect(textAt('B4'), 'Total Amount (PHP)');
      expect(textAt('C4'), 'Completed Orders');
      expect(textAt('A5'), 'Earnings Today');
      expect(textAt('A6'), 'Earnings This Week');
      expect(textAt('A7'), 'Total Monthly Earnings');
      expect(textAt('B7'), 'P 48,250.00');
      expect(textAt('A10'), 'Daily Earnings Breakdown');
      expect(textAt('A12'), 'Date');
      expect(textAt('B12'), 'Completed Orders');
      expect(textAt('A13'), '2026-07-24');
    });
  });
}
