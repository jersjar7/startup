// Composition root — the ONLY place concrete implementations are constructed and
// wired to the domain ports. Swapping infrastructure happens here and nowhere else.

import { BundledContentDataSource } from '@/data/sources/content/BundledContentDataSource';
import { AsyncStorageKeyValueStore } from '@/data/sources/storage/AsyncStorageKeyValueStore';
import { ProblemRepositoryImpl } from '@/data/repositories/ProblemRepositoryImpl';
import { CardRepositoryImpl } from '@/data/repositories/CardRepositoryImpl';
import { ReviewRepositoryImpl } from '@/data/repositories/ReviewRepositoryImpl';
import { MasteryRepositoryImpl } from '@/data/repositories/MasteryRepositoryImpl';
import { PlanRepositoryImpl } from '@/data/repositories/PlanRepositoryImpl';
import { ChapterRepositoryImpl } from '@/data/repositories/ChapterRepositoryImpl';
import { StreakRepositoryImpl } from '@/data/repositories/StreakRepositoryImpl';
import { AppDataRepositoryImpl } from '@/data/repositories/AppDataRepositoryImpl';
import { DiagnosticRepositoryImpl } from '@/data/repositories/DiagnosticRepositoryImpl';
import { Sm2Scheduler } from '@/data/services/Sm2Scheduler';
import { ConceptMasteryPolicy } from '@/data/services/ConceptMasteryPolicy';
import { AdaptivePacingPolicy } from '@/data/services/AdaptivePacingPolicy';

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
  const mastery = new MasteryRepositoryImpl(content, reviews, masteryPolicy, diagnostic);
  const plans = new PlanRepositoryImpl(store);
  const chapters = new ChapterRepositoryImpl(content);
  const streaks = new StreakRepositoryImpl(store);
  const appData = new AppDataRepositoryImpl(store);

  // use cases
  return {
    getDailySession: new GetDailySession(reviews, cards, problems),
    getChapterPractice: new GetChapterPractice(cards, problems),
    computeStudyPlan: new ComputeStudyPlan(plans, mastery, pacing),
    previewStudyPlan: new PreviewStudyPlan(mastery, pacing),
    getOverallMastery: new GetOverallMastery(mastery),
    getChapterMastery: new GetChapterMastery(mastery),
    getChapterProgress: new GetChapterProgress(chapters, mastery),
    submitReview: new SubmitReview(reviews, scheduler),
    getStudyPreferences: new GetStudyPreferences(plans),
    setStudyPreferences: new SetStudyPreferences(plans),
    getStreak: new GetStreak(streaks),
    recordStudyDay: new RecordStudyDay(streaks),
    resetAllProgress: new ResetAllProgress(appData),
    getDiagnosticQuestions: new GetDiagnosticQuestions(chapters, problems),
    submitDiagnostic: new SubmitDiagnostic(diagnostic),
  };
}
