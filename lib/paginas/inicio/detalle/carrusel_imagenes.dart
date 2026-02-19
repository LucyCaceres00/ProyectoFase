import 'package:flutter/material.dart';

class CarruselImagenes extends StatefulWidget {
  final List<String> imagenes;
  final int indiceInicial;
  const CarruselImagenes({super.key, required this.imagenes, required this.indiceInicial});

  @override
  State<CarruselImagenes> createState() => _CarruselImagenesState();
}

class _CarruselImagenesState extends State<CarruselImagenes> {
  late PageController _controller;
  late int _actual;

  @override
  void initState() {
    super.initState();
    _actual = widget.indiceInicial;
    _controller = PageController(initialPage: widget.indiceInicial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imagenes.length,
            onPageChanged: (i) => setState(() => _actual = i),
            itemBuilder: (_, i) => InteractiveViewer(
              child: Image.network(
                widget.imagenes[i],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 60),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imagenes.length, (i) {
                final activo = i == _actual;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: activo ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: activo ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_actual + 1} / ${widget.imagenes.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
