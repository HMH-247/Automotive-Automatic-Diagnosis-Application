import 'package:flutter/material.dart';
import 'package:flutter_modern_ui/screens/home_screen.dart';
import 'package:flutter_modern_ui/screens/onboarding/app_introduction.dart';
import 'package:flutter_modern_ui/screens/onboarding/usage_introduction.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller to keep track of which pape we're on
  final PageController _controller = PageController();

  // Keep track of if we are on the last page or not
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 1);
              });
            },
            children: [AppIntroduction(), UsageIntroduction()],
          ),
          // Dot indicators - Previous - Next
          Container(
            alignment: Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Skip button
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(1);
                  },
                  child: Text('Skip'),
                ),
                // Dot indicator
                SmoothPageIndicator(controller: _controller, count: 2),
                // Next or Get Started button
                onLastPage
                    ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) {
                                return HomeScreen();
                              }
                          ),
                        );
                      },
                      child: Text('Done'),
                    )
                    : GestureDetector(
                      onTap: () {
                        _controller.nextPage(
                          duration: Duration(microseconds: 500),
                          curve: Curves.easeIn,
                        );
                      },
                      child: Text('Next'),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
