import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pixcellz/ui/widgets/pixcellz_appbar.dart';
import 'dart:html' as html;
import 'dart:convert';

class PixCellZPage extends StatelessWidget {
  final Map<String, dynamic> pixCellZData;

  const PixCellZPage({super.key, required this.pixCellZData});

  @override
  Widget build(BuildContext context) {
    final userId = pixCellZData['pixcell']['userId'];
    final creationDate = DateTime.fromMillisecondsSinceEpoch(
      pixCellZData['pixcell']['creationDate'],
    );
    final formattedDate =
        DateFormat('dd MMMM yyyy', 'fr_FR').format(creationDate);
    final pixelMatrix =
        pixCellZData['pixcell']['data'] as List<List<Map<String, dynamic>>>;

    final svgContent = _generateSvg(pixelMatrix);

    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: const PixCellZAppBar(
        title: "Détails du Pixel Art",
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle, size: 32, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "User ID: $userId",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 32, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "Créé le : $formattedDate",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Expanded(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: SvgPicture.string(
                        svgContent,
                        width: 320,
                        height: 320,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _generateAndSaveSvg(context, svgContent);
        },
        icon: const Icon(Icons.share),
        label: const Text("Partager"),
        backgroundColor: primaryColor,
      ),
    );
  }

  Future<void> _generateAndSaveSvg(BuildContext context, String svgContent) async {
    try {
      final encodedSvg = Uri.encodeComponent(svgContent);
      final blob = html.Blob([Uint8List.fromList(utf8.encode(svgContent))]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'pixel_art.svg';
      anchor.click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SVG sauvegardé !")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }

  String _generateSvg(List<List<Map<String, dynamic>>> matrix) {
    const pixelSize = 10;
    final buffer = StringBuffer();

    buffer.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${matrix[0].length * pixelSize} ${matrix.length * pixelSize}">',
    );

    for (int y = 0; y < matrix.length; y++) {
      for (int x = 0; x < matrix[y].length; x++) {
        final pixel = matrix[y][x];
        final color = 'rgb(${pixel['r']},${pixel['g']},${pixel['b']})';
        buffer.writeln(
          '<rect x="${x * pixelSize}" y="${y * pixelSize}" width="$pixelSize" height="$pixelSize" fill="$color" />',
        );
      }
    }

    buffer.writeln('</svg>');

    return buffer.toString();
  }
}
