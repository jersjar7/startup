// Which URL paths have a build-time prerendered index.html to serve.
//
// Kept in its own module so it can be asserted against the prerenderer's route
// list without importing service/index.js, which starts a listening server on
// require.
//
// KEEP IN SYNC WITH `ROUTES` IN scripts/prerender.mjs. The failure mode when
// these drift is silent and expensive: a prerendered page missing from this
// pattern still answers HTTP 200, because the SPA catch-all serves index.html
// for anything unmatched. The page looks correct in a browser and every crawler
// gets the generic landing title with none of the page's JSON-LD.
// prerenderedRoutes.test.js fails if a prerendered route is not covered here.
const PRERENDERED_ROUTE_PATTERN = /^\/(fe-civil-exam-guide|exam-simulation|fe-civil\/[a-z-]+)\/?$/;

module.exports = { PRERENDERED_ROUTE_PATTERN };
