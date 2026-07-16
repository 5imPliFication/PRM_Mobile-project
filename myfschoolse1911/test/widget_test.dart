import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfschoolse1911/vn/edu/fpt/view/login.dart';

void main() {
  testWidgets('Login screen renders phone field and login button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    // Login button label
    expect(find.text('Đăng nhập'), findsWidgets);
    // Phone input icon present
    expect(find.byIcon(Icons.phone), findsOneWidget);
    // Password input icon present
    expect(find.byIcon(Icons.key), findsOneWidget);
  });
}