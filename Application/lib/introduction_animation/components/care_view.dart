import 'package:flutter/material.dart';

class CareView extends StatelessWidget {
  final AnimationController animationController;

  const CareView({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _firstHalfAnimation = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.2, 0.4, curve: Curves.fastOutSlowIn),
    ));
    final _secondHalfAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.4, 0.6, curve: Curves.fastOutSlowIn),
    ));
    final _relaxFirstHalfAnimation = Tween<Offset>(begin: Offset(2, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.2, 0.4, curve: Curves.fastOutSlowIn),
    ));
    final _relaxSecondHalfAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(-2, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.4, 0.6, curve: Curves.fastOutSlowIn),
    ));
    final _imageFirstHalfAnimation = Tween<Offset>(begin: Offset(4, 0), end: Offset(0, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.2, 0.4, curve: Curves.fastOutSlowIn),
    ));
    final _imageSecondHalfAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(-4, 0))
        .animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.4, 0.6, curve: Curves.fastOutSlowIn),
    ));

    return SlideTransition(
      position: _firstHalfAnimation,
      child: SlideTransition(
        position: _secondHalfAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double availableHeight = constraints.maxHeight;
            double imageHeight = availableHeight * 0.2;
            double spacing = availableHeight * 0.05;

            return Padding(
              // ↑ bumped vertical padding
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ↑ more space above image
                    SizedBox(height: spacing),

                    SlideTransition(
                      position: _imageFirstHalfAnimation,
                      child: SlideTransition(
                        position: _imageSecondHalfAnimation,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 280,
                            maxHeight: imageHeight,
                          ),
                          margin: EdgeInsets.symmetric(vertical: 20),
                          child: Image.asset(
                            'assets/introduction_animation/care_image.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // ↑ extra spacing before title
                    SizedBox(height: spacing * 1.2),

                    SlideTransition(
                      position: _relaxFirstHalfAnimation,
                      child: SlideTransition(
                        position: _relaxSecondHalfAnimation,
                        child: Text(
                          "Record Your Care",
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    SizedBox(height: spacing),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.08,
                      ),
                      child: Text(
                        "With real-time waveform visualization, seize the fleeting pulses of your mind's energy, capturing raw brainwave data as dynamic artful patterns.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          height: 1.5,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),

                    SizedBox(height: availableHeight * 0.1),
                    SizedBox(height: availableHeight * 0.05),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
