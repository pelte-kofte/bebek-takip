// ignore_for_file: constant_identifier_names

const String LEGAL_BASE_URL = 'https://nilico-c8f58.web.app/';
const String TERMS_URL = '${LEGAL_BASE_URL}terms.html';
const String PRIVACY_URL = '${LEGAL_BASE_URL}privacy.html';

void debugAssertLegalUrls() {
  assert(TERMS_URL.startsWith(LEGAL_BASE_URL));
  assert(PRIVACY_URL.startsWith(LEGAL_BASE_URL));
}
