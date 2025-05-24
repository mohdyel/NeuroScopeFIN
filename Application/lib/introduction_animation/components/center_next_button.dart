import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class CenterNextButton extends StatelessWidget {
  final AnimationController animationController;
  final VoidCallback onNextClick;

  const CenterNextButton({
    Key? key,
    required this.animationController,
    required this.onNextClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _topMoveAnimation = Tween<Offset>(
      begin: const Offset(0, 5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.2, curve: Curves.fastOutSlowIn),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: 85 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // page-indicator dots (always shown)
          SlideTransition(
            position: _topMoveAnimation,
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) => AnimatedOpacity(
                opacity: animationController.value >= 0.2 &&
                        animationController.value <= 0.6
                    ? 1
                    : 0,
                duration: const Duration(milliseconds: 480),
                child: _pageView(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // next-arrow button, hidden on last page
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              final isLastPage = animationController.value >= 0.7;
              if (isLastPage) {
                return const SizedBox.shrink();
              }
              return Center(
                child: SlideTransition(
                  position: _topMoveAnimation,
                  child: Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(29),
                      color: const Color(0xff132137),
                    ),
                    child: InkWell(
                      key: const ValueKey('next button'),
                      onTap: onNextClick,
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _pageView() {
    int _selectedIndex = 0;
    final v = animationController.value;
    if (v >= 0.7) {
      _selectedIndex = 3;
    } else if (v >= 0.5) {
      _selectedIndex = 2;
    } else if (v >= 0.3) {
      _selectedIndex = 1;
    } else if (v >= 0.1) {
      _selectedIndex = 0;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (i) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 480),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: _selectedIndex == i
                    ? const Color(0xff132137)
                    : const Color(0xffE3E4E4),
              ),
              width: 10,
              height: 10,
            ),
          );
        }),
      ),
    );
  }
}
