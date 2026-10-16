import { describe, it, expect } from 'vitest';
import { appleAppSiteAssociation, androidAssetLinks, APP_PATHS, IOS_APP_ID } from './appLinks.js';

describe('apple-app-site-association', () => {
  it('claims verification and the results email for the shipping App ID', () => {
    const aasa = appleAppSiteAssociation();
    const detail = aasa.applinks.details[0];
    expect(detail.appIDs).toEqual([IOS_APP_ID]);
    expect(IOS_APP_ID).toBe('79KW5HMNLY.com.fe4raccoons.mobile');
    // The results email's own answer links, not just the card: a phone opens
    // the app only for a link tapped outside the browser (ADR 0023).
    expect(APP_PATHS).toEqual([
      '/verify-email/*',
      '/api/email/exam-result/*',
      '/api/email/exam-attempt/*',
      '/pass-card/*',
    ]);
    expect(detail.components).toEqual(APP_PATHS.map((p) => ({ '/': p })));
    // Every other API path stays a web request.
    expect(JSON.stringify(aasa)).not.toContain('/api/*');
    // Claiming more would open the app for pages it cannot show.
    expect(JSON.stringify(aasa)).not.toContain('reset-password');
  });
});

describe('assetlinks.json', () => {
  it('is withheld until an Android signing certificate exists', () => {
    expect(androidAssetLinks({})).toBeNull();
    expect(androidAssetLinks({ ANDROID_CERT_SHA256: '' })).toBeNull();
  });

  it('publishes every configured fingerprint for the package', () => {
    const links = androidAssetLinks({ ANDROID_CERT_SHA256: 'AA:BB, CC:DD' });
    expect(links[0].target.package_name).toBe('com.fe4raccoons.mobile');
    expect(links[0].target.sha256_cert_fingerprints).toEqual(['AA:BB', 'CC:DD']);
    expect(links[0].relation).toEqual(['delegate_permission/common.handle_all_urls']);
  });
});
