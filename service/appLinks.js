// The association files that let one link serve two places.
//
// The verification email links to https://fe4raccoons.com/verify-email/<token>.
// With these files published, iOS (Universal Links) and Android (App Links)
// open that link in the installed app; without the app, or on a desktop, the
// website's own /verify-email page handles it. Nothing about the link changes.
//
// Apple fetches apple-app-site-association through its CDN when the app is
// installed and requires it to be served as application/json from
// /.well-known/. The App ID is <team>.<bundle>. See docs/mobile/universal-links.md.

const IOS_APP_ID = '79KW5HMNLY.com.fe4raccoons.mobile';
const ANDROID_PACKAGE = 'com.fe4raccoons.mobile';

/** Paths the app claims. Everything else on the domain stays a web page. */
const APP_PATHS = ['/verify-email/*'];

function appleAppSiteAssociation() {
  return {
    applinks: {
      // Both spellings: `components` is the current form, `paths` keeps older
      // iOS releases happy.
      details: [
        {
          appIDs: [IOS_APP_ID],
          appID: IOS_APP_ID,
          paths: APP_PATHS,
          components: APP_PATHS.map((p) => ({ '/': p })),
        },
      ],
    },
  };
}

/**
 * Android's equivalent. It needs the SHA-256 fingerprint of the certificate
 * the APK is signed with, which does not exist until the app ships on
 * Android; until then there is nothing honest to publish, and the route
 * returns 404. Set ANDROID_CERT_SHA256 (comma-separated for several) when it
 * does.
 */
function androidAssetLinks(env = process.env) {
  const fingerprints = (env.ANDROID_CERT_SHA256 || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  if (fingerprints.length === 0) return null;
  return [
    {
      relation: ['delegate_permission/common.handle_all_urls'],
      target: {
        namespace: 'android_app',
        package_name: ANDROID_PACKAGE,
        sha256_cert_fingerprints: fingerprints,
      },
    },
  ];
}

module.exports = { appleAppSiteAssociation, androidAssetLinks, APP_PATHS, IOS_APP_ID, ANDROID_PACKAGE };
