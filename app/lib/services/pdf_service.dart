import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/certificate_model.dart';
import 'builders_form_document.dart';
import 'file_storage_service.dart';

/// Service for generating Certificate of Inspection PDF documents
class PdfService {
  static const String _approvedByName = 'Cardelar Stevie Angel M. Madriñan';
  static const String _approvedByTitle =
      'CG Assistant Department Head II (Assistant City ENRO)';

  /// Generate PDF and save to device storage
  static Future<String> generatePdf(CertificateModel certificate) async {
    if (certificate.certificateType == 'builders_form') {
      return _generateBuildersFormPdf(certificate);
    }

    final doc = pw.Document(
      title: 'Certificate of Inspection - ${certificate.controlNumber}',
      author: 'CENRO App',
    );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => _buildContent(certificate),
      ),
    );

    final bytes = Uint8List.fromList(await doc.save());
    final filename = '${certificate.controlNumber}.pdf';
    return FileStorageService.savePdfFile(bytes: bytes, filename: filename);
  }

  /// Preview PDF in print dialog
  static Future<void> previewPdf(CertificateModel certificate) async {
    if (certificate.certificateType == 'builders_form') {
      final doc = pw.Document(title: 'Builders Form - ${certificate.controlNumber}');
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(36),
          build: (_) => _buildersFormWidgets(BuildersFormData(certificate)),
        ),
      );
      await Printing.layoutPdf(
        onLayout: (_) async => doc.save(),
        name: 'Builders_${certificate.controlNumber}.pdf',
      );
      return;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => _buildContent(certificate),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => doc.save(),
      name: 'Certificate_${certificate.controlNumber}.pdf',
    );
  }

  static Future<String> _generateBuildersFormPdf(CertificateModel certificate) async {
    final b = BuildersFormData(certificate);
    final doc = pw.Document(
      title: 'SERTIPIKO NG PAGKAGAWA - ${certificate.controlNumber}',
      author: 'CENRO App',
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => _buildersFormWidgets(b),
      ),
    );
    final bytes = Uint8List.fromList(await doc.save());
    final filename = '${certificate.controlNumber}_Builders_Form.pdf';
    return FileStorageService.savePdfFile(bytes: bytes, filename: filename);
  }

  static const _bfSmall = 8.5;
  static const _bfH = 10.0;

  static List<pw.Widget> _buildersFormWidgets(BuildersFormData b) {
    pw.TextStyle small() => const pw.TextStyle(fontSize: _bfSmall);
    pw.TextStyle h() =>
        pw.TextStyle(fontSize: _bfH, fontWeight: pw.FontWeight.bold);

    pw.Widget line(String label, String value, {bool boldLabel = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.RichText(
          text: pw.TextSpan(
            style: small(),
            children: [
              pw.TextSpan(
                text: label,
                style: boldLabel ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
              ),
              pw.TextSpan(
                text: value.isEmpty ? ' _________________' : ' $value',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return [
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('Control / BLG: ${b.controlNumber}', style: small()),
      ),
      pw.SizedBox(height: 6),
      pw.Center(
        child: pw.Text(
          'SERTIPIKO NG PAGKAGAWA:',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Ang kasulatang ito ay pagpatunay na ang nabanggit na pangalan at pagkakakilanlan sa bangkang may motor ay ginawa ni',
        style: small(),
        textAlign: pw.TextAlign.justify,
      ),
      line('', b.builderName),
      pw.Text('(Pangalan ng gumawa)', style: small(), textAlign: pw.TextAlign.center),
      pw.SizedBox(height: 4),
      pw.Text('Nakatira sa', style: small()),
      line('', b.builderAddress),
      pw.Text('at ginawa/binuo sa Barangay', style: small()),
      line('', b.builderBarangayBuilt),
      pw.SizedBox(height: 4),
      pw.Text(
        'Para sa kapakanan ni (may-ari) ${b.ownerName}, residente/naninirahan sa Sitio / Purok ${b.ownerSitioPurok}',
        style: small(),
        textAlign: pw.TextAlign.justify,
      ),
      pw.Text(
        'Barangay ${b.ownerBarangay}, Lungsod ng Puerto Princesa.',
        style: small(),
      ),
      pw.SizedBox(height: 8),
      pw.Center(
        child: pw.Text(
          'PAGKAKAKILANLAN NG BANGKANG MAY MOTOR',
          style: h(),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 4),
      line('Pangalan ng Bangkang may motor:', b.vesselName),
      line('Uri/Klase ng Bangkang may motor:', b.vesselTypeClass),
      line('Mga Materyales na ginamit:', b.materialsUsed),
      line('Kabuuang Haba (Length overall):', '${b.lengthOverall} m'),
      line('Luwang (Breadth-Molded):', '${b.breadthMolded} metro'),
      line('Sukat ng Lalim (Depth-Molded):', '${b.depthMolded} metro'),
      line('Bilang ng Kamarote (No. of Deck):', b.numberOfDecks),
      line('Bilang ng Palo (No. of Mast):', b.numberOfMasts),
      line('Kabuuang bigat (Gross Tonnage) G.T.:', b.grossTonnageBuilder),
      line('Netong bigat (Net Tonnage) N.T.:', b.netTonnageBuilder),
      line('Kailan natapos o ipinalaot (Date Finished/Launched):',
          b.dateFinishedLaunched),
      line('Bilang ng gamit pangkaligtasan (Life Vest/Jacket):', b.lifeVests),
      pw.SizedBox(height: 6),
      pw.Center(
        child: pw.Text(
          'PAGKAKAKILANLAN NG MAKINA',
          style: h(),
          textAlign: pw.TextAlign.center,
        ),
      ),
      line('Uri ng Makina:', b.engineType),
      line('Lakas at Modelo (HP & MODEL):', b.horsepowerModel),
      line('Serial Number:', b.serialNumber),
      line('Petsang Ginawa:', b.dateManufactured),
      line('Ilang Silindro:', b.numberOfCylinders),
      line('Bore at Stroke:', b.boreStroke),
      line('R.P.M:', b.rpm),
      line('Ilang Makina:', b.numberOfEngines),
      line('Ilang Turnilyo / Screw (propellers):', b.numberOfPropellers),
      line('Petsa at lugar na inisyu (Date & place issued):', b.datePlaceIssued),
      pw.SizedBox(height: 8),
      pw.Text('PANGALAN AT LAGDA NG GUMAWA', style: h(), textAlign: pw.TextAlign.center),
      line('Lagda / pangalan (Builder\'s signature):', b.builderSignature),
      pw.SizedBox(height: 6),
      line('Prepared By:', b.preparedBy),
      pw.SizedBox(height: 6),
      pw.Text(
        'Sumumpa sa harap ko, ngayong ika-${b.oathDay} ng ${b.oathMonth} ${b.oathYear.isNotEmpty ? b.oathYear : ''}.${b.oathDate.isNotEmpty ? ' (${b.oathDate})' : ''}',
        style: small(),
        textAlign: pw.TextAlign.justify,
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        'Katibayan ng paninirahan — BLG. ${b.residenceCertBlg}; na iginawad: ${b.residenceCertIssued}; sa ${b.residenceCertPlace}.',
        style: small(),
      ),
      if (b.residenceCertDetails.isNotEmpty)
        pw.Text(b.residenceCertDetails, style: small()),
      pw.SizedBox(height: 12),
      pw.Text(
        '(Applicant / pangkalahatang datos mula sa form: ${b.applicantName}, ${b.contactNumber}. Inspektor: ${b.inspectorName}. Petsa ng isyu: ${b.issuedDate}.)',
        style: const pw.TextStyle(fontSize: 7),
      ),
    ];
  }

  static pw.Widget _buildContent(CertificateModel cert) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Control number top right
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(cert.controlNumber, style: const pw.TextStyle(fontSize: 12)),
          ],
        ),
        pw.SizedBox(height: 8),

        // Centered header
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('Republic of the Philippines',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text('City Government of Puerto Princesa',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Office of the City Environment and Natural Resources Officer',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('ENVIRONMENTAL LAW ENFORCEMENT DIVISION (ELED)',
                  style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Bantay Dagat Section',
                  style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
        pw.SizedBox(height: 24),

        // Large centered title
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text('CERTIFICATE OF INSPECTION',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('(Marine Products)', style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
        ),
        pw.SizedBox(height: 24),

        // Main body
        pw.Text('TO WHOM IT MAY CONCERN:',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),

        pw.RichText(
          text: pw.TextSpan(
            children: [
              const pw.TextSpan(text: 'THIS IS TO CERTIFY that Mr. / Ms. '),
              pw.TextSpan(
                text: cert.applicantName,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              const pw.TextSpan(text: ' of '),
              pw.TextSpan(
                text: cert.applicantAddress,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              const pw.TextSpan(
                  text:
                      ' Puerto Princesa City has been inspected by Bantay Dagat and hereby endorsing his/her request for approval and issuance of Mayor\'s Permit to operate/engage in the business of:'),
            ],
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.SizedBox(height: 16),

        // License type
        pw.Row(
          children: [
            pw.Text(cert.licenseType == 'New' ? '(X)' : '( )',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(width: 4),
            pw.Text('New', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(width: 12),
            pw.Text(cert.licenseType == 'Renew' ? '(X)' : '( )',
                style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(width: 4),
            pw.Text('Renew', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
        pw.SizedBox(height: 12),

        pw.Text('KIND OF LICENSE APPLIED : BUSINESS PERMIT',
            style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 8),

        pw.Text('NATURE OF BUSINESS : ${cert.natureOfBusiness}',
            style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 8),

        pw.Row(
          children: [
            pw.Text('BUSINESS ADDRESS : ',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Expanded(
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5),
                  ),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(cert.businessAddress,
                      style: const pw.TextStyle(fontSize: 10)),
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),

        pw.Row(
          children: [
            pw.Text('NAME OF BUSINESS : ',
                style: const pw.TextStyle(fontSize: 10)),
            pw.Expanded(
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5),
                  ),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 2),
                  child: pw.Text(cert.businessName,
                      style: const pw.TextStyle(fontSize: 10)),
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),

        pw.Text(
          'FURTHER CERTIFY that the above described business including the proposed location or area, prior to approval, does not pose any destruction/obstruction to the Ecological and Marine Resources of the City.',
          style: const pw.TextStyle(fontSize: 10),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 24),

        pw.Text('Issued this ${cert.issuedDate}.',
            style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 16),

        pw.Text('Conformed:',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 24),

        // Signature line
        pw.Container(
          width: 200,
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 1),
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text('(Signature over Printed Name) Owner/Representative',
            style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 8),

        pw.Text('Contact No. ${cert.contactNumber}',
            style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 12),

        pw.Text('Inspected by: ${cert.inspectorName}',
            style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 32),

        // Approved By section - right aligned
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Approved by:',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold)),
                pw.Text('BY AUTHORITY OF THE CITY ENRO:',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text(_approvedByName,
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Text(_approvedByTitle, style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
        pw.Spacer(),

        // Footer
        pw.Divider(thickness: 0.5),
        pw.SizedBox(height: 8),
        pw.Text(
            'Ground Floor, Old City Hall Building, Bgy. Sta. Monica, Puerto Princesa City',
            style: const pw.TextStyle(fontSize: 8)),
        pw.Text('bantaydagat.ppc@gmail.com', style: const pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}
