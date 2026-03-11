import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import '../models/certificate_model.dart';
import 'file_storage_service.dart';

/// Service for generating Certificate of Inspection Word documents
class WordService {
  static const String _approvedByName = 'Cardelar Stevie Angel M. Madriñan';
  static const String _approvedByTitle =
      'CG Assistant Department Head II (Assistant City ENRO)';

  /// Generate Word (RTF) file and save to device storage
  static Future<String> generateWord(CertificateModel certificate) async {
    final bytes = _buildDocxBytes(certificate);
    final filename = '${certificate.controlNumber}.docx';
    return FileStorageService.saveWordFile(bytes: bytes, filename: filename);
  }

  static Uint8List _buildDocxBytes(CertificateModel cert) {
    final documentXml = _buildDocumentXml(cert);

    final contentTypesXml = _buildContentTypesXml();
    final relsXml = _buildRootRelsXml();
    final docRelsXml = _buildDocumentRelsXml();

    final documentBytes = utf8.encode(documentXml);
    final contentTypesBytes = utf8.encode(contentTypesXml);
    final relsBytes = utf8.encode(relsXml);
    final docRelsBytes = utf8.encode(docRelsXml);

    final archive = Archive()
      ..addFile(
        ArchiveFile(
          '[Content_Types].xml',
          contentTypesBytes.length,
          Uint8List.fromList(contentTypesBytes),
        ),
      )
      ..addFile(
        ArchiveFile(
          '_rels/.rels',
          relsBytes.length,
          Uint8List.fromList(relsBytes),
        ),
      )
      ..addFile(
        ArchiveFile(
          'word/document.xml',
          documentBytes.length,
          Uint8List.fromList(documentBytes),
        ),
      )
      ..addFile(
        ArchiveFile(
          'word/_rels/document.xml.rels',
          docRelsBytes.length,
          Uint8List.fromList(docRelsBytes),
        ),
      );

    final zipped = ZipEncoder().encode(archive);
    if (zipped == null) throw Exception('Failed to create DOCX archive');
    return Uint8List.fromList(zipped);
  }

  static String _buildContentTypesXml() {
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>
''';
  }

  static String _buildRootRelsXml() {
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>
''';
  }

  static String _buildDocumentRelsXml() {
    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
</Relationships>
''';
  }

  static String _buildDocumentXml(CertificateModel cert) {
    final body = StringBuffer();

    body.writeln(_p(cert.controlNumber, align: 'right'));

    body.writeln(_p('Republic of the Philippines',
        align: 'center', bold: true, fontSize: 22));
    body.writeln(_p('City Government of Puerto Princesa',
        align: 'center', bold: true, fontSize: 22));
    body.writeln(_p(
      'Office of the City Environment and Natural Resources Officer',
      align: 'center',
      fontSize: 20,
    ));
    body.writeln(_p('ENVIRONMENTAL LAW ENFORCEMENT DIVISION (ELED)',
        align: 'center', fontSize: 20));
    body.writeln(_p('Bantay Dagat Section', align: 'center', fontSize: 20));
    body.writeln(_spacer());

    body.writeln(_p('CERTIFICATE OF INSPECTION',
        align: 'center', bold: true, fontSize: 32));
    body.writeln(_p('(Marine Products)', align: 'center', fontSize: 22));
    body.writeln(_spacer());

    body.writeln(_p('TO WHOM IT MAY CONCERN:', bold: true));
    body.writeln(_spacer(height: 1));

    body.writeln(_p(
      "THIS IS TO CERTIFY that Mr. / Ms. ${cert.applicantName} of ${cert.applicantAddress} Puerto Princesa City has been inspected by Bantay Dagat and hereby endorsing his/her request for approval and issuance of Mayor's Permit to operate/engage in the business of:",
    ));
    body.writeln(_spacer(height: 1));

    body.writeln(_p('License Type: ${cert.licenseType}'));
    body.writeln(_p('KIND OF LICENSE APPLIED : BUSINESS PERMIT'));
    body.writeln(_p('NATURE OF BUSINESS : ${cert.natureOfBusiness}'));
    body.writeln(_p('BUSINESS ADDRESS : ${cert.businessAddress}'));
    body.writeln(_p('NAME OF BUSINESS : ${cert.businessName}'));
    body.writeln(_spacer(height: 1));

    body.writeln(_p(
      'FURTHER CERTIFY that the above described business including the proposed location or area, prior to approval, does not pose any destruction/obstruction to the Ecological and Marine Resources of the City.',
    ));
    body.writeln(_spacer(height: 1));

    body.writeln(_p('Issued this ${cert.issuedDate}.'));
    body.writeln(_spacer(height: 1));

    body.writeln(_p('Conformed:', bold: true));
    body.writeln(_spacer(height: 1));
    body.writeln(_p('_____________________________'));
    body.writeln(
        _p('(Signature over Printed Name) Owner/Representative', fontSize: 18));
    body.writeln(_spacer(height: 1));
    body.writeln(_p('Contact No. ${cert.contactNumber}'));
    body.writeln(_p('Inspected by: ${cert.inspectorName}'));
    body.writeln(_spacer(height: 2));

    body.writeln(_p('Approved by:', align: 'right', bold: true));
    body.writeln(
        _p('BY AUTHORITY OF THE CITY ENRO:', align: 'right', bold: true));
    body.writeln(_spacer(height: 1));
    body.writeln(_p(_approvedByName, align: 'right'));
    body.writeln(_p(_approvedByTitle, align: 'right', fontSize: 18));
    body.writeln(_spacer(height: 2));

    body.writeln(_p(
      'Ground Floor, Old City Hall Building, Bgy. Sta. Monica, Puerto Princesa City',
      fontSize: 18,
    ));
    body.writeln(_p('bantaydagat.ppc@gmail.com', fontSize: 18));

    // Section properties (required by Word)
    body.writeln('''
<w:sectPr>
  <w:pgSz w:w="11906" w:h="16838"/>
  <w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" w:header="708" w:footer="708" w:gutter="0"/>
</w:sectPr>
''');

    return '''
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    ${body.toString()}
  </w:body>
</w:document>
''';
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _spacer({int height = 1}) {
    // Inserts empty paragraphs as vertical space.
    final buf = StringBuffer();
    for (var i = 0; i < height; i++) {
      buf.writeln(_p(''));
    }
    return buf.toString();
  }

  static String _p(
    String text, {
    String? align, // 'left' | 'center' | 'right' | 'both'
    bool bold = false,
    int fontSize = 20, // points-ish; will be converted to half-points
  }) {
    final escaped = _escapeXml(text);
    final jc = align == null ? '' : '<w:jc w:val="$align"/>';
    final b = bold ? '<w:b/>' : '';
    final sz = '<w:sz w:val="${fontSize * 2}"/>';

    return '''
<w:p>
  <w:pPr>
    $jc
  </w:pPr>
  <w:r>
    <w:rPr>
      $b
      $sz
    </w:rPr>
    <w:t xml:space="preserve">$escaped</w:t>
  </w:r>
</w:p>
''';
  }
}
