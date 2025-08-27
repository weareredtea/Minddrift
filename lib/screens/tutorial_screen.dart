// lib/screens/tutorial_screen.dart

import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../l10n/app_localizations.dart';

class TutorialScreen extends StatefulWidget {
  static const String routeName = '/tutorial';
  final VoidCallback? onDone;

  const TutorialScreen({Key? key, this.onDone}) : super(key: key);

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final LiquidController _liquidController = LiquidController();
  int _currentPage = 0;



  void _onSkipOrDone() {
    if (widget.onDone != null) {
      widget.onDone!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final pages = <_PageData>[
      _PageData(
        title: loc.tutorialTitle1,
        description: loc.tutorialDesc1,
        icon: Icons.meeting_room,
        gradient: [Color(0xFFCE9FFC), Color(0xFF7367F0)],
      ),
      _PageData(
        title: loc.tutorialTitle2,
        description: loc.tutorialDesc2,
        icon: Icons.group,
        gradient: [Color(0xFF90F7EC), Color(0xFF32CCBC)],
      ),
      _PageData(
        title: loc.tutorialTitle3,
        description: loc.tutorialDesc3,
        icon: Icons.lightbulb,
        gradient: [Color(0xFFF9F586), Color(0xFFF09A36)],
      ),
      _PageData(
        title: loc.tutorialTitle4,
        description: loc.tutorialDesc4,
        icon: Icons.slideshow,
        gradient: [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
      ),
      _PageData(
        title: loc.tutorialTitle5,
        description: loc.tutorialDesc5,
        icon: Icons.bug_report,
        gradient: [Color(0xFFFEA085), Color(0xFFFEE140)],
      ),
      _PageData(
        title: loc.tutorialTitle6,
        description: loc.tutorialDesc6,
        icon: Icons.score,
        gradient: [Color(0xFF5EE7DF), Color(0xFFB490CA)],
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          LiquidSwipe(
            pages: pages.map((p) => _buildPage(p)).toList(),
            liquidController: _liquidController,
            enableLoop: false,
            enableSideReveal: true,
            slideIconWidget: Icon(Icons.arrow_back_ios, color: Colors.white70),
            positionSlideIcon: 0.8,
            onPageChangeCallback: (index) => setState(() => _currentPage = index),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: _onSkipOrDone,
              child: Text(
                _currentPage == pages.length - 1 ? loc.done : loc.skip,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
          // Page indicator dots - positioned higher when button is shown
          Positioned(
            bottom: _currentPage == pages.length - 1 ? 120 : 80,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSmoothIndicator(
                activeIndex: _currentPage,
                count: pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.white,
                  dotColor: Colors.white54,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                ),
              ),
            ),
          ),
          // Get Started button - only shown on last page
          if (_currentPage == pages.length - 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _onSkipOrDone,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    loc.getStarted,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.purple),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(_PageData data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
            child: Icon(data.icon, size: 180, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  const _PageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
