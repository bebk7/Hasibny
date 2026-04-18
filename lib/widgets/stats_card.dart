import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // استخدام لون البطاقة كخلفية خفيفة جداً لإعطاء هوية بصرية
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
        child: Container(
          padding: EdgeInsets.all(Responsive.isSmall(context) ? 12 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة بخلفية دائرية ملونة
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: Responsive.isSmall(context) ? 20 : 24,
                ),
              ),
              const SizedBox(height: 12),
              // القيمة الرقمية بلون البطاقة الصريح
              Text(
                value,
                style: TextStyle(
                  color: color.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w900,
                  fontSize: Responsive.isSmall(context) ? 20 : 24,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
