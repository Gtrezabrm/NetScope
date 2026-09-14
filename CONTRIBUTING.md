# Contributing to NetScope

Thanks for helping improve NetScope.

## Before opening an issue

- Confirm the issue is reproducible on the latest version.
- Include the device/Android version when relevant.
- Include the network type (Wi-Fi/mobile) and useful test details.
- Never include passwords, API keys, private keys, or other secrets.

## Pull requests

1. Keep changes focused and easy to review.
2. Run `flutter pub get`.
3. Run `dart format lib test`.
4. Run `flutter analyze`.
5. Run `flutter test`.
6. Explain any user-visible measurement or behavior changes.

## Measurement integrity

NetScope is a diagnostic application. Do not add claims that a test proves more than it actually measures. In particular, TCP connectivity must not be presented as guaranteed in-game ping.
