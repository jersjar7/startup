import obligationsPublic from './obligations-public';
import obligationsEmployersPeers from './obligations-employers-peers';
import definitionsPractice from './definitions-practice';
import licensureDiscipline from './licensure-discipline';
import ipSustainability from './ip-sustainability';

export default [
  { subtopicId: 'professional-conduct', lessons: [obligationsPublic, obligationsEmployersPeers] },
  { subtopicId: 'licensure-and-law', lessons: [definitionsPractice, licensureDiscipline] },
  { subtopicId: 'broader-responsibilities', lessons: [ipSustainability] },
];
