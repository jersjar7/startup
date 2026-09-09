import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/math_text.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// Which One Do They Want — the third item for `linear-regression-correlation`.
///
/// The lesson's one warning is a warning about a word. Correlation is r and
/// determination is r squared, and the exam asks for them in English rather
/// than in symbols: "how strong is the relationship" against "what percentage
/// of the variation is explained". Squaring is not the difficulty. Knowing
/// which of the two the sentence just asked for is.
///
/// Every wrong option here is a real answer to a different question, and one
/// of them is impossible: a proportion of variation explained cannot be
/// negative, however negative the correlation was.
class ROrR2Game extends StatefulWidget {
  const ROrR2Game({super.key});

  @override
  State<ROrR2Game> createState() => _ROrR2GameState();
}

@immutable
class ROption {
  const ROption(this.value, this.meaning);

  /// The number as it would be written in an answer.
  final String value;

  /// What that number actually is, said plainly.
  final String meaning;
}

@immutable
class RRound {
  const RRound({
    required this.given,
    required this.ask,
    required this.options,
    required this.answer,
    required this.why,
    required this.source,
  });

  /// What the regression handed back, in the lesson's own notation.
  final String given;
  final String ask;
  final List<ROption> options;
  final int answer;
  final String why;
  final String source;
}

const rRounds = <RRound>[
  RRound(
    given: r'r = -0.92',
    ask: 'What percentage of the variation in condition rating is explained '
        'by the age of the bridge?',
    options: [
      ROption('84.6%', 'r squared'),
      ROption('92.0%', 'the size of r'),
      ROption('−84.6%', 'r squared, kept negative'),
      ROption('8.0%', 'one take the size of r'),
    ],
    answer: 0,
    why:
        'Variation explained is r squared, and squaring throws the sign away. '
        'Ninety two percent is the correlation itself, which answers a '
        'question nobody asked.',
    source: 'stat-reg-q2',
  ),
  RRound(
    given: r'r = -0.92',
    ask: 'What is the correlation coefficient?',
    options: [
      ROption('84.6%', 'r squared'),
      ROption('−0.92', 'r itself'),
      ROption('0.92', 'the size of r, sign dropped'),
      ROption('−0.846', 'r squared, kept negative'),
    ],
    answer: 1,
    why:
        'Asked for r, hand back r, minus sign and all. The sign is half of '
        'what it tells you: rating falls as age rises.',
    source: 'stat-reg-q2',
  ),
  RRound(
    given: r'r = 0.70',
    ask: 'How much of the variation does the regression account for?',
    options: [
      ROption('70%', 'the size of r'),
      ROption('30%', 'one take r'),
      ROption('49%', 'r squared'),
      ROption('84%', 'the square root of r'),
    ],
    answer: 2,
    why:
        'A correlation of zero point seven sounds strong and explains under '
        'half. Squaring is unkind to middling correlations, which is exactly '
        'why the exam asks for the squared one.',
    source: 'stat-reg-q2',
  ),
  RRound(
    given: r'R^2 = 0.64,\ \text{the relationship falls}',
    ask: 'What is the correlation coefficient?',
    options: [
      ROption('0.80', 'the root of R squared'),
      ROption('−0.80', 'the root, with the sign put back'),
      ROption('0.64', 'R squared itself'),
      ROption('−0.41', 'R squared squared again'),
    ],
    answer: 1,
    why:
        'Going back the other way, the square root gives the size and the '
        'question gives the sign. R squared has already thrown the direction '
        'away, so it has to be told to you or read off the plot.',
    source: 'stat-reg-q2',
  ),
  RRound(
    given: r'r = 0.50',
    ask: 'What fraction of the variation is NOT explained by the regression?',
    options: [
      ROption('50%', 'the size of r'),
      ROption('25%', 'r squared'),
      ROption('75%', 'one take r squared'),
      ROption('0%', 'nothing is unexplained'),
    ],
    answer: 2,
    why:
        'A quarter is explained, so three quarters is not. The unexplained '
        'share is what is left over from r squared, never from r.',
    source: 'stat-reg-q2',
  ),
  RRound(
    given: r'r = -0.90',
    ask: 'What is the coefficient of determination?',
    options: [
      ROption('−0.81', 'r squared, kept negative'),
      ROption('0.81', 'r squared'),
      ROption('−0.90', 'r itself'),
      ROption('0.95', 'the root of the size of r'),
    ],
    answer: 1,
    why:
        'Determination is always positive, because it is a share of something '
        'and a share cannot be less than none. A minus sign on an R squared '
        'is a wrong answer you can spot without doing any arithmetic.',
    source: 'stat-reg-q2',
  ),
];

class _ROrR2GameState extends State<ROrR2Game> {
  late final BoardSession _session = BoardSession(
    gameId: 'r-or-r2',
    chapterId: 'statistics',
    total: rRounds.length,
    sourceProblemIdOf: (round) => rRounds[round].source,
  )..addListener(_onSession);

  int? _picked;

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  RRound get _round => rRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which One Do They Want',
        closing:
            'Correlation is r and carries a sign. Determination is r squared, '
            'is always positive, and is the share of the variation explained. '
            'The exam asks for them in English, so the reading is the work.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: determinationBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(() => _picked = null);
              _session.next();
            }
          : (_picked == null
                ? null
                : () => _session.submit(
                    ok: _picked == r.answer,
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE REGRESSION IS ALREADY DONE',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.ask,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.creamDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MathBlock(r.given, fontSize: 17),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < r.options.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _OptionRow(
              key: ValueKey('r2-$i'),
              option: r.options[i],
              selected: _picked == i,
              locked: answered,
              isTruth: i == r.answer,
              onTap: answered ? null : () => setState(() => _picked = i),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS THE ONE' : 'A DIFFERENT ONE',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    super.key,
    required this.option,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final ROption option;
  final bool selected;
  final bool locked;
  final bool isTruth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    final Color fill;
    if (locked && isTruth) {
      border = AppColors.forest;
      fill = AppColors.forestBg;
    } else if (locked && selected) {
      border = AppColors.error;
      fill = AppColors.errorBg;
    } else if (selected) {
      border = AppColors.ember;
      fill = AppColors.emberBg;
    } else {
      border = AppColors.line;
      fill = AppColors.white;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 76,
                child: Text(
                  option.value,
                  style: AppTheme.code(size: 16),
                ),
              ),
              Expanded(
                child: Text(
                  // Shown after the answer only. Before it, naming each number
                  // would be handing the reading skill over.
                  locked ? option.meaning : '',
                  style: AppTheme.mono(size: 10.5, color: AppColors.ink3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
