import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';

class FAQScreen extends StatefulWidget {
  final AnimationController? animationController;

  const FAQScreen({Key? key, this.animationController}) : super(key: key);

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I get an EEG prediction?',
      answer:
          'Simply tap the ➕ button front and center, select your .parquet file, and sit back—our AI kicks into gear and delivers your EEG prediction in seconds. It\'s that effortless!',
    ),
    FAQItem(
      question: 'Can I review my previous recordings?',
      answer:
          'Absolutely. Head over to the History tab, where all your past analyses live. Tap any entry to zoom in on the EEG image, explore waveforms in detail, and even compare sessions side-by-side.',
    ),
    FAQItem(
      question: 'How can I update my profile?',
      answer:
          'Navigate to the Settings tab, select Profile, and edit any field—name, email, avatar—with just a few taps. Hit Save, and your profile is instantly refreshed. No paperwork, no hassle.',
    ),
    FAQItem(
      question: 'How do I sign out?',
      answer:
          'Signing out is a breeze: go to Settings and hit Sign Out at the bottom. You\'ll be safely logged out and back at the welcome screen in a flash.',
    ),
    FAQItem(
      question: 'Can I delete my account?',
      answer:
          'We\'re sorry to see you go, but yes—you can. Just reach out to our admin team via the Support link (in Settings), and they\'ll promptly handle your request.',
    ),
    FAQItem(
      question: 'What file formats are supported?',
      answer:
          'Right now, we process .parquet files for EEG data. In the future, we plan to add more formats—stay tuned!',
    ),
    FAQItem(
      question: 'Is my data secure?',
      answer:
          'Your privacy is our priority. All uploads are encrypted in transit and at rest, so your EEG recordings stay under lock and key.',
    ),
    FAQItem(
      question: 'What\'s coming next?',
      answer:
          'We\'re always innovating! Expect features like real-time monitoring, customizable dashboards, and integration with popular health platforms in upcoming releases.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).padding.top),
            getAppBarUI(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Got questions? We\'ve got answers. Browse below to learn how to make the most of your EEG app.',
                        style: TextStyle(
                          fontFamily: FitnessAppTheme.fontName,
                          fontSize: 16,
                          color: FitnessAppTheme.grey.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _faqItems.length,
                      itemBuilder: (context, index) {
                        return _buildFAQCard(_faqItems[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(FAQItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: FitnessAppTheme.white,
        collapsedBackgroundColor: FitnessAppTheme.white,
        title: Text(
          item.question,
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: FitnessAppTheme.darkerText,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              item.answer,
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontSize: 14,
                color: FitnessAppTheme.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getAppBarUI() {
    return Container(
      decoration: BoxDecoration(
        color: FitnessAppTheme.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32.0),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: FitnessAppTheme.grey.withOpacity(0.4),
            offset: const Offset(1.1, 1.1),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'FAQ',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        letterSpacing: 1.2,
                        color: FitnessAppTheme.darkerText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
