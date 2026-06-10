// Root navigation contract — typed routes shared by the navigator and screens.
export type RootStackParamList = {
  Tabs: undefined;
  // chapterId set → focused chapter practice; omitted → the daily spaced session.
  Review: { chapterId?: string } | undefined;
};
