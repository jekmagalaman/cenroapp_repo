import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/certificate_model.dart';
import 'file_storage_service.dart';

/// Service for generating Certificate of Inspection PDF documents
class PdfService {
  static const String _approvedByName = 'Cardelar Stevie Angel M. Madriñan';
  static const String _approvedByTitle =
      'CG Assistant Department Head II (Assistant City ENRO)';

  /// Generate PDF and save to device storage
  static Future<String> generatePdf(CertificateModel certificate) async {
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

  static pw.Widget _buildContent(CertificateModel cert) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Control number top right
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(cert.controlNumber, style: pw.TextStyle(fontSize: 12)),
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
                  style: pw.TextStyle(fontSize: 10)),
              pw.Text('ENVIRONMENTAL LAW ENFORCEMENT DIVISION (ELED)',
                  style: pw.TextStyle(fontSize: 10)),
              pw.Text('Bantay Dagat Section',
                  style: pw.TextStyle(fontSize: 10)),
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
              pw.Text('(Marine Products)', style: pw.TextStyle(fontSize: 12)),
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
              pw.TextSpan(text: 'THIS IS TO CERTIFY that Mr. / Ms. '),
              pw.TextSpan(
                text: cert.applicantName,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: ' of '),
              pw.TextSpan(
                text: cert.applicantAddress,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(
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
                decoration: pw.BoxDecoration(
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
                decoration: pw.BoxDecoration(
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
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(width: 1),
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text('(Signature over Printed Name) Owner/Representative',
            style: pw.TextStyle(fontSize: 8)),
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
                pw.Text(_approvedByTitle, style: pw.TextStyle(fontSize: 9)),
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
            style: pw.TextStyle(fontSize: 8)),
        pw.Text('bantaydagat.ppc@gmail.com', style: pw.TextStyle(fontSize: 8)),
      ],
    );
  }
}
