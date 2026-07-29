import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.js'],
    // service/ was previously excluded, so its 13 test files existed but never
    // ran. All of them pass; keep them in the default run so backend regressions
    // are actually caught.
    include: ['src/**/*.test.{js,jsx}', 'service/**/*.test.js'],
  },
});
