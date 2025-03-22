import 'package:flutter/material.dart';

import '../utils/theme.dart';
import '../utils/constants.dart';

class BadgeIcon extends StatelessWidget {
  final String badgeType;
  final double size;
  
  const BadgeIcon({
    Key? key,
    required this.badgeType,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.eco,
      color: _getBadgeColor(),
      size: size,
    );
  }
  
  Color _getBadgeColor() {
    switch (badgeType) {
      case 'orange':
        return AppColors.orangeBadge;
      case 'green':
        return AppColors.greenBadge;
      default:
        return Colors.grey;
    }
  }
}

class VerifiedFarmerBadge extends StatelessWidget {
  final String badgeType;
  final double size;
  
  const VerifiedFarmerBadge({
    Key? key,
    required this.badgeType,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.25),
      decoration: BoxDecoration(
        color: _getBadgeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(size),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.eco,
            color: _getBadgeColor(),
            size: size * 0.8,
          ),
          SizedBox(width: size * 0.3),
          Text(
            'Verified Organic',
            style: TextStyle(
              color: _getBadgeColor(),
              fontWeight: FontWeight.bold,
              fontSize: size * 0.6,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getBadgeColor() {
    switch (badgeType) {
      case 'orange':
        return AppColors.orangeBadge;
      case 'green':
        return AppColors.greenBadge;
      default:
        return Colors.grey;
    }
  }
}
