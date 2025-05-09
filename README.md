
# QuickTask Flutter

A Flutter application for task management with AI prioritization, based on a Next.js prototype.

## Features

- Create, view, complete, and delete tasks.
- Tasks are stored locally on the device.
- AI-powered task prioritization (requires a backend Genkit flow endpoint).

## Getting Started

This project is a Flutter application.

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- An editor like Android Studio (with Flutter plugin) or VS Code (with Flutter extension).

### Running the app

1.  Clone the repository (if applicable) or ensure you have the `flutter_app` directory.
2.  Navigate to the `flutter_app` directory:
    ```bash
    cd flutter_app
    ```
3.  Get Flutter dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the app on an emulator or connected device:
    ```bash
    flutter run
    ```

### AI Prioritization Backend

The AI task prioritization feature relies on an external backend service that exposes the Genkit flow `prioritizeTaskListFlow`.

- The current placeholder endpoint in `lib/services/ai_service.dart` is `http://10.0.2.2:4000/flows/prioritizeTaskListFlow`.
    - `10.0.2.2` is the standard alias for the host machine's localhost when running in an Android emulator.
    - The port `4000` and path `/flows/prioritizeTaskListFlow` are common defaults for Genkit dev servers but might need adjustment based on your Genkit setup.
- If you are running the original Next.js project's Genkit dev server (`npm run genkit:dev`), ensure it's accessible from your Flutter environment and update the endpoint URL in `ai_service.dart` if necessary.
- For physical device testing, replace `10.0.2.2` with your computer's local network IP address.
- For production, this Genkit flow should be deployed (e.g., to Firebase Functions, Google Cloud Run) and the endpoint URL updated accordingly.
