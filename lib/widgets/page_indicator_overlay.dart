import 'package:flutter/material.dart';

class PageIndicatorOverlay extends StatefulWidget {
  final int currentIndex;
  final int pageCount;

  const PageIndicatorOverlay({
    super.key,
    required this.currentIndex,
    required this.pageCount,
  });

  @override
  State<PageIndicatorOverlay> createState() => _PageIndicatorOverlayState();
}

class _PageIndicatorOverlayState extends State<PageIndicatorOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PageIndicatorOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Show indicator when page changes
      _animationController.forward().then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _animationController.reverse();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate responsive sizes
    final dotSize = screenWidth * 0.02;  // 2% of screen width
    final dotSpacing = screenWidth * 0.015;  // 1.5% of screen width
    final containerPaddingH = screenWidth * 0.04;  // 4% of screen width
    final containerPaddingV = screenHeight * 0.01;  // 1% of screen height
    final borderRadius = screenWidth * 0.03;  // 3% of screen width
    final bottomOffset = screenHeight * 0.02;  // 2% of screen height

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomOffset,
      child: FadeTransition(
        opacity: _animation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: containerPaddingH,
                vertical: containerPaddingV,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withAlpha(204),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withAlpha(128),
                  width: screenWidth * 0.002,  // 0.2% of screen width
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.pageCount,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: dotSpacing),
                    child: _buildDot(context, index, dotSize),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.currentIndex == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withAlpha(51),
      ),
    );
  }
}