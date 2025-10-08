# Contributing to Bangla Weather

Thank you for your interest in contributing to Bangla Weather! This project aims to provide accessible weather information for disaster-prone coastal communities in Bangladesh and beyond.

## 🤝 How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **🐛 Bug Reports**: Report issues you encounter
- **✨ Feature Requests**: Suggest new features or improvements
- **📝 Documentation**: Improve setup guides, code comments, or user documentation
- **🌐 Translation**: Add support for more languages
- **🎨 UI/UX**: Improve accessibility and user experience
- **🧪 Testing**: Add test coverage or help with testing
- **💻 Code**: Fix bugs, implement features, or improve performance

### Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
```bash
git clone https://github.com/tech-with-m/choy-ritur-golpo.git
cd choy-ritur-golpo
```
3. **Create a new branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Set up the development environment** following the [SETUP.md](SETUP.md) guide
5. **Make your changes** and test them thoroughly
6. **Commit your changes** with clear, descriptive messages
7. **Push to your fork** and create a Pull Request

## 📋 Development Guidelines

### Code Style

- **Follow Flutter/Dart style guidelines**: Use `dart format` to format your code
- **Use meaningful names**: Variables, functions, and classes should have descriptive names
- **Add comments**: Explain complex logic and business rules
- **Keep functions small**: Aim for single responsibility
- **Use const constructors**: When possible, use `const` for better performance

### Commit Messages

Use clear, descriptive commit messages:

```bash
# Good examples
git commit -m "Add support for Hindi language translation"
git commit -m "Fix crash when weather data is null"
git commit -m "Improve accessibility for screen readers"

# Avoid
git commit -m "fix bug"
git commit -m "update"
git commit -m "changes"
```

### Testing

- **Test your changes**: Ensure the app runs without crashes
- **Test on different devices**: If possible, test on various screen sizes
- **Test offline functionality**: Verify the app works without internet
- **Test accessibility**: Ensure the app is usable with screen readers

## 🎯 Areas for Contribution

### High Priority

1. **🌐 Multi-language Support**
   - Add Hindi, Urdu, or other regional languages
   - Improve existing Bangla translations
   - Add right-to-left (RTL) language support

2. **♿ Accessibility Improvements**
   - Improve screen reader compatibility
   - Add voice announcements for weather alerts
   - Enhance color contrast and visual accessibility

3. **🧪 Testing**
   - Add unit tests for business logic
   - Add widget tests for UI components
   - Add integration tests for critical user flows

4. **📱 Cross-platform Support**
   - iOS version development
   - Web version for broader access
   - Desktop version for emergency centers

### Medium Priority

1. **🎨 UI/UX Enhancements**
   - Improve weather visualization
   - Add more weather icons and animations
   - Enhance the seasons tab with more cultural content

2. **📊 Features**
   - Add weather history and trends
   - Integrate with local market prices

3. **🔧 Technical Improvements**
   - Optimize app performance
   - Reduce app size
   - Improve offline data management

4. **📚 Documentation**
   - Improve setup guides
   - Add API documentation
   - Create video tutorials

### Low Priority

1. **🎮 Gamification**
   - Add weather-related mini-games
   - Weather prediction challenges
   - Community weather sharing

2. **🔗 Integrations**
   - Social media sharing
   - Integration with other weather services
   - Community features

## 🐛 Reporting Issues

### Before Reporting

1. **Check existing issues**: Search for similar problems
2. **Update to latest version**: Ensure you're using the latest code
3. **Test on different devices**: Verify the issue is reproducible

### Issue Template

When reporting issues, please include:

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Device information:**
- Device: [e.g. Samsung Galaxy S21]
- OS: [e.g. Android 12]
- App version: [e.g. 1.1.0]

**Additional context**
Any other context about the problem.
```

## ✨ Feature Requests

### Before Requesting

1. **Check existing requests**: Search for similar feature requests
2. **Consider the project scope**: Ensure the feature aligns with project goals
3. **Think about implementation**: Consider how the feature might be implemented

### Feature Request Template

```markdown
**Feature description**
A clear description of the feature you'd like to see.

**Problem it solves**
What problem does this feature solve?

**Proposed solution**
How would you like this feature to work?

**Alternatives considered**
Any alternative solutions you've considered.

**Additional context**
Any other context about the feature request.
```

## 🔄 Pull Request Process

### Before Submitting

1. **Test thoroughly**: Ensure your changes work as expected
2. **Update documentation**: Update relevant documentation
3. **Add tests**: If applicable, add tests for your changes
4. **Check formatting**: Run `dart format` on your code

### Pull Request Template

```markdown
**Description**
Brief description of changes.

**Type of change**
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

**Testing**
- [ ] Tested on Android device
- [ ] Tested offline functionality
- [ ] Tested accessibility features
- [ ] Added/updated tests

**Screenshots**
If applicable, add screenshots.

**Checklist**
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

### Review Process

1. **Automated checks**: CI/CD will run tests and checks
2. **Code review**: Maintainers will review your code
3. **Testing**: Changes will be tested on various devices
4. **Approval**: Once approved, changes will be merged

## 🌍 Translation Guidelines

### Adding New Languages

1. **Create translation file**: Copy `lib/translation/bn_in.dart` to `lib/translation/[language_code].dart`
2. **Translate all strings**: Provide accurate translations for all weather terms
3. **Test thoroughly**: Ensure translations fit in the UI
4. **Cultural adaptation**: Adapt content for local context

### Translation Best Practices

- **Use simple language**: Avoid technical jargon
- **Consider cultural context**: Adapt examples and references
- **Test with native speakers**: Get feedback from native speakers
- **Maintain consistency**: Use consistent terminology

## 🧪 Testing Guidelines

### Unit Tests

```dart
// Example unit test
test('should format temperature correctly', () {
  final formatter = TemperatureFormatter();
  expect(formatter.format(25.5), '২৫.৫°C');
});
```

### Widget Tests

```dart
// Example widget test
testWidgets('should display weather information', (tester) async {
  await tester.pumpWidget(WeatherWidget());
  expect(find.text('আজ বৃষ্টি হবে'), findsOneWidget);
});
```

### Integration Tests

```dart
// Example integration test
testWidgets('should show weather data after loading', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.pumpAndSettle();
  expect(find.byType(WeatherCard), findsOneWidget);
});
```

## 📚 Documentation Guidelines

### Code Documentation

```dart
/// Formats temperature for display in Bangla
/// 
/// Takes a temperature in Celsius and returns a formatted string
/// with Bangla numerals and degree symbol.
/// 
/// Example:
/// ```dart
/// final formatter = TemperatureFormatter();
/// print(formatter.format(25.5)); // "২৫.৫°C"
/// ```
class TemperatureFormatter {
  String format(double temperature) {
    // Implementation
  }
}
```

### README Updates

When updating documentation:
- **Keep it simple**: Use clear, simple language
- **Include examples**: Provide code examples where helpful
- **Update screenshots**: Keep screenshots current
- **Test instructions**: Verify setup instructions work

## 🎨 Design Guidelines

### Accessibility

- **Color contrast**: Ensure sufficient contrast ratios
- **Touch targets**: Minimum 44x44 dp touch targets
- **Screen readers**: Add semantic labels
- **Keyboard navigation**: Support keyboard navigation

### Visual Design

- **Consistent styling**: Follow Material Design principles
- **Cultural appropriateness**: Use culturally appropriate imagery
- **Simple layouts**: Avoid complex, cluttered interfaces
- **Clear hierarchy**: Use typography and spacing to create clear hierarchy

## 🚀 Release Process

### Version Numbering

We use semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Breaking changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version number updated
- [ ] Changelog updated
- [ ] Release notes prepared
- [ ] APK/AAB built and tested

## 📞 Getting Help

### Community Support

- **GitHub Discussions**: Ask questions and share ideas
- **GitHub Issues**: Report bugs and request features
- **Email**: Contact maintainers directly

### Development Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)
- [Accessibility Guidelines](https://flutter.dev/docs/development/accessibility-and-localization/accessibility)

## 🏆 Recognition

Contributors will be recognized in:
- **README.md**: Listed as contributors
- **Release notes**: Mentioned in release announcements
- **GitHub**: Appear in contributor statistics

## 📄 License

By contributing to Bangla Weather, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to making weather information more accessible for vulnerable communities! 🌟**