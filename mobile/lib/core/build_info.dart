/// The TestFlight build number, passed at build time
/// (`--dart-define=BUILD_NUMBER=$N`, see RELEASING.md). "dev" in a debug run.
/// Feedback reports carry it so a report can be tied to what the student saw.
const appBuild = String.fromEnvironment('BUILD_NUMBER', defaultValue: 'dev');
