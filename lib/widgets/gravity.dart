import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math.dart' as vector;

class GravityController {
  final List<GravityWidgetState> _states = [];

  void _attach(GravityWidgetState state) {
    _states.add(state);
  }

  void _detach(GravityWidgetState state) {
    _states.remove(state);
  }

  void start() {
    for (GravityWidgetState state in _states) {
      final random = Random().nextInt(1000);
      Future.delayed(Duration(milliseconds: random)).whenComplete(
        () {
          if (state.mounted) {
            state._onTap();
          }
        },
      );
    }
  }
}

class GravityWidget extends StatefulWidget {
  final Widget? child;
  final GravityController? controller;

  const GravityWidget({
    this.child,
    this.controller,
    super.key,
  });

  @override
  GravityWidgetState createState() => GravityWidgetState();
}

class GravityWidgetState extends State<GravityWidget>
    with SingleTickerProviderStateMixin {
  bool _hide = false;
  final _key = GlobalKey();
  late AnimationController _animationController;
  OverlayEntry? _entry;

  void _onTap() async {
    if (!mounted || _key.currentContext == null) return;
    RenderRepaintBoundary boundary =
        _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final byteData =
        (await image.toByteData(format: ui.ImageByteFormat.png) as ByteData);
    if (!mounted) return;
    var pngBytes = byteData.buffer.asUint8List();

    final renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _entry?.remove();

    final fullHeight = MediaQuery.of(context).size.height;
    final distance = fullHeight - position.dy;
    const min = 10, max = 40;
    final random = min + Random().nextInt(max - min);
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: position.dy + (_animationController.value * distance),
          left: position.dx,
          width: renderBox.size.width,
          height: renderBox.size.height,
          child: Transform(
            transform: Matrix4.identity()
              ..rotateZ(
                vector.radians(
                  random * _animationController.value,
                ),
              ),
            child: Image.memory(pngBytes),
          ),
        );
      },
    );

    Overlay.of(context)!.insert(_entry!);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      _hide = true;
    });

    final simulation = GravitySimulation(
      position.dy / 10, // acceleration
      0, // starting point
      1, // end point
      0, // starting velocity
    );
    _animationController.animateWith(simulation);
  }

  @override
  void didUpdateWidget(GravityWidget oldWidget) {
    setState(() {
      _hide = false;
    });
    super.didUpdateWidget(oldWidget);
  }

  void _animationListener() {
    if (_animationController.status == AnimationStatus.completed) {
      _entry!.remove();
      _entry = null;
    } else {
      _entry!.markNeedsBuild();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller?._attach(this);
    });
    _animationController = AnimationController(
      vsync: this,
    );
    _animationController.addListener(_animationListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _animationController.removeListener(_animationListener);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !_hide,
      child: RepaintBoundary(
        key: _key,
        child: AbsorbPointer(
          child: widget.child,
        ),
      ),
    );
  }
}
