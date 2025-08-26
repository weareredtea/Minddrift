// lib/screens/role_reveal_screen.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/round.dart';
import '../theme/app_theme.dart';

class RoleRevealScreen extends StatefulWidget {
  final String roomId;
  const RoleRevealScreen({super.key, required this.roomId});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _animationComplete = false; // To track when the animation is done

  @override
void initState() {
  super.initState();
  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  _animation = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  _controller.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      // Wait 400ms AFTER the animation is done to show the button
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _animationComplete = true;
          });
        }
      });
    }
  });

  // Start animation right away
  _controller.forward();
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fb = context.watch<FirebaseService>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The animated card
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final angle = _animation.value * pi;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: _animation.value <= 0.5
                      ? const RoleCard(isFront: true)
                      : Transform(
                          transform: Matrix4.identity()..rotateY(pi),
                          alignment: Alignment.center,
                          child: StreamBuilder<Role>(
                            stream: fb.listenMyRole(widget.roomId),
                            builder: (context, snapshot) {
                              final myRole = snapshot.data ?? Role.Seeker;
                              return RoleCard(role: myRole);
                            },
                          ),
                        ),
                );
              },
            ),
            const SizedBox(height: 40),
            // --- MODIFIED: Show Continue button for host after animation ---
            if (_animationComplete)
              FutureBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                future: fb.roomDocRef(widget.roomId).get(),
                builder: (context, roomSnap) {
                  final isHost = roomSnap.hasData && roomSnap.data?['creator'] == fb.currentUserUid;
                  if (isHost) {
                    return ElevatedButton(
                      onPressed: () => fb.transitionAfterRoleReveal(widget.roomId),
                      child: const Text('Continue'),
                    );
                  } else {
                    return const Text('Waiting for host to continue...');
                  }
                },
              )
          ],
        ),
      ),
    );
  }
}

// The RoleCard widget remains the same as before.
class RoleCard extends StatelessWidget {
  final bool isFront;
  final Role? role;

  const RoleCard({
    super.key,
    this.isFront = false,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String title;
    String description;
    IconData icon;
    Color color;

    if (isFront) {
      title = 'Your Role Is...';
      description = '';
      icon = Icons.help_outline_rounded;
      color = AppColors.surface;
    } else {
      switch (role) {
        case Role.Navigator:
          title = 'Navigator';
          description = 'Give a clever clue to guide your team!';
          icon = Icons.explore_rounded;
          color = AppColors.accent;
          break;
        case Role.Saboteur:
          title = 'Saboteur';
          description = 'Subtly mislead the team to make them miss!';
          icon = Icons.remove_red_eye_rounded;
          color = AppColors.accentVariant;
          break;
        default:
          title = 'Seeker';
          description = 'Work with your team to guess the position!';
          icon = Icons.search_rounded;
          color = AppColors.primary;
      }
    }

    return Card(
      color: color,
      child: Container(
        width: 300,
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.onPrimary),
            const SizedBox(height: 24),
            Text(title, style: textTheme.displayMedium?.copyWith(color: AppColors.onPrimary)),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                description,
                style: textTheme.titleLarge?.copyWith(color: AppColors.onPrimary.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }
}