import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'board.dart';
import 'lesson_brief.dart';
import 'liability_row.dart';

/// Which Protection — the first item for
/// `intellectual-property-sustainability`.
///
/// Four kinds of protection and six things they attach to, and the exam gives
/// you a scenario rather than a definition. The distinction that decides most
/// of them is disclosure: a patent is a bargain in which you publish the
/// invention and get twenty years of exclusivity for it, and a trade secret is
/// the opposite bargain, which lasts as long as nobody finds out and stops the
/// moment somebody does.
class WhichProtectionGame extends StatefulWidget {
  const WhichProtectionGame({super.key});

  @override
  State<WhichProtectionGame> createState() => _WhichProtectionGameState();
}

/// The whole taxonomy, in the order the handbook walks it.
const protections = <(String, String)>[
  ('Utility patent', 'a new process, machine or composition'),
  ('Design patent', 'the ornamental look of a made article'),
  ('Plant patent', 'a new variety, reproduced without seed'),
  ('Trademark', 'a name or mark that says who made it'),
  ('Copyright', 'an original work of authorship'),
  ('Trade secret', 'value that comes from nobody else knowing'),
];

@immutable
class ProtectionRound {
  const ProtectionRound({
    required this.subject,
    required this.asset,
    required this.answer,
    required this.why,
    required this.source,
  });

  final String subject;
  final String asset;

  /// Index into [protections].
  final int answer;
  final String why;
  final String source;
}

const protectionRounds = <ProtectionRound>[
  ProtectionRound(
    subject: 'an algorithm nobody may see',
    asset:
        'A firm has an algorithm that optimises concrete mixes for a climate. '
        'It gives them an edge and they have no intention of telling anybody '
        'how it works.',
    answer: 5,
    why:
        'Not wanting to disclose it settles the question. A patent is a trade: '
        'publish the invention and get twenty years. Keeping it quiet buys '
        'protection that lasts indefinitely and evaporates the day it leaks.',
    source: 'eth-ips-q1',
  ),
  ProtectionRound(
    subject: 'a word on the packaging',
    asset:
        'A membrane is sold under the name AquaPure. The firm wants to stop '
        'competitors calling their products something confusingly close to it.',
    answer: 3,
    why:
        'A mark protects the name and not the goods. Anybody may make and sell '
        'the same membrane; what they may not do is let a buyer think theirs '
        'came from you.',
    source: 'eth-ips-q3',
  ),
  ProtectionRound(
    subject: 'a paper about the membrane',
    asset:
        'The engineer writes a detailed technical paper describing the '
        'membrane and wants control over who reproduces and distributes it.',
    answer: 4,
    why:
        'The paper is an original work of authorship, and this protects the '
        'expression rather than the idea. Somebody who reads it and builds the '
        'membrane has not infringed the copyright.',
    source: 'eth-ips-q3',
  ),
  ProtectionRound(
    subject: 'the membrane itself',
    asset:
        'The membrane is a genuinely new structure. The firm is content to '
        'publish how it works in exchange for the right to stop others making '
        'it for twenty years.',
    answer: 0,
    why:
        'A new composition of matter, and they are willing to disclose. That '
        'is the patent bargain exactly, and the twenty years runs from the '
        'filing date rather than from the grant.',
    source: 'eth-ips-q3',
  ),
  ProtectionRound(
    subject: 'the shape of a cover',
    asset:
        'A foundry has a manhole cover with a distinctive ornamental pattern. '
        'The pattern does nothing structural; it is there to be recognised.',
    answer: 1,
    why:
        'Nothing about it is functional, so there is no invention to claim. '
        'What is protectable is the way it looks, which is the narrow thing '
        'this kind of patent is for.',
    source: 'eth-ips-q1',
  ),
  ProtectionRound(
    subject: 'grass for a median',
    asset:
        'An agronomist develops a drought-resistant turf variety for highway '
        'medians, propagated from cuttings rather than from seed.',
    answer: 2,
    why:
        'A new variety reproduced asexually has its own category, and it is '
        'the one people forget exists. Reproduced from cuttings is the phrase '
        'that puts it there.',
    source: 'eth-ips-q1',
  ),
];

class _WhichProtectionGameState extends State<WhichProtectionGame> {
  late final BoardSession _session = BoardSession(
    gameId: 'which-protection',
    chapterId: 'ethics',
    total: protectionRounds.length,
    sourceProblemIdOf: (round) => protectionRounds[round].source,
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

  ProtectionRound get _round => protectionRounds[_session.round];

  @override
  Widget build(BuildContext context) {
    if (_session.finished) {
      return BoardDone(
        session: _session,
        title: 'Which Protection',
        closing:
            'Disclosure decides most of them. A patent publishes the invention '
            'and buys twenty years; a trade secret publishes nothing and lasts '
            'until somebody finds out. A mark protects the name and not the '
            'goods, and a copyright protects the writing and not the idea in '
            'it.',
      );
    }

    final answered = _session.answered;
    final r = _round;

    return BoardShell(
      session: _session,
      brief: propertyBrief,
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
            'WHAT PROTECTS THIS',
            style: AppTheme.overline(color: AppColors.ember),
          ),
          const SizedBox(height: 8),
          Text(
            r.asset,
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
          for (var i = 0; i < protections.length; i++) ...[
            if (i > 0) const SizedBox(height: 7),
            LiabilityRow(
              key: ValueKey('protection-$i'),
              title: protections[i].$1,
              note: protections[i].$2,
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
