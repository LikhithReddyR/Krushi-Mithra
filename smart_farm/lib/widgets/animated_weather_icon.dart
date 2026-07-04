import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWeatherIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const AnimatedWeatherIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<AnimatedWeatherIcon> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _lightningController;
  
  @override
  void initState() {
    super.initState();
    // Extended to 10 seconds for ultra-smooth, slow drifting/rotating
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _lightningController.dispose();
    super.dispose();
  }

  Widget _buildRainDrop(double progress, double phaseOffset, double xOffset) {
    // Smoothly loop the drop multiple times across the 10-second main controller
    final localProgress = ((progress * 8) + phaseOffset) % 1.0;
    
    // Smooth opacity: fade in fast, fade out slowly
    final opacity = localProgress < 0.2 
        ? (localProgress * 5) 
        : (1.0 - localProgress) * 1.25;
        
    return Positioned(
      top: 5 + (localProgress * widget.size * 0.6),
      left: xOffset,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: 2.5, 
          height: 8, 
          decoration: BoxDecoration(
            color: Colors.blueAccent, 
            borderRadius: BorderRadius.circular(2)
          )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _lightningController]),
      builder: (context, child) {
        
        // --- SUNNY ---
        if (widget.icon == Icons.wb_sunny || widget.icon == Icons.wb_sunny_outlined) {
          // Gentle breathing + slow smooth rotation
          final pulse = 1.0 + (sin(_mainController.value * pi * 8) * 0.05);
          return Transform.scale(
            scale: pulse,
            child: Transform.rotate(
              angle: _mainController.value * 2 * pi,
              child: Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: widget.size),
            ),
          );
        }
        
        // --- NIGHT / CLEAR ---
        if (widget.icon == Icons.nights_stay || widget.icon == Icons.nightlight_round) {
          // Softly pulsing stars
          final pulse1 = sin(_mainController.value * pi * 10) * 1.5;
          final pulse2 = cos(_mainController.value * pi * 8 + 1) * 1.5;
          
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -5,
                right: -10,
                child: Icon(Icons.star, size: 8 + pulse1, color: Colors.white70),
              ),
              Positioned(
                bottom: 0,
                left: -10,
                child: Icon(Icons.star, size: 6 + pulse2, color: Colors.white54),
              ),
              Icon(Icons.nights_stay, color: Colors.indigoAccent.shade100, size: widget.size),
            ],
          );
        }

        // --- RAINY / SHOWERS ---
        if (widget.icon == Icons.umbrella || widget.icon == Icons.grain || widget.icon == Icons.water_drop || widget.icon == Icons.cloudy_snowing) {
          final progress = _mainController.value;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              _buildRainDrop(progress, 0.0, widget.size * 0.25),
              _buildRainDrop(progress, 0.4, widget.size * 0.5),
              _buildRainDrop(progress, 0.8, widget.size * 0.75),
              Icon(Icons.cloud, color: Colors.grey.shade400, size: widget.size),
            ],
          );
        }

        // --- THUNDERSTORM ---
        if (widget.icon == Icons.thunderstorm_outlined || widget.icon == Icons.flash_on) {
          // Smooth fade in/out for lightning instead of sharp popping
          final flashOpacity = _lightningController.value > 0.7 
              ? ((_lightningController.value - 0.7) / 0.3) 
              : 0.0;
              
          return Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.cloud, color: Colors.grey.shade700, size: widget.size),
              Positioned(
                bottom: -5,
                child: Opacity(
                  opacity: flashOpacity.clamp(0.0, 1.0),
                  child: Icon(Icons.flash_on, color: Colors.yellowAccent, size: widget.size * 0.6),
                ),
              ),
            ],
          );
        }

        // --- CLOUDY / FOGGY --- (Default)
        // Extremely smooth multi-layered horizontal drifting + slight bobbing
        final drift1 = sin(_mainController.value * 2 * pi) * 6;
        final drift2 = cos(_mainController.value * 2 * pi) * 4;
        final bob = sin(_mainController.value * 4 * pi) * 2;
        
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(-drift1, bob),
              child: Icon(Icons.cloud, color: Colors.grey.shade300, size: widget.size * 0.85),
            ),
            Transform.translate(
              offset: Offset(drift2, 5 - bob),
              child: Icon(Icons.cloud, color: widget.color.withOpacity(0.9), size: widget.size),
            ),
          ],
        );
      },
    );
  }
}

