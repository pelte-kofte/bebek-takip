import 'package:flutter_test/flutter_test.dart';
import 'package:bebek_takip/constants/legal_urls.dart';

void main() {
  test('legal URLs use Firebase Hosting domain and exact paths', () {
    expect(LEGAL_BASE_URL, 'https://nilico-c8f58.web.app/');
    expect(TERMS_URL, 'https://nilico-c8f58.web.app/terms.html');
    expect(PRIVACY_URL, 'https://nilico-c8f58.web.app/privacy.html');
    expect(TERMS_URL.startsWith(LEGAL_BASE_URL), isTrue);
    expect(PRIVACY_URL.startsWith(LEGAL_BASE_URL), isTrue);
  });
}
