import 'package:flutter/material.dart';

class CustomCheckIcon extends StatefulWidget {
  final Color color;
  final double size;

  const CustomCheckIcon({super.key, this.color = Colors.black, this.size = 22});

  @override
  State<CustomCheckIcon> createState() => _CustomCheckIconState();
}

class _CustomCheckIconState extends State<CustomCheckIcon>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 350),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axis: Axis.horizontal,
      axisAlignment: -1,
      child: Center(
        child: Icon(
          Icons.check_rounded,
          color: widget.color,
          size: widget.size,
        ),
      ),
    );
  }
}
