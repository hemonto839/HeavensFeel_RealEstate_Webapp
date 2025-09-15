import 'package:flutter/material.dart';

class Custombutton extends StatefulWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final IconData? icon;

  // Sizing
  final double? width;
  final double? height;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  // Styling (optional overrides)
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hoverColor;
  final Color? pressedColor;
  final bool isOutlined;
  final FontWeight? fontWeight;

  const Custombutton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.icon,
    this.width,
    this.height = 50,
    this.fontSize = 16,
    this.padding,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    this.hoverColor,
    this.pressedColor,
    this.isOutlined = false,
    this.fontWeight,
  });

  @override
  State<Custombutton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<Custombutton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ✅ Fallbacks to theme colors if not injected
    final bgColor = widget.backgroundColor ?? scheme.primary;
    final txtColor = Colors.white;
    final hoverColor = widget.hoverColor ?? scheme.primaryContainer;
    final pressedColor = widget.pressedColor ?? scheme.primary.withOpacity(0.8);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width ?? double.infinity,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.isOutlined
                ? Colors.transparent
                : _isPressed
                    ? pressedColor
                    : _isHovered
                        ? hoverColor
                        : bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.isOutlined
                ? Border.all(color: bgColor, width: 2)
                : null,
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: scheme.onPrimary.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon,
                      size: widget.fontSize! + 4,
                      color: widget.isOutlined ? bgColor : txtColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.buttonText,
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: widget.fontSize,
                    color: widget.isOutlined ? bgColor : txtColor,
                    fontWeight: widget.fontWeight ?? FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}