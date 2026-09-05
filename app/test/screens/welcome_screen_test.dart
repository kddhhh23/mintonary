import 'package:flutter_test/flutter_test.dart';
import 'package:mintonary/main.dart';
import 'package:mintonary/screens/profile_setup_screen.dart';
import 'package:mintonary/screens/welcome_screen.dart';

void main() {
  testWidgets('첫 화면에 앱 설명과 시작하기 버튼을 표시한다', (tester) async {
    await tester.pumpWidget(const MintonaryApp(home: WelcomeScreen()));

    expect(find.text('민터너리'), findsOneWidget);
    expect(find.text('나의 배드민턴 다이어리'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
  });

  testWidgets('시작하기를 누르면 프로필 입력 화면으로 이동한다', (tester) async {
    await tester.pumpWidget(const MintonaryApp(home: WelcomeScreen()));

    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(find.text('내 정보 설정'), findsOneWidget);
    expect(find.text('닉네임 *'), findsOneWidget);
  });
}
