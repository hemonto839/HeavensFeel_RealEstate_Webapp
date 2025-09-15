// import 'package:flutter/material.dart';

// class HoverMenuButton extends StatefulWidget {
//   final String label;
//   final List<String> items;
//   final void Function(String)? onSelected;

//   // ✅ Styling options
//   final TextStyle? buttonTextStyle;
//   final ButtonStyle? buttonStyle;

//   // ✅ Popup menu styling
//   final String? menuTitle;
//   final TextStyle? menuTitleStyle;
//   final BoxDecoration? menuDecoration;

//   // ✅ NEW configurable properties
//   final TextStyle? menuItemTextStyle;
//   final double? menuElevation;        // <--- NEW
//   final ShapeBorder? menuShape;
  
//   final dynamic onPressed;       // <--- NEW

//   const HoverMenuButton({
//     super.key,
//     required this.label,
//     required this.items,
//     this.onSelected,
//     this.buttonTextStyle,
//     this.buttonStyle,
//     this.menuTitle,
//     this.menuTitleStyle,
//     this.menuDecoration,
//     this.menuItemTextStyle,
//     this.menuElevation,  // 👈
//     this.menuShape,
//     this.onPressed,      // 👈
//   });

//   @override
//   State<HoverMenuButton> createState() => _HoverMenuButtonState();
// }

// class _HoverMenuButtonState extends State<HoverMenuButton> {
//   final LayerLink _layerLink = LayerLink();
//   OverlayEntry? _overlayEntry;

//   bool _isHoveredButton = false;
//   bool _isHoveredMenu = false;

//   bool get _keepMenuOpen => _isHoveredButton || _isHoveredMenu;

//   void _showMenu() {
//     if (_overlayEntry != null) return;

//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         width: 200,
//         child: CompositedTransformFollower(
//           offset: const Offset(0, 40),
//           link: _layerLink,
//           showWhenUnlinked: false,
//           child: MouseRegion(
//             onEnter: (_) {
//               setState(() => _isHoveredMenu = true);
//             },
//             onExit: (_) {
//               setState(() => _isHoveredMenu = false);
//               _scheduleClose();
//             },
//             child: Material(
//               // use provided elevation OR default
//               elevation: widget.menuElevation ?? 6,
//               color: Colors.transparent, // don’t override background
//               shape: widget.menuShape ??
//                 RoundedRectangleBorder(
//                   borderRadius: widget.menuDecoration?.borderRadius is BorderRadius
//                       ? widget.menuDecoration!.borderRadius as BorderRadius
//                       : BorderRadius.circular(8),
//                 ),
//               child: Container(
//                 decoration: widget.menuDecoration ??
//                   BoxDecoration(
//                     // color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     if (widget.menuTitle != null)
//                       Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Text(
//                           widget.menuTitle!,
//                           style: widget.menuTitleStyle ??
//                             const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                         ),
//                       ),
//                     // if (widget.menuTitle != null) const Divider(height: 1),
//                     ...widget.items.map(
//                       (item) => InkWell(
//                         onTap: () {
//                           widget.onSelected?.call(item);
//                           _removeMenu();
//                         },
//                         child: Container(
//                           alignment: Alignment.centerLeft,
//                           padding:
//                             const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                           child: Text(
//                             item,
//                             style: widget.menuItemTextStyle ??
//                               const TextStyle(
//                                 fontSize: 14,
//                                 // color: Colors.black87,
//                               ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//     Overlay.of(context).insert(_overlayEntry!);
//   }

//   void _removeMenu() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//   }

//   void _scheduleClose() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (!_keepMenuOpen) {
//         _removeMenu();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CompositedTransformTarget(
//       link: _layerLink,
//       child: MouseRegion(
//         onEnter: (_) {
//           _isHoveredButton = true;
//           if (_overlayEntry == null) _showMenu();
//         },
//         onExit: (_) {
//           _isHoveredButton = false;
//           _scheduleClose();
//         },
//         child: TextButton(
//           style: widget.buttonStyle ??
//             TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               // backgroundColor: Colors.transparent,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(6),
//               ),
//             ),
//           onPressed: () {
//             if (_overlayEntry != null) {
//               _removeMenu();
//               widget.onPressed?.call();
//             } else {
//               _showMenu();
//             }
//           },
//           child: Text(
//             widget.label,
//             style: widget.buttonTextStyle ??
//               const TextStyle(
//                 // color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class HoverMenuButton extends StatefulWidget {
  final String label;
  final List<String> items;
  final void Function(String)? onSelected;

  // Customization (optional)
  final TextStyle? buttonTextStyle;
  final ButtonStyle? buttonStyle;

  final String? menuTitle;
  final TextStyle? menuTitleStyle;
  final BoxDecoration? menuDecoration;

  final TextStyle? menuItemTextStyle;
  final double? menuElevation;
  final ShapeBorder? menuShape;

  final VoidCallback? onPressed;

  const HoverMenuButton({
    super.key,
    required this.label,
    required this.items,
    this.onSelected,
    this.buttonTextStyle,
    this.buttonStyle,
    this.menuTitle,
    this.menuTitleStyle,
    this.menuDecoration,
    this.menuItemTextStyle,
    this.menuElevation,
    this.menuShape,
    this.onPressed,
  });

  @override
  State<HoverMenuButton> createState() => _HoverMenuButtonState();
}

class _HoverMenuButtonState extends State<HoverMenuButton> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  bool _isHoveredButton = false;
  bool _isHoveredMenu = false;

  bool get _keepMenuOpen => _isHoveredButton || _isHoveredMenu;

  void _showMenu() {
    if (_overlayEntry != null) return;

    final theme = Theme.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          offset: const Offset(0, 40),
          link: _layerLink,
          showWhenUnlinked: false,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHoveredMenu = true),
            onExit: (_) {
              setState(() => _isHoveredMenu = false);
              _scheduleClose();
            },
            child: Material(
              elevation: widget.menuElevation ?? theme.cardTheme.elevation ?? 6,
              color: Colors.transparent,
              shape: widget.menuShape ??
                  theme.cardTheme.shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
              child: Container(
                decoration: widget.menuDecoration ??
                    BoxDecoration(
                      color: theme.cardColor, // use theme card color
                      borderRadius: BorderRadius.circular(8),
                    ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.menuTitle != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          widget.menuTitle!,
                          style: widget.menuTitleStyle ??
                              theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ...widget.items.map(
                      (item) => InkWell(
                        onTap: () {
                          
                          widget.onSelected?.call(item);
                          _removeMenu();
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          child: Text(
                            item,
                            style: widget.menuItemTextStyle ??
                                theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _scheduleClose() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_keepMenuOpen) _removeMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          _isHoveredButton = true;
          if (_overlayEntry == null) _showMenu();
        },
        onExit: (_) {
          _isHoveredButton = false;
          _scheduleClose();
        },
        child: TextButton(
          style: widget.buttonStyle ??
              theme.textButtonTheme.style ?? //  fallback to themed text button
              TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
          onPressed: () {
            if (_overlayEntry != null) {
              _removeMenu();
              widget.onPressed?.call();
            } else {
              _showMenu();
            }
          },
          child: Text(
            widget.label,
            style: widget.buttonTextStyle ??
                theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}