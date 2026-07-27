// Plausible queue stub + init. Kept in its own same-origin file (not inline in
// index.html) so the CSP in service/index.js can stay at script-src 'self'
// plus plausible.io, with no 'unsafe-inline' and no hash to re-compute on edit.
window.plausible =
  window.plausible ||
  function () {
    (plausible.q = plausible.q || []).push(arguments);
  };
plausible.init = plausible.init || function (i) { plausible.o = i || {}; };
plausible.init();
