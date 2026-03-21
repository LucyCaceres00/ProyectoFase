import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app_theme.dart';

class SelectorImagenesResena extends StatelessWidget {
  final List<XFile> imagenes;
  final VoidCallback onAgregar;
  final ValueChanged<int> onEliminar;

  const SelectorImagenesResena({
    super.key,
    required this.imagenes,
    required this.onAgregar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (imagenes.length < 5)
            GestureDetector(
              onTap: onAgregar,
              child: Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.colorBorde),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_photo_alternate_rounded, color: AppTheme.primaryColor, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${imagenes.length}/5',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textoSuave),
                    ),
                  ],
                ),
              ),
            ),
          ...imagenes.asMap().entries.map((entry) {
            final i = entry.key;
            final img = entry.value;
            return Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(File(img.path), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 14,
                  child: GestureDetector(
                    onTap: () => onEliminar(i),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
