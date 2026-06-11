import { Platform } from 'react-native';

// Composition root — the ONLY place concrete implementations are constructed and
// wired to the domain ports. Swapping infrastructure happens here and nowhere else.

import { BundledContentDataSource } from '@/data/sources/content/BundledContentDataSource';
import { AsyncStorageKeyValueStore } from '@/data/sources/storage/AsyncStorageKeyValueStore';
import { SecureTokenStore } from '@/data/sources/storage/SecureTokenStore';
import { ApiClient } from '@/data/sources/api/ApiClient';
import { AccountRepositoryImpl } from '@/data/repositories/AccountRepositoryImpl';
import { SyncOutboxRepositoryImpl } from '@/data/repositories/SyncOutboxRepositoryImpl';
import { ServerMasteryRepositoryImpl } from '@/data/repositories/ServerMasteryRepositoryImpl';
import { SyncApi } from '@/data/sources/api/SyncApi';
import { ProblemRepositoryImpl } from '@/data/repositories/ProblemRepositoryImpl';
import { CardRepositoryImpl } from '@/data/repositories/CardRepositoryImpl';
import { ReviewRepositoryImpl } from '@/data/repositories/ReviewRepositoryImpl';
import { MasteryRepositoryImpl } from '@/data/repositories/MasteryRepositoryImpl';
import { PlanRepositoryImpl } from '@/data/repositories/PlanRepositoryImpl';
import { ChapterRepositoryImpl } from '@/data/repositories/ChapterRepositoryImpl';
import { StreakRepositoryImpl } from '@/data/repositories/StreakRepositoryImpl';
import { AppDataRepositoryImpl } from '@/data/repositories/AppDataRepositoryImpl';
import { DiagnosticRepositoryImpl } from '@/data/repositories/DiagnosticRepositoryImpl';
import { ReminderRepositoryImpl } from '@/data/repositories/ReminderRepositoryImpl';
import { SoundRepositoryImpl } from '@/data/repositories/SoundRepositoryImpl';
import { Sm2Scheduler } from '@/data/services/Sm2Scheduler';
import { ConceptMasteryPolicy } from '@/data/services/ConceptMasteryPolicy';
import { AdaptivePacingPolicy } from '@/data/services/AdaptivePacingPolicy';
import { ExpoReminderScheduler } from '@/data/services/ExpoReminderScheduler';
import { ExpoSoundEngine } from '@/data/services/ExpoSoundEngine';
import { sound } from '@/core/sound';

import { GetDailySession } from '@/domain/usecases/GetDailySession';
import { ComputeStudyPlan } from '@/domain/usecases/ComputeStudyPlan';
import { GetOverallMastery } from '@/domain/usecases/GetOverallMastery';
import { GetChapterMastery } from '@/domain/usecases/GetChapterMastery';
import { SubmitReview } from '@/domain/usecases/SubmitReview';
import { SetStudyPreferences } from '@/domain/usecases/SetStudyPreferences';
import { GetChapterProgress } from '@/domain/usecases/GetChapterProgress';
import { GetChapterPractice } from '@/domain/usecases/GetChapterPractice';
import { GetStudyPreferences } from '@/domain/usecases/GetStudyPreferences';
import { PreviewStudyPlan } from '@/domain/usecases/PreviewStudyPlan';
import { GetStreak } from '@/domain/usecases/GetStreak';
import { RecordStudyDay } from '@/domain/usecases/RecordStudyDay';
import { ResetAllProgress } from '@/domain/usecases/ResetAllProgress';
import { GetDiagnosticQuestions } from '@/domain/usecases/GetDiagnosticQuestions';
import { SubmitDiagnostic } from '@/domain/usecases/SubmitDiagnostic';
import { GetReminder } from '@/domain/usecases/GetReminder';
import { SetReminder } from '@/domain/usecases/SetReminder';
import { GetSoundEnabled } from '@/domain/usecases/GetSoundEnabled';
import { SetSoundEnabled } from '@/domain/usecases/SetSoundEnabled';
import { GetReviewStats } from '@/domain/usecases/GetReviewStats';
import { GetWeekActivity } from '@/domain/usecases/GetWeekActivity';
import { SignIn } from '@/domain/usecases/SignIn';
import { GetAccount } from '@/domain/usecases/GetAccount';
import { SignOut } from '@/domain/usecases/SignOut';
import { DeleteAccount } from '@/domain/usecases/DeleteAccount';
import { SyncNow } from '@/domain/usecases/SyncNow';
import { GetSyncStatus } from '@/domain/usecases/GetSyncStatus';

export interface UseCases {
  readonly getDailySession: GetDailySession;
  readonly getChapterPractice: GetChapterPractice;
  readonly computeStudyPlan: ComputeStudyPlan;
  readonly previewStudyPlan: PreviewStudyPlan;
  readonly getOverallMastery: GetOverallMastery;
  readonly getChapterMastery: GetChapterMastery;
  readonly getChapterProgress: GetChapterProgress;
  readonly submitReview: SubmitReview;
  readonly getStudyPreferences: GetStudyPreferences;
  readonly setStudyPreferences: SetStudyPreferences;
  readonly getStreak: GetStreak;
  readonly recordStudyDay: RecordStudyDay;
  readonly resetAllProgress: ResetAllProgress;
  readonly getDiagnosticQuestions: GetDiagnosticQuestions;
  readonly submitDiagnostic: SubmitDiagnostic;
  readonly getReminder: GetReminder;
  readonly setReminder: SetReminder;
  readonly getSoundEnabled: GetSoundEnabled;
  readonly setSoundEnabled: SetSoundEnabled;
  readonly getReviewStats: GetReviewStats;
  readonly getWeekActivity: GetWeekActivity;
  readonly signIn: SignIn;
  readonly getAccount: GetAccount;
  readonly signOut: SignOut;
  readonly deleteAccount: DeleteAccount;
  readonly syncNow: SyncNow;
  readonly getSyncStatus: GetSyncStatus;
}

export function createUseCases(): UseCases {
  // sources
  const content = new BundledContentDataSource();
  const store = new AsyncStorageKeyValueStore();

  // services (domain ports → concrete)
  const scheduler = new Sm2Scheduler();
  const masteryPolicy = new ConceptMasteryPolicy();
  const pacing = new AdaptivePacingPolicy();

  // repositories (domain ports → concrete)
  const problems = new ProblemRepositoryImpl(content);
  const cards = new CardRepositoryImpl(content);
  const reviews = new ReviewRepositoryImpl(store, content);
  const diagnostic = new DiagnosticRepositoryImpl(store);
  const serverMastery = new ServerMasteryRepositoryImpl(store);
  const mastery = new MasteryRepositoryImpl(content, reviews, masteryPolicy, diagnostic, serverMastery);
  const plans = new PlanRepositoryImpl(store);
  const chapters = new ChapterRepositoryImpl(content);
  const streaks = new StreakRepositoryImpl(store);
  const appData = new AppDataRepositoryImpl(store);
  const reminderRepo = new ReminderRepositoryImpl(store);
  const reminderScheduler = new ExpoReminderScheduler();
  const soundRepo = new SoundRepositoryImpl(store);
  const tokenStore = new SecureTokenStore();
  const api = new ApiClient(() => tokenStore.get());
  const accounts = new AccountRepositoryImpl(api, tokenStore, store);
  const outbox = new SyncOutboxRepositoryImpl(store);
  const syncApi = new SyncApi(api);
  // Event source tag: the harness runs on web; real builds are ios/android.
  const eventSource = Platform.OS === 'android' ? ('android' as const) : ('ios' as const);

  // Wire the global sound controller: engine now, persisted on/off once loaded.
  sound.configure(new ExpoSoundEngine(), true);
  void soundRepo.getEnabled().then((on) => sound.setEnabled(on));

  // use cases
  return {
    getDailySession: new GetDailySession(reviews, cards, problems),
    getChapterPractice: new GetChapterPractice(cards, problems),
    computeStudyPlan: new ComputeStudyPlan(plans, mastery, pacing),
    previewStudyPlan: new PreviewStudyPlan(mastery, pacing),
    getOverallMastery: new GetOverallMastery(mastery),
    getChapterMastery: new GetChapterMastery(mastery),
    getChapterProgress: new GetChapterProgress(chapters, mastery),
    submitReview: new SubmitReview(reviews, scheduler, outbox, eventSource),
    getStudyPreferences: new GetStudyPreferences(plans),
    setStudyPreferences: new SetStudyPreferences(plans, accounts),
    getStreak: new GetStreak(streaks),
    recordStudyDay: new RecordStudyDay(streaks),
    resetAllProgress: new ResetAllProgress(appData),
    getDiagnosticQuestions: new GetDiagnosticQuestions(chapters, problems),
    submitDiagnostic: new SubmitDiagnostic(diagnostic, reviews, scheduler, outbox, eventSource),
    getReminder: new GetReminder(reminderRepo),
    setReminder: new SetReminder(reminderRepo, reminderScheduler),
    getSoundEnabled: new GetSoundEnabled(soundRepo),
    setSoundEnabled: new SetSoundEnabled(soundRepo),
    getReviewStats: new GetReviewStats(reviews),
    getWeekActivity: new GetWeekActivity(streaks),
    signIn: new SignIn(accounts, diagnostic),
    getAccount: new GetAccount(accounts),
    signOut: new SignOut(accounts),
    deleteAccount: new DeleteAccount(accounts, appData),
    syncNow: new SyncNow(accounts, outbox, syncApi, reviews, scheduler, serverMastery),
    getSyncStatus: new GetSyncStatus(serverMastery, outbox),
  };
}
