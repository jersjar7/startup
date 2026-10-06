import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/app_storage.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/auth_controller.dart';
import 'package:mobile/features/profile/account_extras.dart';
import 'package:mobile/features/profile/exam_outcome_card.dart';

import 'support/fonts.dart';

/// The two records a university report cannot be built without: which school
/// somebody is at, and whether they passed. What is guarded here is that the
/// questions are asked at the right moment, that nobody is trapped behind
/// either of them, and that a refusal is recorded rather than ignored.

/// Records what the app posted, and can be told to fail, so the "never block
/// the user" rule is testable rather than asserted.
class _RecordingApi extends ApiClient {
  _RecordingApi({this.fail = false});

  final bool fail;
  final posts = <(String, Map<String, dynamic>?)>[];

  @override
  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    posts.add((path, body));
    if (fail) throw Exception('offline');
    return <String, dynamic>{'ok': true};
  }

  @override
  Future<dynamic> get(String path) async => <String, dynamic>{'email': 'a@b.com'};
}

AuthController _auth(_RecordingApi api, [Map<String, dynamic>? user]) =>
    AuthController(api: api, storage: AppStorage())
      ..user = user ?? {'email': 'a@b.com'}
      ..status = AuthStatus.authenticated;

Widget _host(AuthController auth, Widget child) => ChangeNotifierProvider.value(
  value: auth,
  child: MaterialApp(
    theme: AppTheme.light,
    debugShowCheckedModeBanner: false,
    home: Scaffold(body: SafeArea(child: child)),
  ),
);

void main() {
  setUpAll(loadBrandFonts);

  group('graduation years', () {
    test('offers this year and four ahead, which covers a freshman', () {
      final years = graduationYears(DateTime(2026, 10, 6));
      expect(years, [2026, 2027, 2028, 2029, 2030]);
    });

    test('rolls forward with the calendar rather than being hardcoded', () {
      expect(graduationYears(DateTime(2030, 1, 1)).first, 2030);
    });
  });

  group('when the outcome question appears', () {
    DateTime on(String d) => DateTime.parse('${d}T12:00:00Z');

    test('nine days after the exam, matching the email', () {
      final user = {'examDate': '2026-04-10'};
      expect(shouldAskOutcome(user, on('2026-04-18')), isFalse);
      expect(shouldAskOutcome(user, on('2026-04-19')), isTrue);
      expect(shouldAskOutcome(user, on('2026-06-01')), isTrue);
      expect(outcomeAskAfterDays, 9);
    });

    test('never without an exam date, which is nearly half the accounts', () {
      expect(shouldAskOutcome({'examDate': null}, on('2026-06-01')), isFalse);
      expect(shouldAskOutcome({}, on('2026-06-01')), isFalse);
      expect(shouldAskOutcome(null, on('2026-06-01')), isFalse);
    });

    test('never once it has been answered or refused', () {
      final user = {'examDate': '2026-04-10', 'examOutcomeResolved': true};
      expect(shouldAskOutcome(user, on('2026-06-01')), isFalse);
    });

    test('comes back on the same schedule the email uses', () {
      // 9, 16, 30 and 60 days after the exam, mirroring ASK_DAYS on the server.
      expect(outcomeAskDays, [9, 16, 30, 60]);
      String after(int d) {
        final x = DateTime.utc(2026, 4, 10 + d);
        return x.toIso8601String().substring(0, 10);
      }
      for (var put = 0; put < outcomeAskDays.length; put++) {
        final user = {'examDate': '2026-04-10', 'examOutcomeSnoozes': put};
        final due = outcomeAskDays[put];
        expect(shouldAskOutcome(user, on(after(due - 1))), isFalse,
            reason: 'ask ${put + 1} showed a day early');
        expect(shouldAskOutcome(user, on(after(due))), isTrue,
            reason: 'ask ${put + 1} did not show');
      }
    });

    test('goes quiet for good after the fourth', () {
      final user = {'examDate': '2026-04-10', 'examOutcomeSnoozes': 4};
      expect(shouldAskOutcome(user, on('2027-06-01')), isFalse);
      expect(shouldAskOutcome({'examDate': '2026-04-10', 'examOutcomeSnoozes': 9},
          on('2027-06-01')), isFalse);
    });

    test('a rubbish exam date is not an exam date', () {
      expect(shouldAskOutcome({'examDate': 'soon'}, on('2026-06-01')), isFalse);
    });
  });

  group('answering', () {
    testWidgets('a pass is recorded with the attempt number', (tester) async {
      final api = _RecordingApi();
      final auth = _auth(api);
      await tester.pumpWidget(_host(auth, ExamOutcomeCard(auth: auth)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('I passed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();

      final (path, body) = api.posts.first;
      expect(path, '/user/exam-outcome');
      expect(body!['sat'], true);
      expect(body['passed'], true);
      expect(body['attemptNumber'], 1);
    });

    testWidgets('a fail is recorded too, and is the more valuable record', (tester) async {
      final api = _RecordingApi();
      final auth = _auth(api);
      await tester.pumpWidget(_host(auth, ExamOutcomeCard(auth: auth)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not this time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();

      final (_, body) = api.posts.first;
      expect(body!['sat'], true);
      expect(body['passed'], false);
      expect(body['attemptNumber'], 2);
    });

    testWidgets('not sitting it records no result at all', (tester) async {
      // A no-show stored as passed:false would make every pass rate computed
      // from this field wrong.
      final api = _RecordingApi();
      final auth = _auth(api);
      await tester.pumpWidget(_host(auth, ExamOutcomeCard(auth: auth)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('I did not sit it'));
      await tester.pumpAndSettle();

      final (_, body) = api.posts.first;
      expect(body!['sat'], false);
      expect(body.containsKey('passed'), isFalse);
    });

    testWidgets('closing it is a snooze, not a refusal', (tester) async {
      // One dismissal used to end the question forever while the email went
      // on asking four times. The phone is now as persistent as the email.
      final api = _RecordingApi();
      final auth = _auth(api);
      await tester.pumpWidget(_host(auth, ExamOutcomeCard(auth: auth)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      final (path, body) = api.posts.first;
      expect(path, '/user/exam-outcome');
      expect(body!['snoozed'], true);
      expect(body.containsKey('declined'), isFalse);
    });

    testWidgets('offers no permanent refusal, on purpose', (tester) async {
      // After the exam this is a departing user with one or two opens left. A
      // one-tap way to remove themselves from the only dataset that matters
      // costs more than it protects, and the sequence ends itself anyway.
      final auth = _auth(_RecordingApi());
      await tester.pumpWidget(_host(auth, ExamOutcomeCard(auth: auth)));
      await tester.pumpAndSettle();

      expect(find.textContaining('ask again'), findsNothing);
      expect(find.textContaining('Never'), findsNothing);
      // But putting it away is always one tap, every single time.
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('a failed request still lets the card go away', (tester) async {
      // Never trap anyone behind a research question.
      var done = false;
      final auth = _auth(_RecordingApi(fail: true));
      await tester.pumpWidget(
        _host(auth, ExamOutcomeCard(auth: auth, onDone: () => done = true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('I did not sit it'));
      await tester.pumpAndSettle();
      expect(done, isTrue);
    });

    testWidgets('it does not celebrate before it knows', (tester) async {
      final auth = _auth(_RecordingApi());
      await tester.pumpWidget(_host(auth, ExamOutcomeCard(auth: auth)));
      await tester.pumpAndSettle();
      expect(find.textContaining('Congratulations'), findsNothing);

      await tester.tap(find.text('Not this time'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Congratulations'), findsNothing);
      expect(find.textContaining('Thank you'), findsOneWidget);
    });
  });

  group('the school editor', () {
    testWidgets('saves the name and the year together', (tester) async {
      final api = _RecordingApi();
      final auth = _auth(api);
      await tester.pumpWidget(_host(auth, SchoolEditor(auth: auth)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Brigham Young University');
      await tester.tap(find.text('${graduationYears().first}'));
      await tester.tap(find.text('SPRING'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final (path, body) = api.posts.first;
      expect(path, '/user/school');
      expect(body!['name'], 'Brigham Young University');
      expect(body['graduationYear'], graduationYears().first);
      // Sent lowercase, which is what the server stores.
      expect(body['graduationTerm'], 'spring');
    });

    testWidgets('offers the four terms the owner named', (tester) async {
      final auth = _auth(_RecordingApi());
      await tester.pumpWidget(_host(auth, SchoolEditor(auth: auth)));
      await tester.pumpAndSettle();
      for (final t in graduationTerms) {
        // Uppercase, matching the exam date screen's month strip.
        expect(find.text(t.toUpperCase()), findsOneWidget);
      }
      expect(graduationTerms, ['Winter', 'Spring', 'Summer', 'Fall']);
    });

    testWidgets('a term without a year still saves, and the reverse too', (tester) async {
      // A May and a December graduate are a full exam cycle apart, so the term
      // is worth having even when somebody skips the year.
      final api = _RecordingApi();
      final auth = _auth(api);
      await tester.pumpWidget(_host(auth, SchoolEditor(auth: auth)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Purdue');
      await tester.tap(find.text('FALL'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final (_, body) = api.posts.first;
      expect(body!['graduationTerm'], 'fall');
      expect(body.containsKey('graduationYear'), isFalse);
    });

    testWidgets('the already-graduated action clears both halves', (tester) async {
      final api = _RecordingApi();
      final auth = _auth(api);
      await tester.pumpWidget(_host(auth, SchoolEditor(auth: auth)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Purdue');
      await tester.tap(find.text('SPRING'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I have already graduated'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final (_, body) = api.posts.first;
      expect(body!.containsKey('graduationTerm'), isFalse);
      expect(body.containsKey('graduationYear'), isFalse);
    });

    testWidgets('allows no year, because repeat takers have already graduated', (tester) async {
      final api = _RecordingApi();
      final auth = _auth(api);
      await tester.pumpWidget(_host(auth, SchoolEditor(auth: auth)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Purdue');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final (_, body) = api.posts.first;
      expect(body!['name'], 'Purdue');
      expect(body.containsKey('graduationYear'), isFalse);
    });

    testWidgets('refuses an empty name rather than storing nothing', (tester) async {
      final api = _RecordingApi();
      final auth = _auth(api);
      await tester.pumpWidget(_host(auth, SchoolEditor(auth: auth)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(api.posts, isEmpty);
      expect(find.text('Which school?'), findsOneWidget);
    });

    testWidgets('opens with what is already there', (tester) async {
      final auth = _auth(_RecordingApi(), {
        'email': 'a@b.com',
        'school': {'name': 'Texas A&M', 'graduationYear': graduationYears()[1]},
      });
      await tester.pumpWidget(_host(auth, SchoolEditor(auth: auth)));
      await tester.pumpAndSettle();
      expect(find.text('Texas A&M'), findsOneWidget);
    });

    testWidgets('says so when it could not save, and keeps what was typed', (tester) async {
      final auth = _auth(_RecordingApi(fail: true));
      await tester.pumpWidget(_host(auth, SchoolEditor(auth: auth)));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Lehigh');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not save'), findsOneWidget);
      expect(find.text('Lehigh'), findsOneWidget);
    });
  });

  group('the school row', () {
    testWidgets('reads Not set before it is answered', (tester) async {
      final auth = _auth(_RecordingApi());
      await tester.pumpWidget(_host(auth, SchoolRow(auth: auth)));
      await tester.pumpAndSettle();
      expect(find.text('Not set'), findsOneWidget);
    });

    testWidgets('shows the school and the year once both are known', (tester) async {
      final auth = _auth(_RecordingApi(), {
        'email': 'a@b.com',
        'school': {'name': 'Purdue', 'graduationYear': 2027},
      });
      await tester.pumpWidget(_host(auth, SchoolRow(auth: auth)));
      await tester.pumpAndSettle();
      expect(find.text('Purdue, 2027'), findsOneWidget);
    });

    testWidgets('shows the school alone when there is no year', (tester) async {
      final auth = _auth(_RecordingApi(), {
        'email': 'a@b.com',
        'school': {'name': 'Purdue', 'graduationYear': null},
      });
      await tester.pumpWidget(_host(auth, SchoolRow(auth: auth)));
      await tester.pumpAndSettle();
      expect(find.text('Purdue'), findsOneWidget);
    });
  });
}
