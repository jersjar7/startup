import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../features/league/league_model.dart';
import '../features/league/league_moment.dart';
import '../features/league/league_screen.dart';
import '../features/profile/profile_views.dart';

/// The league screens on a real renderer, with a sample week (the names and
/// figures of the approved mock). Not part of the app:
///
///   flutter run -t lib/dev/league_gallery.dart --dart-define=MOVE=up
///   flutter run -t lib/dev/league_gallery.dart --dart-define=MOVE=down
///   flutter run -t lib/dev/league_gallery.dart --dart-define=MOVE=stay
///   flutter run -t lib/dev/league_gallery.dart --dart-define=SCREEN=profile
///   flutter run -t lib/dev/league_gallery.dart --dart-define=SCREEN=league
///   flutter run -t lib/dev/league_gallery.dart --dart-define=SCREEN=reel
///
/// The reel plays everything in turn with no taps, for recording: up, down,
/// stay, then Profile opening the league page and scrolling it.
///
/// The moment plays again each time its button is tapped; Profile opens the
/// league page from its fourth figure.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LeagueArt.warmUp();
  const screen = String.fromEnvironment('SCREEN', defaultValue: 'moment');
  const move = String.fromEnvironment('MOVE', defaultValue: 'up');
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: screen == 'reel'
          ? const _Reel()
          : screen == 'profile'
          ? const _Profile()
          : screen == 'league'
          ? LeagueScreen(initial: sampleLeague, live: false)
          : _Moment(result: sampleResult(move)),
    ),
  );
}

LeagueResult sampleResult(String move) => switch (move) {
  'down' => const LeagueResult(
    from: LeagueMetal.gold,
    to: LeagueMetal.silver,
    place: 14,
    size: 15,
    moved: 'down',
  ),
  'stay' => const LeagueResult(
    from: LeagueMetal.silver,
    to: LeagueMetal.silver,
    place: 8,
    size: 15,
    moved: 'stay',
  ),
  _ => const LeagueResult(
    from: LeagueMetal.bronze,
    to: LeagueMetal.silver,
    place: 3,
    size: 15,
    moved: 'up',
  ),
};

final sampleLeague = LeagueView.fromJson({
  'tier': 'silver',
  'joined': true,
  'zones': {'promote': 5, 'demote': 3},
  'rows': [
    for (final (i, r) in const [
      ('Sweet D.', 1840, 'up', 6),
      ('Mohammad A.', 1525, 'down', 5),
      ('Kasie N.', 1310, null, 5),
      ('Jerson G.', 1290, 'up', 4),
      ('Jackson H.', 1240, 'down', 4),
      ('Meagan', 1105, 'up', 5),
      ('Liz', 980, 'new', 3),
      ('Nicholas K.', 870, 'up', 4),
      ('Izzy T.', 760, null, 3),
      ('Ermi', 640, 'down', 3),
      ('A student', 515, 'new', 2),
      ('Devon R.', 420, 'up', 2),
      ('sal***', 310, 'down', 2),
      ('Priya S.', 185, 'new', 1),
      ('Tom B.', 90, null, 1),
    ].indexed)
      {
        'place': i + 1,
        'name': r.$1,
        'xp': r.$2,
        'move': r.$3,
        'days': r.$4,
        'isMe': i == 3,
      },
  ],
});

/// The moment, over and over: its button starts it again.
class _Moment extends StatefulWidget {
  const _Moment({required this.result});

  final LeagueResult result;

  @override
  State<_Moment> createState() => _MomentState();
}

class _MomentState extends State<_Moment> {
  int _run = 0;

  @override
  Widget build(BuildContext context) => Navigator(
    key: ValueKey(_run),
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      builder: (_) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, _) => setState(() => _run++),
        child: LeagueMomentScreen(result: widget.result),
      ),
    ),
  );
}

class _Profile extends StatelessWidget {
  const _Profile();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.fog,
    body: SafeArea(
      child: Builder(
        builder: (context) => ProfileUnderway(
          top: const SizedBox(height: 48),
          name: 'Jerson',
          headline: 'Welcome back, Jerson.',
          lessonName: 'Law of Sines & Law of Cosines',
          chapterName: 'Mathematics',
          roundsInLesson: 20,
          roundsCleared: 0,
          daysStudied: 6,
          exam: const ExamFacts(days: 29, label: 'Monday, November 30'),
          league: sampleLeague,
          onLeague: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => LeagueScreen(initial: sampleLeague, live: false),
            ),
          ),
          onCarryOn: () {},
          onDays: () {},
          onExam: () {},
        ),
      ),
    ),
  );
}

/// Everything in turn, untouched, so a screen recording can be cut into one
/// clip per moment. Each beat starts from a plain fog screen so the cuts are
/// clean.
class _Reel extends StatefulWidget {
  const _Reel();

  @override
  State<_Reel> createState() => _ReelState();
}

class _ReelState extends State<_Reel> {
  final _nav = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _wait(int ms) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  Route<void> _fade(Widget page) => PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, child) =>
        FadeTransition(opacity: a, child: child),
  );

  Future<void> _run() async {
    await _wait(3000);
    for (final m in ['up', 'down', 'stay']) {
      final nav = _nav.currentState!;
      nav.push(_fade(LeagueMomentScreen(result: sampleResult(m))));
      await _wait(5200);
      nav.pop();
      await _wait(1500);
    }
    final nav = _nav.currentState!;
    nav.push(_fade(const _Profile()));
    await _wait(2200);
    final scroll = ScrollController();
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) =>
            LeagueScreen(initial: sampleLeague, live: false, scroll: scroll),
      ),
    );
    await _wait(2200);
    if (scroll.hasClients) {
      await scroll.animateTo(
        scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 4200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Navigator(
    key: _nav,
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      builder: (_) => const Scaffold(backgroundColor: AppColors.fog),
    ),
  );
}
