import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:office_app/models/asset_model.dart';

class PdfService {
  static Future<void> generateAndDownloadPdf(AssetRecord record) async {
    final pdf = pw.Document();
    final DateFormat formatter = DateFormat('MMM dd, yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Office Asset Management',
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Asset Allocation Record',
                          style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${formatter.format(DateTime.now())}',
                          style: const pw.TextStyle(fontSize: 12)),
                      pw.Text('ID: ${record.companyId}',
                          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            _buildSection('Employee Information', [
              _buildRow('Company ID', record.companyId),
              _buildRow('Employee Name', record.employeeName),
              _buildRow('Department', record.employeeDepartment),
              _buildRow('Email', record.employeeEmail),
              _buildRow('Contact', record.employeeContact),
              _buildRow('Work From', record.workFrom),
              _buildRow('Office Location', record.officeLocation),
            ]),

            _buildSection('Asset Ownership', [
              _buildRow('Asset Status', record.assetStatus),
              _buildRow('Purchase/Rent', record.purchaseOrRent),
            ]),

            _buildSection('Laptop Details', [
              _buildRow('Brand', record.laptopBrand),
              _buildRow('Model No', record.laptopModelNo),
              _buildRow('Serial No', record.laptopSerialNo),
              _buildRow('Configuration', record.configuration),
              _buildRow('Host Name', record.computerHostName),
              _buildRow('Issue Date',
                  record.laptopIssueDate != null ? formatter.format(record.laptopIssueDate!) : 'N/A'),
              _buildRow('Expiry Date',
                  record.laptopExpiryDate != null ? formatter.format(record.laptopExpiryDate!) : 'N/A'),
            ]),

            _buildSection('Hardware & Peripherals', [
              _buildRow('Screen Brand', record.screenCompany),
              _buildRow('Screen Serial No', record.screenSerialNo),
              _buildRow('Headphone Serial No', record.headphoneSerialNo),
              _buildRow('Mouse Serial No', record.mouseSerialNo),
              _buildRow('Keyboard Serial No', record.keyboardSerialNo),
              _buildRow('Charger Serial No', record.chargerSerialNo),
            ]),

            _buildSection('Connectivity & Extras', [
              _buildRow('WiFi MAC Address', record.wifiMacAddress),
              _buildRow('Data Card No', record.dataCardNo),
              _buildRow('Desk No', record.deskNo),
            ]),

            _buildSection('Corporate Asset Info', [
              _buildRow('Corporate Asset Name', record.companyAssetName),
              _buildRow('HDFC Item ID', record.hdfcItemIdName),
              _buildRow('Asset Number', record.assetNumber),
              _buildRow('Asset Issue Date',
                  record.assetIssueDate != null ? formatter.format(record.assetIssueDate!) : 'N/A'),
            ]),

            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Authorized Signature',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 40),
                    pw.Container(width: 150, height: 1, color: PdfColors.black),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Employee Signature',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 40),
                    pw.Container(width: 150, height: 1, color: PdfColors.black),
                  ],
                ),
              ],
            ),
            pw.Footer(
              margin: const pw.EdgeInsets.only(top: 20),
              trailing: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Asset_Record_${record.companyId}.pdf',
    );
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
          pw.Divider(thickness: 0.5),
          ...children,
        ],
      ),
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
          pw.Expanded(
              child: pw.Text(value.isNotEmpty ? value : 'N/A',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }
}
