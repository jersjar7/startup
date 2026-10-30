// Search engines cut titles past about 70 characters (Bing flags them), so the
// brand suffix goes only where it fits. The page name always comes first.
const BRAND = ' | FE for Raccoons';
export const TITLE_MAX = 70;

export function pageTitle(name) {
  return name.length + BRAND.length <= TITLE_MAX ? name + BRAND : name;
}

// Shorter chapter names for titles: "Ethics & Prof. Practice Practice
// Problems" repeats itself, and the full math name pushes past the limit.
const TITLE_NAMES = { mathematics: 'Mathematics', ethics: 'Ethics' };
export function titleName(topic) {
  return TITLE_NAMES[topic.id] || topic.name;
}
