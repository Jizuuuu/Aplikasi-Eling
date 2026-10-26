import 'package:flutter/material.dart';

class SpeechWaveWidget extends StatefulWidget {
  final bool isListening;
  final double soundLevel;
  final VoidCallback onTap;

  const SpeechWaveWidget({
    super.key,
    required this.isListening,
    required this.soundLevel,
    required this.onTap,
  });

  @override
  State<SpeechWaveWidget> createState() => _SpeechWaveWidgetState();
}

class _SpeechWaveWidgetState extends State<SpeechWaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Ripple Layer (when active)
          if (widget.isListening)
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.purple.withOpacity(0.15),
                    ),
                  ),
                );
              },
            ),

          // Mid Ripple Layer
          if (widget.isListening)
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.25),
              ),
            ),

          // Core Microphone Button
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.isListening
                    ? [const Color(0xFF7C3AED), const Color(0xFFDB2777)]
                    : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.isListening
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFF2563EB))
                      .withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              widget.isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}
