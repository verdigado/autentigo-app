# Autentigo

This is a Dart app that implements an Keycloak App Authenticator from the [netzbegruenung/keycloak-mfa-plugins](https://github.com/netzbegruenung/keycloak-mfa-plugins/tree/main/app-authenticator) app authenticator.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Deployment Setup

Fastlane can be installed in multiple ways. The preferred method is with Bundler.

First install ruby on your system. If you use macOS, system Ruby is not recommended. For macOS and Linux, rbenv is one of the most popular ways to manage your Ruby environment.
If you choose rbenv to install ruby, bundler will be available too.

Every time you run fastlane, use `bundle exec fastlane [lane]`
To update fastlane, just run `bundle update fastlane`

## CircleCI config updates

1. Install CircleCI command line interface https://circleci.com/docs/local-cli/#alternative-installation-method
2. Place your CircleCI config under `.circleci/src` https://circleci.com/docs/how-to-use-the-circleci-local-cli/#packing-a-config
3. Run `circleci config pack .circleci/src > .circleci/config.yml` to merge your changes into single YAML file
4. Validate your config `circleci config validate`
