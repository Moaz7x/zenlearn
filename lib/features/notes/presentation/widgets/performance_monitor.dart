import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Result of a performance benchmark
class BenchmarkResult<T> {
  final T data;
  final Duration duration;
  final String operationName;

  BenchmarkResult({
    required this.data,
    required this.duration,
    required this.operationName,
  });
}

/// A widget for monitoring frame performance
class FramePerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const FramePerformanceMonitor({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
  });

  @override
  State<FramePerformanceMonitor> createState() => _FramePerformanceMonitorState();
}

/// Types of performance metrics
enum MetricType {
  buildTime,
  memory,
  frameTime,
  networkRequest,
  databaseQuery,
}

/// A widget for benchmarking specific operations
class PerformanceBenchmark<T> extends StatelessWidget {
  final String operationName;
  final Future<T> Function() operation;
  final Widget Function(T result) builder;
  final Widget? loadingWidget;
  final Widget Function(Object error)? errorBuilder;

  const PerformanceBenchmark({
    super.key,
    required this.operationName,
    required this.operation,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BenchmarkResult<T>>(
      future: _runBenchmark(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? const CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          if (kDebugMode) {
            print('Benchmark error for $operationName: ${snapshot.error}');
          }
          return errorBuilder?.call(snapshot.error!) ?? 
                 Text('Error: ${snapshot.error}');
        }
        
        final result = snapshot.data!;
        
        if (kDebugMode) {
          print('Benchmark $operationName completed in ${result.duration.inMilliseconds}ms');
        }
        
        return builder(result.data);
      },
    );
  }

  Future<BenchmarkResult<T>> _runBenchmark() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      return BenchmarkResult(
        data: result,
        duration: stopwatch.elapsed,
        operationName: operationName,
      );
    } catch (e) {
      stopwatch.stop();
      rethrow;
    }
  }
}

/// Performance metric data class
class PerformanceMetric {
  final DateTime timestamp;
  final MetricType type;
  final double value;
  final String label;

  PerformanceMetric({
    required this.timestamp,
    required this.type,
    required this.value,
    required this.label,
  });
}

/// A performance monitoring widget for the notes feature
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final String? label;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
    this.label,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _FramePerformanceMonitorState extends State<FramePerformanceMonitor>
    with TickerProviderStateMixin {
  
  late AnimationController _controller;
  final List<double> _frameTimes = [];
  int _frameCount = 0;

  double get _averageFrameTime {
    if (_frameTimes.length < 2) return 0;
    
    double totalTime = 0;
    for (int i = 1; i < _frameTimes.length; i++) {
      totalTime += _frameTimes[i] - _frameTimes[i - 1];
    }
    
    return totalTime / (_frameTimes.length - 1);
  }

  double get _fps {
    final avgFrameTime = _averageFrameTime;
    return avgFrameTime > 0 ? 1000 / avgFrameTime : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.enabled && kDebugMode)
          Positioned(
            top: 100,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Frame Monitor',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'FPS: ${_fps.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: _fps >= 55 ? Colors.green : 
                             _fps >= 30 ? Colors.yellow : Colors.red,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Frames: $_frameCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    if (widget.enabled) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      );
      _startFrameMonitoring();
    }
  }

  void _recordFrameTime() {
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    _frameTimes.add(now);
    _frameCount++;
    
    // Keep only last 60 frame times (1 second at 60fps)
    if (_frameTimes.length > 60) {
      _frameTimes.removeAt(0);
    }
  }

  void _startFrameMonitoring() {
    _controller.addListener(() {
      _recordFrameTime();
    });
    _controller.repeat();
  }
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  final List<PerformanceMetric> _metrics = [];
  Timer? _memoryTimer;
  int _buildCount = 0;
  DateTime? _lastBuildTime;

  @override
  Widget build(BuildContext context) {
    if (widget.enabled) {
      _recordBuildTime();
    }

    return Stack(
      children: [
        widget.child,
        if (widget.enabled && kDebugMode)
          Positioned(
            top: 50,
            right: 10,
            child: _buildPerformanceOverlay(),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _memoryTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startMonitoring();
    }
  }

  Widget _buildPerformanceOverlay() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Performance Monitor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Builds: $_buildCount',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Metrics: ${_metrics.length}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          if (_metrics.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Last Build: ${_getLastBuildTime()}ms',
              style: const TextStyle(color: Colors.green, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  String _getLastBuildTime() {
    final buildMetrics = _metrics
        .where((m) => m.type == MetricType.buildTime)
        .toList();
    
    if (buildMetrics.isEmpty) return '0';
    
    return buildMetrics.last.value.toStringAsFixed(1);
  }

  void _recordBuildTime() {
    final now = DateTime.now();
    if (_lastBuildTime != null) {
      final buildDuration = now.difference(_lastBuildTime!);
      _metrics.add(PerformanceMetric(
        timestamp: now,
        type: MetricType.buildTime,
        value: buildDuration.inMilliseconds.toDouble(),
        label: 'Build #$_buildCount',
      ));
    }
    _lastBuildTime = now;
    _buildCount++;
  }

  void _recordMemoryUsage() {
    // This is a simplified memory monitoring
    // In a real app, you might use more sophisticated tools
    final now = DateTime.now();
    _metrics.add(PerformanceMetric(
      timestamp: now,
      type: MetricType.memory,
      value: 0, // Would need platform-specific implementation
      label: widget.label ?? 'Notes Feature',
    ));

    // Keep only last 100 metrics
    if (_metrics.length > 100) {
      _metrics.removeAt(0);
    }
  }

  void _startMonitoring() {
    // Monitor memory usage every 5 seconds
    _memoryTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _recordMemoryUsage();
    });
  }
}
