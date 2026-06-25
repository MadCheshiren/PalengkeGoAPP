import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palengkego/features/vendors/application/sales_report_export_service.dart';

void main() {
  const report = SalesReportData(
    period: 'Week',
    total: 'PHP 12,450.00',
    change: '+PHP 1,250 vs last week',
    payouts: [
      SalesReportPayout(
        method: 'Bank Transfer',
        amount: 'PHP 4,900.00',
        date: 'May 21, 2024',
      ),
      SalesReportPayout(
        method: 'GCash',
        amount: 'PHP 850.00',
        date: 'May 22, 2024',
      ),
    ],
  );

  group('SalesReportExportService', () {
    test('buildFilename normalizes the report period', () {
      final name = SalesReportExportService.buildFilename(
        report.copyWith(period: 'This Week'),
        DateTime(2026, 6, 25, 9, 8, 7),
      );

      expect(name, 'sales_report_this_week_2026-06-25_090807');
    });

    test('buildPdf returns a valid PDF byte stream', () async {
      final bytes = await SalesReportExportService.buildPdf(report);
      final header = ascii.decode(bytes.take(4).toList());

      expect(bytes, isNotEmpty);
      expect(header, '%PDF');
      expect(bytes.length, greaterThan(1000));
    });

    test('buildExcel returns a decodable workbook with report rows', () {
      final bytes = SalesReportExportService.buildExcel(report);
      final workbook = Excel.decodeBytes(bytes);
      final sheet = workbook['Sales Report'];

      String? textAt(String cell) {
        return sheet.cell(CellIndex.indexByString(cell)).value?.toString();
      }

      expect(bytes, isNotEmpty);
      expect(textAt('A1'), 'PalengkeGo Sales Report');
      expect(textAt('A2'), 'Period');
      expect(textAt('B2'), 'Week');
      expect(textAt('A3'), 'Total Earnings');
      expect(textAt('B3'), 'PHP 12,450.00');
      expect(textAt('A4'), 'Change');
      expect(textAt('B4'), '+PHP 1,250 vs last week');
      expect(textAt('A6'), 'Recent Payouts');
      expect(textAt('A7'), 'Method');
      expect(textAt('A8'), 'Bank Transfer');
      expect(textAt('B8'), 'PHP 4,900.00');
      expect(textAt('A9'), 'GCash');
      expect(textAt('B9'), 'PHP 850.00');
    });
  });
}
