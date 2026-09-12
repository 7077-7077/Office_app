import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:office_app/models/asset_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelService {
  /// Helper to extract raw values from CellValue types (excel v4.x compatibility)
  static dynamic _getCellValue(CellValue? cellValue) {
    if (cellValue == null) return null;
    if (cellValue is TextCellValue) return cellValue.value.toString();
    if (cellValue is IntCellValue) return cellValue.value;
    if (cellValue is DoubleCellValue) return cellValue.value;
    if (cellValue is DateCellValue) return DateTime(cellValue.year, cellValue.month, cellValue.day);
    if (cellValue is DateTimeCellValue) return DateTime(cellValue.year, cellValue.month, cellValue.day, cellValue.hour, cellValue.minute);
    if (cellValue is BoolCellValue) return cellValue.value;
    // Default fallback
    return cellValue.toString();
  }

  /// Picks an Excel file and parses it into a list of AssetRecords
  static Future<List<AssetRecord>> pickAndParseExcel() async {
    try {
      debugPrint('Opening File Picker...');
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Crucial for getting bytes directly if path is restricted
      );

      if (result != null) {
        final platformFile = result.files.single;
        Uint8List? bytes = platformFile.bytes;
        
        // If bytes are null (common on some mobile configurations), read from path
        if (bytes == null && platformFile.path != null) {
          bytes = File(platformFile.path!).readAsBytesSync();
        }

        if (bytes == null) {
          debugPrint('Error: Could not retrieve file data (bytes and path are null)');
          return [];
        }

        debugPrint('File picked: ${platformFile.name}, size: ${bytes.length} bytes');
        var excel = Excel.decodeBytes(bytes);
        List<AssetRecord> importedRecords = [];

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table]!;
          debugPrint('Processing sheet: $table, rows: ${sheet.maxRows}');
          
          if (sheet.maxRows < 1) continue;

          // Smart Header Detection: Scan top 10 rows for keywords
          int headerRowIndex = 0;
          int maxMatches = -1;
          List<String> detectedHeaders = [];
          
          final keywords = ['name', 'id', 'model', 'serial', 'brand', 'dept', 'status', 'email', 'contact', 'remark', 'location', 'date'];
          
          for (int r = 0; r < (sheet.maxRows < 10 ? sheet.maxRows : 10); r++) {
            List<String> rowHeaders = [];
            int matches = 0;
            for (var cell in sheet.rows[r]) {
              String val = _getCellValue(cell?.value)?.toString().toLowerCase().trim() ?? '';
              rowHeaders.add(val);
              if (keywords.any((k) => val.contains(k))) matches++;
            }
            if (matches > maxMatches) {
              maxMatches = matches;
              headerRowIndex = r;
              detectedHeaders = rowHeaders;
            }
          }
          
          debugPrint('Smart Header Index: $headerRowIndex (Matches: $maxMatches)');
          debugPrint('Detected Headers (Raw): $detectedHeaders');

          // Parse rows starting from AFTER the detected header row
          int validRows = 0;
          for (int i = headerRowIndex + 1; i < sheet.maxRows; i++) {
            var row = sheet.rows[i];
            Map<String, dynamic> rowData = {};
            
            for (int j = 0; j < row.length; j++) {
              if (j < detectedHeaders.length) {
                var header = detectedHeaders[j];
                if (header.isEmpty) continue;
                rowData[header] = _getCellValue(row[j]?.value);
              }
            }

            if (rowData.isNotEmpty && rowData.values.any((v) => v != null && v.toString().isNotEmpty)) {
              importedRecords.add(AssetRecord.fromMap(rowData));
              validRows++;
            }
          }
          debugPrint('Sheet $table: Parsed $validRows valid records');
        }
        
        debugPrint('Total records imported: ${importedRecords.length}');
        return importedRecords;
      } else {
        debugPrint('User canceled file picker');
      }
    } catch (e) {
      debugPrint('CRITICAL Excel Parsing Error: $e');
      rethrow; // Re-throw so the UI can show the error
    }
    return [];
  }

  /// Exports a list of assets to an Excel file and triggers a Share dialog
  static Future<void> exportToExcel(List<AssetRecord> assets) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Asset Inventory'];
      excel.delete('Sheet1'); // Remove default sheet

      // Define Headers
      List<String> headers = [
        'ID', 'Employee Name', 'Employee ID', 'Employee Department', 
        'Laptop Model', 'Laptop Serial No.', 'Keyboard Serial No.', 
        'Mouse Serial No.', 'Charger Serial No.', 'Company Name', 
        'Laptop Location', 'Remark', 'Date', 'Managed By'
      ];

      // Set Header Style
      for (int i = 0; i < headers.length; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
      }

      // Populate Data
      for (int i = 0; i < assets.length; i++) {
        final r = assets[i];
        final rowIndex = i + 1;
        
        void setCell(int col, dynamic val) {
          var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
          if (val is DateTime) {
            cell.value = DateCellValue(year: val.year, month: val.month, day: val.day);
          } else {
            cell.value = TextCellValue(val?.toString() ?? '');
          }
        }

        setCell(0, r.id);
        setCell(1, r.employeeName);
        setCell(2, r.companyId);
        setCell(3, r.employeeDepartment);
        setCell(4, r.laptopModelNo);
        setCell(5, r.laptopSerialNo);
        setCell(6, r.keyboardSerialNo);
        setCell(7, r.mouseSerialNo);
        setCell(8, r.chargerSerialNo);
        setCell(9, r.companyName);
        setCell(10, r.officeLocation);
        setCell(11, r.remark);
        setCell(12, r.assetIssueDate);
        setCell(13, r.managedByName);
      }

      // Encode and Save
      final bytes = excel.encode();
      if (bytes != null) {
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'Asset_Inventory_$timestamp.xlsx';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        // Share the file
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'IT Asset Inventory Export',
          subject: 'Asset Inventory Export',
        );
      }
    } catch (e) {
      debugPrint('Export Error: $e');
      rethrow;
    }
  }
}
