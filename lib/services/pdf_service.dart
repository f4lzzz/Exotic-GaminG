import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/models.dart';

class PdfService {
  static String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _getMonthName(date.month);
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');

    return '$day $month $year $hour:$minute:$second';
  }

  static String _formatDateForFilename(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${year}${month}${day}_${hour}${minute}';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  static String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return months[month - 1];
  }

  static String _formatCurrency(double amount) {
    final intValue = amount.toInt();
    final str = intValue.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(str[i]);
    }

    return 'Rp $buffer';
  }

  static Future<void> cetakRekap({
    required List<TransaksiModel> transaksi,
    required String kasir,
    required String shift,
  }) async {
    if (transaksi.isEmpty) {
      throw Exception('Tidak ada transaksi untuk dicetak');
    }

    final pdf = pw.Document();

    final now = DateTime.now();

    final total = transaksi.fold<double>(
      0,
      (sum, item) => sum + item.harga,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'EXOTIC GAMING & CAFFE',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Laporan Rekap Kasir',
                      style: const pw.TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Dicetak: ${_formatDateTime(now)}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Divider(thickness: 1.5),

              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Kasir : $kasir',
                    style: const pw.TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    'Shift : $shift',
                    style: const pw.TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),

              // HEADER TABLE
              pw.Container(
                color: PdfColors.blueGrey800,
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'No',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        'Menu',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Waktu',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Harga',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // DATA
              ...transaksi.asMap().entries.map((e) {
                final i = e.key;
                final t = e.value;

                return pw.Container(
                  color: i.isEven ? PdfColors.grey100 : PdfColors.white,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          '${i + 1}',
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(
                          t.namaMenu,
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          _formatTime(t.waktu),
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          _formatCurrency(t.harga),
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(thickness: 1),

              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL: ${transaksi.length} transaksi',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    _formatCurrency(total),
                    style: pw.TextStyle(
                      color: PdfColors.blue,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      '--- Terima Kasih ---',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Exotic Gaming & Caffe',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();

    final safeShift = shift.toLowerCase().replaceAll(' ', '_');

    final fileName = 'rekap_${safeShift}_${_formatDateForFilename(now)}.pdf';

    Directory dir;

    // ANDROID
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory()) ??
          await getApplicationDocumentsDirectory();

      // IOS
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();

      // WINDOWS / LINUX / MACOS
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();

      // OTHER
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    // buat folder jika belum ada
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final filePath = '${dir.path}/$fileName';

    final file = File(filePath);

    // simpan file
    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    // buka otomatis
    final result = await OpenFile.open(file.path);

    // cek hasil
    if (result.type != ResultType.done) {
      throw Exception(
        'Gagal membuka file PDF: ${result.message}',
      );
    }
  }

  static Future<void> cetakRekapShift({
    required List<TransaksiModel> transaksi,
    required String kasir,
    required String shift,
  }) async {
    await cetakRekap(
      transaksi: transaksi,
      kasir: kasir,
      shift: shift,
    );
  }
}
