import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/engineering_grid.dart';
import '../shared/widgets/figure_view.dart';
import '../shared/widgets/math_text.dart';
import 'models.dart';

typedef AnswerLog = ({String problemId, bool isCorrect});

/// Tab 1, Level 4 — the exercise player. One problem at a time on engineering
/// paper: statement, figure, choices, submit, then the green/red reveal and the
/// explanation. Runs the lesson's (or a review's) problems and reports answers.
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({
    super.key,
    required this.problems,
    required this.title,
    this.onComplete,
  });

  final List<Problem> problems;
  final String title;
  final Future<void> Function(List<AnswerLog> answers)? onComplete;

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _index = 0;
  String? _selected;
  bool _submitted = false;
  int _xp = 0;
  final List<AnswerLog> _answers = [];

  static const _labels = ['A', 'B', 'C', 'D', 'E', 'F'];

  Problem get _p => widget.problems[_index];
  bool get _isCorrect => _selected == _p.correctAnswerId;
  String get _correctLabel {
    final i = _p.choices.indexWhere((c) => c.id == _p.correctAnswerId);
    return i >= 0 && i < _labels.length ? _labels[i] : '?';
  }

  void _submit() {
    if (_selected == null) return;
    setState(() {
      _submitted = true;
      _xp += _isCorrect ? 10 : 5;
      _answers.add((problemId: _p.id, isCorrect: _isCorrect));
    });
  }

  Future<void> _next() async {
    if (_index < widget.problems.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _submitted = false;
      });
    } else {
      await widget.onComplete?.call(_answers);
      if (mounted) Navigator.of(context).pop(_answers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == widget.problems.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 15)),
        backgroundColor: const Color(0xFFFDFCF8),
      ),
      backgroundColor: const Color(0xFFFDFCF8),
      body: EngineeringGrid(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  children: [
                    _progressBar(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _difficultyPill(_p.difficulty),
                        Row(children: [
                          Text('Problem ${_index + 1} of ${widget.problems.length}',
                              style: AppTheme.mono(size: 11, color: AppColors.ink3)),
                          const SizedBox(width: 12),
                          Icon(Icons.bolt, size: 14, color: AppColors.ink3),
                          Text(' $_xp XP', style: AppTheme.mono(size: 12, color: AppColors.ink2)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 12),
                    MathText(_p.statement,
                        style: const TextStyle(
                            fontSize: 15.5, height: 1.5, fontWeight: FontWeight.w500)),
                    if (_p.figure != null) ...[
                      const SizedBox(height: 14),
                      FigureView(_p.figure!.figureId),
                    ],
                    const SizedBox(height: 14),
                    for (var i = 0; i < _p.choices.length; i++) _choice(i),
                    if (_submitted) _feedback(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: _submitted
                    ? AppButton(label: last ? 'Finish' : 'Next problem', onPressed: _next)
                    : AppButton(label: 'Submit answer', onPressed: _selected == null ? null : _submit),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar() {
    return Row(
      children: List.generate(widget.problems.length, (i) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == widget.problems.length - 1 ? 0 : 5),
            decoration: BoxDecoration(
              color: i <= _index ? AppColors.ember : AppColors.creamDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _choice(int i) {
    final c = _p.choices[i];
    final isCorrect = c.id == _p.correctAnswerId;
    final isPicked = c.id == _selected;

    Color border = AppColors.line;
    Color bg = Colors.white;
    Widget badge = Text(_labels[i],
        style: AppTheme.mono(size: 13, weight: FontWeight.w700, color: AppColors.ink2));
    Color badgeBg = AppColors.creamDark;
    TextDecoration deco = TextDecoration.none;
    double opacity = 1;

    if (_submitted) {
      if (isCorrect) {
        border = AppColors.forest;
        bg = AppColors.forestBg;
        badgeBg = AppColors.forest;
        badge = const Icon(Icons.check, size: 14, color: Colors.white);
      } else if (isPicked) {
        border = AppColors.error;
        bg = AppColors.errorBg;
        badgeBg = Colors.white;
        badge = const Icon(Icons.close, size: 14, color: AppColors.error);
        deco = TextDecoration.lineThrough;
      } else {
        opacity = 0.45;
      }
    } else if (isPicked) {
      border = AppColors.ember;
    }

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: _submitted ? null : () => setState(() => _selected = c.id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                    border: _submitted && isPicked && !isCorrect
                        ? Border.all(color: AppColors.error, width: 1.5)
                        : null,
                  ),
                  child: badge,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MathText(c.text,
                      style: TextStyle(
                          fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
                          fontSize: 14,
                          decoration: deco,
                          color: deco == TextDecoration.lineThrough
                              ? AppColors.ink3
                              : AppColors.charcoal)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _isCorrect ? AppColors.forestBg : AppColors.emberBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _isCorrect
                ? 'Correct · +10 XP'
                : 'Not quite. The answer is $_correctLabel · +5 XP',
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: _isCorrect ? const Color(0xFF1F5A44) : const Color(0xFFB8431C)),
          ),
        ),
        if (_p.eli5.isNotEmpty)
          _card('Why', MathText(_p.eli5, style: const TextStyle(fontSize: 12.5, height: 1.55, color: Color(0xFF46433D)))),
        if (_p.steps.isNotEmpty)
          _card(
            'Step-by-step',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final s in _p.steps) ...[
                  if (s.text.isNotEmpty)
                    MathText(s.text, style: const TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xFF46433D))),
                  if (s.latex != null && s.latex!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: MathBlock(s.latex!, fontSize: 14),
                    ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        if (_p.handbookPage != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Row(children: [
              const Icon(Icons.menu_book_outlined, size: 15, color: Color(0xFF9A6B00)),
              const SizedBox(width: 6),
              Text('FE Handbook · ${_p.handbookPage}',
                  style: GoogleFonts.dmSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink2)),
            ]),
          ),
      ],
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [BoxShadow(color: Color(0x0F2C2C2C), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 12.5)),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }

  Widget _difficultyPill(String d) {
    final cap = d.isEmpty ? 'Medium' : d[0].toUpperCase() + d.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.forestBg, borderRadius: BorderRadius.circular(20)),
      child: Text(cap,
          style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700, fontSize: 10.5, color: AppColors.forest)),
    );
  }
}
