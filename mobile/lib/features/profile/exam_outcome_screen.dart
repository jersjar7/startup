import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../auth/auth_controller.dart';
import 'exam_outcome_card.dart';

/// Where the outcome notification lands.
///
/// Somebody who tapped that notification came here to answer, so this screen
/// does not offer a dismissal (owner, 2026-10-06). Three answers, all one tap,
/// and nothing else competing for attention.
///
/// It is a screen rather than the home card for one reason: on the home screen
/// the cheapest thing to do is scroll past, and after the exam this is a
/// departing user with perhaps one or two opens left. Here the question is the
/// whole screen.
///
/// Not a trap. The system back gesture still works and so does the hardware
/// back button on Android; there is simply no button inviting it, so leaving
/// is no longer the path of least resistance. That is the entire difference.
class ExamOutcomeScreen extends StatelessWidget {
  const ExamOutcomeScreen({
    super.key,
    required this.auth,
    this.mastery,
    this.onSetExamDate,
  });

  final AuthController auth;
  final Map<String, int>? mastery;
  final VoidCallback? onSetExamDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.butter,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: ExamOutcomeCard(
              auth: auth,
              dismissible: false,
              via: 'notification',
              mastery: mastery,
              onSetExamDate: onSetExamDate,
              onDone: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ),
    );
  }
}
