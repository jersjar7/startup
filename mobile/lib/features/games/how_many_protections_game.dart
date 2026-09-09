import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';

/// How Many Protections — the second item for
/// `intellectual-property-sustainability`.
///
/// The lesson's hard problem describes one project and asks how many kinds of
/// protection it needs, and the answer is four. That is the whole idea: the
/// categories do not compete, they attach to different things, and a firm that
/// patents the invention and stops there has left the name, the writing and
/// the process unprotected.
///
/// So the project is described and every protection that applies is tapped.
/// The count is not given, because being told there are four is most of the
/// question.
class HowManyProtectionsGame extends StatefulWidget {
  const HowManyProtectionsGame({super.key});

  @override
  State<HowManyProtectionsGame> createState() =>
      _HowManyProtectionsGameState();
}

/// The four the exam works in, in the handbook's order.
const kinds = <String>['Patent', 'Trademark', 'Copyright', 'Trade secret'];

@immutable
class CountRound {
  const CountRound({
    required this.subject,
    required this.project,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String project;

  /// Indices into [kinds] that apply.
  final List<int> answer;
  final String why;
  final String source;
}

const countRounds = <CountRound>[
  CountRound(
    subject: 'a membrane, a name, a paper and a process',
    project:
        'An engineer develops a new water filtration membrane, brands it '
        'AquaPure, publishes a detailed technical paper on its design, and '
        'manufactures it by a process the paper does not describe.',
    answer: [0, 1, 2, 3],
    why:
        'All four, and the reason is that they attach to four different '
        'things. Patenting the membrane leaves the name, the paper and the '
        'process each unprotected by it.',
    source: 'eth-ips-q3',
  ),
  CountRound(
    subject: 'a mix design and nothing else',
    project:
        'A firm has a concrete mix optimisation method that it uses in house, '
        'has never published, has never named, and does not intend to file '
        'anything about.',
    answer: [3],
    why:
        'One thing, kept quiet. There is no name to protect, nothing written '
        'for the public, and no application on file, which leaves exactly the '
        'protection that comes from nobody else knowing.',
    source: 'eth-ips-q1',
  ),
  CountRound(
    subject: 'a design manual sold under a brand',
    project:
        'A firm writes and sells a stormwater design manual under the name '
        'FlowGuide. The methods in it are all published standards and there is '
        'no invention and no secret.',
    answer: [1, 2],
    why:
        'The writing and the name, and nothing else. Standard methods '
        'explained well are still an original work of authorship, and the '
        'brand on the cover is its own thing.',
    source: 'eth-ips-q3',
  ),
  CountRound(
    subject: 'a filed invention with a name on it',
    project:
        'A firm files a utility application for a new bearing assembly and '
        'sells it under the mark PivotLock. Nothing is written for publication '
        'and nothing is being kept secret.',
    answer: [0, 1],
    why:
        'Two. Filing publishes the invention, which is the point of the trade, '
        'so nothing about it can be a secret at the same time, and there is no '
        'authored work here to protect.',
    source: 'eth-ips-q3',
  ),
  CountRound(
    subject: 'drawings for one client',
    project:
        'A firm produces a set of construction drawings for a single client. '
        'The details are conventional, the firm\'s name is on the title block '
        'as it always is, and nothing about the work is confidential.',
    answer: [2],
    why:
        'The drawings are an authored work and that is the whole of it. A name '
        'in a title block is not a mark being used to sell goods, and '
        'conventional details are nobody\'s invention.',
    source: 'eth-ips-q3',
  ),
  CountRound(
    subject: 'a machine, and the recipe for its coating',
    project:
        'A manufacturer patents a trenching machine and publishes the '
        'application. The proprietary coating on its cutting teeth is made by '
        'a formula that appears nowhere in the filing.',
    answer: [0, 3],
    why:
        'The two opposite bargains at once, on two different things. What was '
        'filed is published and protected for twenty years; what was left out '
        'of the filing is protected for as long as it stays out.',
    source: 'eth-ips-q1',
  ),
];

class _HowManyProtectionsGameState extends State<HowManyProtectionsGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'how-many-protections',
    chapterId: 'ethics',
    total: countRounds.length,
    sourceProblemIdOf: (round) => countRounds[round].source,
  )..addListener(_onSession);

  final _picked = <int>{};

  void _onSession() => setState(() {});

  @override
  void dispose() {
    _session
      ..removeListener(_onSession)
      ..dispose();
    super.dispose();
  }

  CountRound get _round => countRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'How Many Protections',
        closing:
            'They do not compete. A patent covers the invention, a mark covers '
            'the name, a copyright covers the writing and a secret covers what '
            'was never filed, and one project can need all four at once. The '
            'one pairing that cannot happen is a patent and a secret on the '
            'same thing.',
      );
    }

    final answered = _session.answered;
    final r = _round;
    final truth = r.answer.toSet();

    return BoardShell(
      session: _session,
      brief: portfolioBrief,
      buttonLabel: answered ? _session.advanceLabel : 'Lock it in',
      onButton: answered
          ? () {
              setState(_picked.clear);
              _session.next();
            }
          : (_picked.isEmpty
                ? null
                : () => _session.submit(
                    ok: _picked.length == truth.length &&
                        _picked.containsAll(truth),
                    context: context,
                  )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP EVERY PROTECTION THIS NEEDS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.project,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            r.subject,
            style: AppTheme.mono(size: 11.5, color: AppColors.ink3),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < kinds.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _KindRow(
              key: ValueKey('kind-$i'),
              name: kinds[i],
              selected: _picked.contains(i),
              locked: answered,
              isTruth: truth.contains(i),
              onTap: answered
                  ? null
                  : () => setState(
                      () => _picked.contains(i)
                          ? _picked.remove(i)
                          : _picked.add(i),
                    ),
            ),
          ],
          if (answered) ...[
            const SizedBox(height: 16),
            BoardFeedback(
              correct: _session.correct!,
              title: _session.correct! ? 'THAT IS ALL OF THEM' : 'NOT THAT SET',
              body: r.why,
            ),
          ],
        ],
      ),
    );
  }
}

class _KindRow extends StatelessWidget {
  const _KindRow({
    super.key,
    required this.name,
    required this.selected,
    required this.locked,
    required this.isTruth,
    required this.onTap,
  });

  final String name;
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: border,
              width: border == AppColors.line ? 1 : 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: selected || (locked && isTruth) ? border : null,
                  border: Border.all(
                    color: selected || (locked && isTruth)
                        ? border
                        : AppColors.line,
                  ),
                ),
                child: selected || (locked && isTruth)
                    ? const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: AppColors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
