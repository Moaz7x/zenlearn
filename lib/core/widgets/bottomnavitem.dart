part of 'custom_bottom_navigationbar.dart';

enum AnimationType {
  scale,
  rotation,
  slide,
  bounce,
  pulse,
}

class BottomNavItem {
  final IconData icon;
  final String? label;
  final Color? activeColor;
  final Widget? customIcon;

  const BottomNavItem({
    required this.icon,
    this.label,
    this.activeColor,
    this.customIcon,
  });
}

class FloatingBottomNavBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color backgroundColor;
  final Color selectedColor;

  const FloatingBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.selectedColor = Colors.blue,
  });

  @override
  State<FloatingBottomNavBar> createState() => _FloatingBottomNavBarState();
}

class MorphingBottomNavBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final Function(int) onTap;
  final Color backgroundColor;
  final Color selectedColor;
  final double height;

  const MorphingBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = Colors.black,
    this.selectedColor = Colors.blue,
    this.height = 70,
  });

  @override
  State<MorphingBottomNavBar> createState() => _MorphingBottomNavBarState();
}

class _FloatingBottomNavBarState extends State<FloatingBottomNavBar> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 70,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == widget.currentIndex;
          final isCenter = index == 2; // Assuming 5 items with center at index 2

          return Expanded(
            child: GestureDetector(
              onTap: () => _handleTap(index),
              child: AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  if (isCenter && isSelected) {
                    return Transform.translate(
                      offset: Offset(0, -20 * _floatAnimation.value),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: widget.selectedColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.selectedColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          item.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  }

                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected && !isCenter
                          ? widget.selectedColor.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Icon(
                      item.icon,
                      color: isSelected ? widget.selectedColor : Colors.grey,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _floatAnimation = CurvedAnimation(
      parent: _floatController,
      curve: Curves.elasticOut,
    );
  }

  void _handleTap(int index) {
    _floatController.forward().then((_) {
      _floatController.reverse();
    });
    widget.onTap(index);
  }
}

class _MorphingBottomNavBarState extends State<MorphingBottomNavBar> with TickerProviderStateMixin {
  late AnimationController _morphController;
  late Animation<double> _morphAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildBackground(),
          _buildNavItems(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _morphAnimation,
      builder: (context, child) {
        final itemWidth = MediaQuery.of(context).size.width / widget.items.length;
        final selectedPosition = widget.currentIndex * itemWidth;

        return Positioned(
          left: selectedPosition - 16 + (32 * _morphAnimation.value),
          top: 10,
          child: Container(
            width: 50 + (20 * _morphAnimation.value),
            height: 50,
            decoration: BoxDecoration(
              color: widget.selectedColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isSelected = index == widget.currentIndex;

        return Expanded(
          child: GestureDetector(
            onTap: () => _handleTap(index),
            child: SizedBox(
              height: widget.height,
              child: Center(
                child: AnimatedBuilder(
                  animation: _morphAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? 1.0 + (0.3 * _morphAnimation.value) : 1.0,
                      child: Icon(
                        item.icon,
                        color: isSelected ? Colors.white : Colors.grey,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleTap(int index) {
    _morphController.forward().then((_) {
      widget.onTap(index);
      _morphController.reverse();
    });
  }
}
