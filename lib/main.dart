import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ParticleLetterA(),
  ));
}

class ParticleLetterA extends StatefulWidget {
  @override
  _ParticleLetterAState createState() => _ParticleLetterAState();
}

class _ParticleLetterAState extends State<ParticleLetterA>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<Particle> particles = [];
  final int maxParticles = 200;
  late Size screenSize;
  double hue = 0;

  final List<Offset> shapePoints = [];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      setState(() {
        hue += 0.5;
        for (var p in particles) {
          p.update();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
    _initializeParticles();
    _ticker.start();
  }

  void _initializeParticles() {
    shapePoints.clear();
    shapePoints.addAll([
      Offset(screenSize.width * 0.4, screenSize.height * 0.8),
      Offset(screenSize.width * 0.5, screenSize.height * 0.2),
      Offset(screenSize.width * 0.6, screenSize.height * 0.8),
      Offset(screenSize.width * 0.45, screenSize.height * 0.5),
      Offset(screenSize.width * 0.55, screenSize.height * 0.5)
    ]);

    particles.clear();
    for (int i = 0; i < maxParticles; i++) {
      particles.add(Particle(screenSize, shapePoints, hue));
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPaint(
        painter: ParticlePainter(particles),
        child: Container(),
      ),
    );
  }
}

class Particle {
  late Offset position;
  late Offset target;
  late double velocity;
  late double size;
  double hue;
  final Random random = Random();

  Particle(Size screenSize, List<Offset> shapePoints, this.hue) {
    position = Offset(
      screenSize.width * random.nextDouble(),
      screenSize.height * random.nextDouble(),
    );
    velocity = random.nextDouble() * 2 + 0.5;
    size = random.nextDouble() * 3 + 2;
    target = shapePoints[random.nextInt(shapePoints.length)];
  }

  void update() {
    double dx = target.dx - position.dx;
    double dy = target.dy - position.dy;
    double angle = atan2(dy, dx);
    position = Offset(
      position.dx + velocity * cos(angle),
      position.dy + velocity * sin(angle),
    );
  }
}

class ParticlePainter extends CustomPainter {
  List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var p in particles) {
      paint.color = HSLColor.fromAHSL(1, p.hue, 1, 0.5).toColor();
      canvas.drawCircle(p.position, p.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
