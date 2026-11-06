// Preloaded into the API for local end-to-end runs ONLY (node -r). Replaces the
// Resend client so no email leaves the machine: every send is appended, as one
// JSON line, to MAIL_CAPTURE_FILE, where the test reads the student code.
const Module = require('module');
const fs = require('fs');

const out = process.env.MAIL_CAPTURE_FILE;
if (!out) throw new Error('mail-capture: set MAIL_CAPTURE_FILE');

const load = Module._load;
Module._load = function patched(request, ...rest) {
  if (request === 'resend') {
    return {
      Resend: class {
        constructor() {
          this.emails = {
            send: async (p) => {
              fs.appendFileSync(out, `${JSON.stringify({ to: p.to, subject: p.subject, html: p.html || '', text: p.text || '' })}\n`);
              return { data: { id: `captured-${Date.now()}` }, error: null };
            },
          };
        }
      },
    };
  }
  return load.call(this, request, ...rest);
};
