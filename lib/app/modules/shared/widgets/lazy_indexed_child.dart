import 'package:flutter/material.dart';

/// Widget wrapper untuk content di IndexedStack
/// Content di-build langsung saat pertama kali agar semua tab siap
/// State tetap preserved dengan AutomaticKeepAliveClientMixin
class LazyIndexedChild extends StatefulWidget {
  final Widget Function() builder;
  final bool isActive;
  
  const LazyIndexedChild({
    super.key,
    required this.builder,
    required this.isActive,
  });
  
  @override
  State<LazyIndexedChild> createState() => _LazyIndexedChildState();
}

class _LazyIndexedChildState extends State<LazyIndexedChild> 
    with AutomaticKeepAliveClientMixin {
  
  late final Widget _child;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Build immediately so all tabs are ready when user switches
    _child = widget.builder();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return _child;
  }
}
