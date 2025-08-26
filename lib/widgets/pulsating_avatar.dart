// ** Create this new widget **
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wavelength_clone_fresh/models/avatar.dart';
import 'package:wavelength_clone_fresh/theme/app_theme.dart';

class PulsatingAvatar extends StatefulWidget {
  final String avatarId;
  const PulsatingAvatar({super.key, required this.avatarId});

  @override
  State<PulsatingAvatar> createState() => _PulsatingAvatarState();
}

class _PulsatingAvatarState extends State<PulsatingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true); // This makes the animation loop back and forth

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: CircleAvatar(
        radius: 40,
        backgroundColor: AppColors.primaryVariant,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(Avatars.getPathFromId(widget.avatarId)),
        ),
      ),
    );
  }
}