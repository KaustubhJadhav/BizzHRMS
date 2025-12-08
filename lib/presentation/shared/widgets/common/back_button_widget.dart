import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A reusable back button widget with page title
/// Displays a back arrow icon and page title below the header
class BackButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final double? fontSize;

  const BackButtonWidget({
    super.key,
    required this.title,
    this.onBackPressed,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Arrow Icon
          IconButton(
            icon: Icon(
              FontAwesomeIcons.arrowLeft,
              color: iconColor ?? const Color(0xFF2C3E50),
              size: iconSize ?? 20,
            ),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          // Page Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor ?? const Color(0xFF2C3E50),
                fontSize: fontSize ?? 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

