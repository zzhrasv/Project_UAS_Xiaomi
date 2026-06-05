import 'package:flutter_test/flutter_test.dart';
import 'package:project_uas_xiaomi/app.dart';

// Widget test dasar — smoke test bahwa App dapat di-render tanpa crash.
// Test lebih lengkap akan ditambahkan per fitur.
void main() {
  testWidgets('App smoke test — renders without crashing', (WidgetTester tester) async {
    // Build App widget
    await tester.pumpWidget(const App());

    // App berhasil di-render jika tidak ada exception
    expect(tester.takeException(), isNull);
  });
}
