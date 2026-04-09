# Savings Goal Enhancements TODO

## Approved Plan Implementation Steps

- [x] **Step 1**: Update `pubspec.yaml` - Add image_picker, path_provider, image dependencies
- [x] **Step 2**: Run `flutter pub get`
- [x] **Step 3**: Update `lib/models/goal_model.dart` - Add imageData field (base64), dailyTarget/weeklyTarget getters, update serialization
- [x] **Step 4**: Update `lib/screens/goals_page.dart` - Add image picker to form, daily/weekly previews, preset buttons (1Y/2Y), image in GoalCard
- [x] **Step 5**: Update `lib/screens/home_page.dart` - Add image to _GoalPreviewTile
- [x] **Step 6**: Test add/edit goal with image/presets/breakdowns
- [x] **Step 7**: Run `flutter analyze` and fix issues (added missing imports, error handling)
- [x] **Complete**: All features working, data persists, errors fixed

App fully functional with image support, charts, transactions. Run `flutter run` to test.

