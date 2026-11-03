/// The FE Reference Handbook edition every cited page refers to. NCEES
/// supplies the current edition on exam day; when it changes, remap the pages
/// and change this one value. The website keeps the same value in
/// src/data/handbook.js.
const handbookEdition = '10.6';

/// "Handbook p. 182" becomes "Handbook 10.6, p. 182". Only a label that
/// gives a page changes: one naming a section ("Handbook, consolidation") or
/// another reference (MUTCD, Model Rules) is left as written, so the sheet's
/// one-line eyebrow does not wrap. A label that already names the edition is
/// not changed again, so content packs can carry the edition and the sheet
/// can still apply it.
String handbookLabel(String label) {
  if (label.contains('Handbook $handbookEdition')) return label;
  return label.replaceFirstMapped(
    RegExp(r'^(FE )?Handbook (?=pp?\. )'),
    (m) => '${m[1] ?? ''}Handbook $handbookEdition, ',
  );
}
