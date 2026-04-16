import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/certificate_model.dart';
import 'builders_form_document.dart';
import 'file_storage_service.dart';

/// Service for generating Certificate of Inspection Excel (.xlsx) files
class ExcelService {
  /// Generate Excel file and save to device storage
  static Future<String> generateExcel(CertificateModel certificate) async {
    if (certificate.certificateType == 'builders_form') {
      return _generateBuildersFormExcel(certificate);
    }

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
      const MapEntry('Approved By', 'Cardelar Stevie Angel M. Madriñan'),
      const MapEntry(
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

  static Future<String> _generateBuildersFormExcel(
      CertificateModel certificate) async {
    final b = BuildersFormData(certificate);
    final excel = Excel.createExcel();
    final sheet = excel['Builders Form'];

    int row = 1;
    void rowPair(String label, String value) {
      sheet.cell(CellIndex.indexByString('A$row')).value =
          TextCellValue(label);
      sheet.cell(CellIndex.indexByString('A$row')).cellStyle =
          CellStyle(bold: true);
      sheet.cell(CellIndex.indexByString('B$row')).value =
          TextCellValue(value);
      row++;
    }

    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('B1'));
    sheet.cell(CellIndex.indexByString('A1')).value =
        TextCellValue('SERTIPIKO NG PAGKAGAWA (Builders Form)');
    sheet.cell(CellIndex.indexByString('A1')).cellStyle =
        CellStyle(fontSize: 16, bold: true);
    row = 3;

    rowPair('Control / BLG', b.controlNumber);
    row++;
    rowPair('Pangalan ng gumawa', b.builderName);
    rowPair('Nakatira sa (address)', b.builderAddress);
    rowPair('Barangay kung saan binuo', b.builderBarangayBuilt);
    rowPair('May-ari', b.ownerName);
    rowPair('Sitio / Purok', b.ownerSitioPurok);
    rowPair('Barangay (may-ari)', b.ownerBarangay);
    row++;
    rowPair('Pangalan ng bangka', b.vesselName);
    rowPair('Uri/Klase', b.vesselTypeClass);
    rowPair('Materyales', b.materialsUsed);
    rowPair('Haba (LOA) m', b.lengthOverall);
    rowPair('Luwang (Breadth)', b.breadthMolded);
    rowPair('Lalim (Depth)', b.depthMolded);
    rowPair('Bilang ng deck', b.numberOfDecks);
    rowPair('Bilang ng mast', b.numberOfMasts);
    rowPair('G.T.', b.grossTonnageBuilder);
    rowPair('N.T.', b.netTonnageBuilder);
    rowPair('Petsa natapos/ipinalaot', b.dateFinishedLaunched);
    rowPair('Life vest/jacket', b.lifeVests);
    row++;
    rowPair('Uri ng makina', b.engineType);
    rowPair('HP & Model', b.horsepowerModel);
    rowPair('Serial', b.serialNumber);
    rowPair('Petsa ginawa', b.dateManufactured);
    rowPair('Silindro', b.numberOfCylinders);
    rowPair('Bore/Stroke', b.boreStroke);
    rowPair('RPM', b.rpm);
    rowPair('Bilang makina', b.numberOfEngines);
    rowPair('Bilang propeller/screw', b.numberOfPropellers);
    rowPair('Petsa at lugar inisyu', b.datePlaceIssued);
    row++;
    rowPair('Lagda ng gumawa', b.builderSignature);
    rowPair('Prepared by', b.preparedBy);
    rowPair('Sumpa — araw (ika-)', b.oathDay);
    rowPair('Sumpa — buwan', b.oathMonth);
    rowPair('Sumpa — taon', b.oathYear);
    rowPair('Sumpa (buong petsa/note)', b.oathDate);
    rowPair('Katibayan BLG.', b.residenceCertBlg);
    rowPair('Iginawad', b.residenceCertIssued);
    rowPair('Lugar', b.residenceCertPlace);
    rowPair('Karagdagang detalye (katibayan)', b.residenceCertDetails);
    row++;
    rowPair('Applicant', b.applicantName);
    rowPair('Contact', b.contactNumber);
    rowPair('Inspektor', b.inspectorName);
    rowPair('Petsa isyu (sertipiko)', b.issuedDate);

    sheet.setColumnWidth(0, 36);
    sheet.setColumnWidth(1, 48);

    final fileBytes = excel.encode();
    if (fileBytes == null) throw Exception('Failed to encode Excel');
    final bytes = Uint8List.fromList(fileBytes);
    final filename = '${certificate.controlNumber}_Builders_Form.xlsx';
    return FileStorageService.saveExcelFile(bytes: bytes, filename: filename);
  }
}
