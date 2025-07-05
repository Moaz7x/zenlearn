import 'package:flutter/material.dart';

/// A skeleton loading widget for notes
class SkeletonLoadingWidget extends StatefulWidget {
  final int itemCount;
  final EdgeInsets? padding;

  const SkeletonLoadingWidget({
    super.key,
    this.itemCount = 5,
    this.padding,
  });

  @override
  State<SkeletonLoadingWidget> createState() => _SkeletonLoadingWidgetState();
}

class _SkeletonLoadingWidgetState extends State<SkeletonLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: widget.padding ?? const EdgeInsets.all(16),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: _buildSkeletonCard(),
            );
          },
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            _buildSkeletonLine(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 20,
            ),
            const SizedBox(height: 12),
            
            // Content skeleton lines
            _buildSkeletonLine(
              width: double.infinity,
              height: 14,
            ),
            const SizedBox(height: 8),
            _buildSkeletonLine(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 14,
            ),
            const SizedBox(height: 8),
            _buildSkeletonLine(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 14,
            ),
            const SizedBox(height: 16),
            
            // Tags skeleton
            Row(
              children: [
                _buildSkeletonChip(),
                const SizedBox(width: 8),
                _buildSkeletonChip(),
                const SizedBox(width: 8),
                _buildSkeletonChip(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLine({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300]?.withOpacity(_animation.value),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSkeletonChip() {
    return Container(
      width: 60,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey[300]?.withOpacity(_animation.value),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// A compact skeleton loading widget for search results
class CompactSkeletonWidget extends StatefulWidget {
  final int itemCount;

  const CompactSkeletonWidget({
    super.key,
    this.itemCount = 3,
  });

  @override
  State<CompactSkeletonWidget> createState() => _CompactSkeletonWidgetState();
}

class _CompactSkeletonWidgetState extends State<CompactSkeletonWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.itemCount, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Icon skeleton
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300]?.withOpacity(_animation.value),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Content skeleton
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]?.withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]?.withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

/// A grid skeleton loading widget
class GridSkeletonWidget extends StatefulWidget {
  final int itemCount;
  final int crossAxisCount;

  const GridSkeletonWidget({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  State<GridSkeletonWidget> createState() => _GridSkeletonWidgetState();
}

class _GridSkeletonWidgetState extends State<GridSkeletonWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300]?.withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300]?.withOpacity(_animation.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey[300]?.withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
