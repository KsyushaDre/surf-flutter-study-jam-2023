import 'package:flutter/material.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class ViewFilePage extends StatelessWidget {
  final String path;

  const ViewFilePage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: PdfView(path: path),
    );
  }
}
