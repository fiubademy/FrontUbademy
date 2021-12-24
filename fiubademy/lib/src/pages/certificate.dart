import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';

class CertificatePage extends StatefulWidget {
  final String courseTitle;
  final double mark;

  const CertificatePage(
      {Key? key, required this.mark, required this.courseTitle})
      : super(key: key);

  @override
  _CertificatePageState createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  String? _name;
  bool _fetchingName = false;

  String markName(double number) {
    int mark = number.round();
    switch (mark) {
      case 10:
        return 'Outstanding 10 (ten)';
      case 9:
        return 'Honorific 9 (nine)';
      case 8:
        return 'Honorific 8 (eight)';
      case 7:
        return '7 (seven)';
      case 6:
        return '6 (six)';
      default:
        return '';
    }
  }

  String todaysDate() {
    DateTime today = DateTime.now();
    return '${today.day}/${today.month}/${today.year}';
  }

  Future<Uint8List> generateCertificate() async {
    final ubademy = pw.MemoryImage(
      (await rootBundle.load('images/certificate.png')).buffer.asUint8List(),
    );
    final font =
        pw.Font.ttf(await rootBundle.load('fonts/ImperialScript-Regular.ttf'));

    String description = '${markName(widget.mark)} in ${widget.courseTitle}';
    String date = todaysDate();

    final pdf = pw.Document();

    final Size nameSize = (TextPainter(
            text: TextSpan(
              text: _name,
              style: const TextStyle(
                fontFamily: 'Imperial Script',
                fontStyle: FontStyle.italic,
                fontSize: 70,
              ),
            ),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;

    final Size descriptionSize = (TextPainter(
            text: TextSpan(
              text: description,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;

    final Size dateSize = (TextPainter(
            text: TextSpan(
              text: date,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;

    pdf.addPage(
      pw.Page(
          build: (context) => pw.Stack(
                children: [
                  pw.Positioned(
                    left: 550 - (nameSize.width / 2),
                    top: 220 - (nameSize.height / 2),
                    child: pw.Text(
                      _name ?? '',
                      style: pw.TextStyle(
                        font: font,
                        fontStyle: pw.FontStyle.italic,
                        fontSize: 70,
                      ),
                    ),
                  ),
                  pw.Positioned(
                    left: 550 - (descriptionSize.width / 2),
                    top: 275 - (descriptionSize.height / 2),
                    child: pw.Text(
                      description,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Positioned(
                    left: 385 - (dateSize.width / 2),
                    top: 485 - (dateSize.height / 2),
                    child: pw.Text(
                      date,
                      style: const pw.TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
          pageTheme: pw.PageTheme(
              pageFormat:
                  const PdfPageFormat(841.8897637795275, 595.275590551181),
              buildBackground: (context) => pw.FullPage(
                    ignoreMargins: true,
                    child: pw.Image(ubademy),
                  ))),
    );

    return pdf.save();
  }

  Future<String?> askName() async {
    _fetchingName = true;
    return showDialog<String>(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        final controller = TextEditingController();

        return AlertDialog(
          title: const Text('Please type your full name:'),
          content: TextField(
            decoration: const InputDecoration(
              hintText: 'Full Name',
            ),
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text != '') {
                  Navigator.pop(context, controller.text);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PdfPreview(
              pdfFileName: 'certificate.pdf',
              canDebug: false,
              canChangePageFormat: false,
              build: (_) {
                if (_name == null && !_fetchingName) {
                  askName().then((value) {
                    if (value != null) {
                      setState(() {
                        _name = value;
                      });
                    }
                  });
                }
                return generateCertificate();
              },
            ),
          ),
        ],
      ),
    );
  }
}
