import 'package:flutter/material.dart';

import '../theme.dart';

class SproutCard extends StatelessWidget {
  const SproutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 158,
                  height: 158,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mintDeep,
                  ),
                  child: const CustomPaint(painter: SproutPainter()),
                ),
                const Positioned(
                  left: 18,
                  top: 58,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.sprout,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 8, height: 8),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: AppColors.muted,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Small steps. Real growth.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: AppColors.text,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'One good habit at a time.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SproutPainter extends CustomPainter {
  const SproutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = AppColors.sprout
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leaf = Paint()
      ..color = AppColors.sprout
      ..style = PaintingStyle.fill;

    final origin = Offset(size.width * 0.5, size.height * 0.78);
    final top = Offset(size.width * 0.5, size.height * 0.34);

    final stemPath = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.55,
        top.dx,
        top.dy,
      );
    canvas.drawPath(stemPath, stem);

    _drawLeaf(
      canvas,
      leaf,
      Offset(size.width * 0.5, size.height * 0.48),
      size.width * 0.16,
      size.height * 0.09,
      -0.85,
    );
    _drawLeaf(
      canvas,
      leaf,
      Offset(size.width * 0.5, size.height * 0.42),
      size.width * 0.15,
      size.height * 0.085,
      0.9,
    );
  }

  void _drawLeaf(
    Canvas canvas,
    Paint paint,
    Offset base,
    double width,
    double height,
    double angle,
  ) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(width * 0.55, -height, width, 0)
      ..quadraticBezierTo(width * 0.55, height, 0, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
