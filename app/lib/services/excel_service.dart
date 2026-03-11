import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/certificate_model.dart';
import 'file_storage_service.dart';

/// Service for generating Certificate of Inspection Excel (.xlsx) files
class ExcelService {
  /// Generate Excel file and save to device storage
  static Future<String> generateExcel(CertificateModel certificate) async {
    final excel = Excel.createExcel();
    final sheet = excel['Certificate'];

    // Header row
    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'));
    sheet.cell(CellIndex.indexByString('A1')).value =
        TextCellValue('CERTIFICATE OF INSPECTION');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle =
        CellStyle(fontSize: 16, bold: true);

    sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('D2'));
    sheet.cell(CellIndex.indexByString('A2')).value =
        TextCellValue('(Marine Products)');
    sheet.cell(CellIndex.indexByString('A2')).cellStyle =
        CellStyle(fontSize: 12);

    // Government header
    sheet.merge(CellIndex.indexByString('A3'), CellIndex.indexByString('D3'));
    sheet.cell(CellIndex.indexByString('A3')).value =
        TextCellValue('Republic of the Philippines');
    sheet.cell(CellIndex.indexByString('A3')).cellStyle = CellStyle(bold: true);

    sheet.merge(CellIndex.indexByString('A4'), CellIndex.indexByString('D4'));
    sheet.cell(CellIndex.indexByString('A4')).value =
        TextCellValue('City Government of Puerto Princesa');
    sheet.cell(CellIndex.indexByString('A4')).cellStyle = CellStyle(bold: true);

    sheet.merge(CellIndex.indexByString('A5'), CellIndex.indexByString('D5'));
    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue(
        'Office of the City Environment and Natural Resources Officer');
    sheet.cell(CellIndex.indexByString('A5')).cellStyle = CellStyle(bold: true);

    sheet.merge(CellIndex.indexByString('A6'), CellIndex.indexByString('D6'));
    sheet.cell(CellIndex.indexByString('A6')).value =
        TextCellValue('ENVIRONMENTAL LAW ENFORCEMENT DIVISION (ELED)');
    sheet.cell(CellIndex.indexByString('A6')).cellStyle = CellStyle(bold: true);

    sheet.merge(CellIndex.indexByString('A7'), CellIndex.indexByString('D7'));
    sheet.cell(CellIndex.indexByString('A7')).value =
        TextCellValue('Bantay Dagat Section');
    sheet.cell(CellIndex.indexByString('A7')).cellStyle = CellStyle(bold: true);

    // Empty row
    int row = 9;

    // Certificate data
    final data = <MapEntry<String, String>>[
      MapEntry('Control Number', certificate.controlNumber),
      MapEntry('Applicant Name', certificate.applicantName),
      MapEntry('Applicant Address', certificate.applicantAddress),
      MapEntry('License Type', certificate.licenseType),
      MapEntry('Nature of Business', certificate.natureOfBusiness),
      MapEntry('Business Name', certificate.businessName),
      MapEntry('Business Address', certificate.businessAddress),
      MapEntry('Contact Number', certificate.contactNumber),
      MapEntry('Issued Date', certificate.issuedDate),
      MapEntry('Inspector Name', certificate.inspectorName),
      MapEntry('Approved By', 'Cardelar Stevie Angel M. Madriñan'),
      MapEntry(
          'Title', 'CG Assistant Department Head II (Assistant City ENRO)'),
    ];

    for (final item in data) {
      sheet.cell(CellIndex.indexByString('A$row')).value =
          TextCellValue(item.key);
      sheet.cell(CellIndex.indexByString('A$row')).cellStyle =
          CellStyle(bold: true);
      sheet.cell(CellIndex.indexByString('B$row')).value =
          TextCellValue(item.value);
      row++;
    }

    // Set column widths
    sheet.setColumnWidth(0, 25);
    sheet.setColumnWidth(1, 50);

    final fileBytes = excel.encode();
    if (fileBytes == null) throw Exception('Failed to encode Excel');

    final bytes = Uint8List.fromList(fileBytes);
    final filename = '${certificate.controlNumber}.xlsx';
    return FileStorageService.saveExcelFile(bytes: bytes, filename: filename);
  }
}
