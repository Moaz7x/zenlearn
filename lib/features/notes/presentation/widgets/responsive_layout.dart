import 'package:flutter/material.dart';

/// Responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.tabletBreakpoint = 768,
    this.desktopBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth >= desktopBreakpoint) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= tabletBreakpoint) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        // Use GridView.builder for better performance with large lists
        if (children.length > 20) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: runSpacing,
            ),
            itemCount: children.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            cacheExtent: 500, // Cache for smooth scrolling
            itemBuilder: (context, index) => children[index],
          );
        }

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

/// Responsive layout helper that adapts to different screen sizes
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.tabletBreakpoint = 768,
    this.desktopBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive padding that adapts to screen size
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final double tabletBreakpoint;
  final double desktopBreakpoint;

  const ResponsivePadding({
    super.key,
    required this.child,
    required this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.tabletBreakpoint = 768,
    this.desktopBreakpoint = 1024,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        EdgeInsets padding;
        if (constraints.maxWidth >= desktopBreakpoint) {
          padding = desktopPadding ?? tabletPadding ?? mobilePadding;
        } else if (constraints.maxWidth >= tabletBreakpoint) {
          padding = tabletPadding ?? mobilePadding;
        } else {
          padding = mobilePadding;
        }

        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

/// Screen size helper utilities
class ScreenSize {
  /// Get appropriate column count for grid layouts
  static int getGridColumns(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    if (isDesktop(context)) {
      return desktopColumns;
    } else if (isTablet(context)) {
      return tabletColumns;
    } else {
      return mobileColumns;
    }
  }

  /// Get appropriate padding for different screen sizes
  static EdgeInsets getResponsivePadding(BuildContext context, {
    EdgeInsets mobile = const EdgeInsets.all(16),
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }
}
