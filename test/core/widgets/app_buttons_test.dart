import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/core/theme/app_theme.dart';
import 'package:things_to_win/core/widgets/app_buttons.dart';

void main() {
  testWidgets(
    'AppPrimaryButton expand:false has finite size inside a row',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(child: Text('Header')),
                  AppPrimaryButton(
                    label: 'Open habits',
                    expand: false,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final buttonRenderBox = tester.renderObject<RenderBox>(
        find.byType(FilledButton),
      );
      expect(buttonRenderBox.hasSize, isTrue);
      expect(buttonRenderBox.size.width.isFinite, isTrue);
      expect(buttonRenderBox.size.width, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );
}
