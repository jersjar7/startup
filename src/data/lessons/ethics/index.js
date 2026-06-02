import obligationsPublic from './obligations-public';
import obligationsEmployersPeers from './obligations-employers-peers';
import definitionsPractice from './definitions-practice';
import licensureDiscipline from './licensure-discipline';
import ipSustainability from './ip-sustainability';
import engineeringContracts from './engineering-contracts';
import professionalLiability from './professional-liability';

export default [
  { subtopicId: 'professional-conduct', lessons: [obligationsPublic, obligationsEmployersPeers] },
  { subtopicId: 'licensure-and-law', lessons: [definitionsPractice, licensureDiscipline] },
  { subtopicId: 'contracts-liability', lessons: [engineeringContracts, professionalLiability] },
  { subtopicId: 'broader-responsibilities', lessons: [ipSustainability] },
];
