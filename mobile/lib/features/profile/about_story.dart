import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The owner's story for the About page (the tester's point 12b), in his
/// own words, approved 2026-10-17. The website's /about (src/about/About.jsx)
/// carries the same text; keep the two the same.
const aboutStory = <(String?, List<String>)>[
  (
    null,
    [
      'I\'m Jerson, a recent graduate. I finished my master\'s in Civil '
          'Engineering at BYU in May 2025.',
      'Some engineering concepts were really hard for me. Not all of them, '
          'but some took a lot of work, and I wished I had something to learn '
          'from other than the books. There is only so much teaching '
          'assistants and professors can do, and a lot of the time I was on my '
          'own. I wished I had one place where I could study all my courses '
          'and find what I needed.',
      'I needed that most when I was preparing for the FE exam. The exam '
          'covers so many courses and chapters that I had to pull resources '
          'together from many different places, and almost none of them '
          'explained things in simple terms. I believe a lot of civil '
          'engineering concepts are really hard, but explained well, they make '
          'sense.',
      'With what I studied, and what I learned building websites and mobile '
          'apps, I thought I could make an impact and give other students the '
          'resource I wish I\'d had. FE for Raccoons launched in June 2026. I\'m '
          'glad it has been well received, and it has already helped hundreds '
          'of students prepare for the FE.',
    ],
  ),
  (
    'Why it\'s free',
    [
      'In college I saw other students, and their families, making a big '
          'sacrifice for them to be there. What I didn\'t like about the '
          'resources I found online is how expensive they are. Even the '
          'materials NCEES provides cost a lot, and the exam itself is over '
          '\$200. For a college student that\'s real money. It felt like these '
          'places were taking advantage of students who are already working '
          'hard to be in college and to pay for their own tuition and '
          'materials.',
      'So I made this site mostly free, even though it has its own costs. The '
          'only thing I charge for is the timed exam simulation, and it\'s '
          'optional for every user.',
    ],
  ),
  (
    'How it teaches',
    [
      'Every problem comes with a "teach me like I\'m five" explanation: the '
          'idea in plain words before the math. The website is where you learn '
          'the material and earn your mastery. The app is for the time in '
          'between, when you\'re away from your desk and have a few minutes to '
          'keep the concepts fresh, a few rounds at a time.',
    ],
  ),
  (
    'Why raccoons?',
    [
      'Honestly, there\'s no special reason. I wanted it to be fun and '
          'different. I didn\'t want something serious like "FE for College '
          'Students" or "FE for Future Civil Engineers". I wanted a name that '
          'would stick, maybe even make you ask "why raccoons?", so that even '
          'if you heard it only once, you\'d remember it the next time you '
          'wanted to study. And raccoons are cute.',
      'I\'d rather not tell you what they mean, though. Make them mean '
          'whatever you like.',
    ],
  ),
];

/// The story as the sheet shows it: the headline, then each part under its
/// heading, left-aligned body type on cream.
class AboutStory extends StatelessWidget {
  const AboutStory({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why this exists',
          style: AppTheme.display(size: 30, height: 1.05),
        ),
        for (final (heading, paragraphs) in aboutStory) ...[
          if (heading != null) ...[
            const SizedBox(height: 22),
            Text(
              heading,
              style: AppTheme.display(
                size: 20,
                weight: FontWeight.w700,
                height: 1.15,
                tracking: -0.02,
              ),
            ),
          ],
          for (final p in paragraphs) ...[
            const SizedBox(height: 10),
            Text(
              p,
              style: AppTheme.body(size: 15, height: 1.5, color: AppColors.ink2),
            ),
          ],
        ],
        const SizedBox(height: 16),
        Text(
          'Jerson J. Garcia, EIT',
          style: AppTheme.display(
            size: 15,
            weight: FontWeight.w700,
            tracking: -0.01,
          ),
        ),
      ],
    );
  }
}
