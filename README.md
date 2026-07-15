# Macktech Mobile

Macktech Mobile is an Android e-commerce application built with Flutter.

## Features

- **Authentication:** Secure user login and registration with JWT and role-based access control.

- **Product Discovery:** Browse products, view details, and get personalized recommendations powered by Recombee.
- **Shopping & Checkout:** Manage wishlists, shopping carts, and handle complete checkout flows.
- **Customer Support:** Create and manage support tickets with image uploads.
- **AI & Live Chat:** Built-in AI assistant for immediate help (featuring Markdown formatting and smart tool integration), and real-time STOMP/WebSocket live chat with support agents.
- **Admin Dashboard:** Comprehensive admin features including user management, product/promo code CRUD, order tracking, and a real-time revenue dashboard.
- **Push Notifications:** Stay updated with order status and promotions via Firebase Cloud Messaging (FCM).

## Setup & Installation

This application requires the Macktech backend services to be running. By default, the app is configured to communicate with the local backend environment (e.g., `http://10.0.2.2:8080`).

### Prerequisites
1. **Flutter SDK:** Ensure you have Flutter ^3.11.4 installed.
2. **Android Studio:** Required for Android SDK and emulator setup (this is an Android-only app).
3. **Environment File:** You must create a `.env` file in the project root containing your API keys and configuration.

### Installation Steps

1. **Clone the repository and install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase:**
   - The app uses Firebase for Auth, Storage, and FCM.
   - You must obtain the `google-services.json` file for your Firebase project and place it in `android/app/`.
   - Ensure `lib/firebase_options.dart` is correctly configured for your environment.

3. **Run the App:**
   Start your Android emulator or connect a physical device, then run:
   ```bash
   flutter run
   ```

## Third-Party Libraries & Plugins

This project heavily relies on several key packages (see `pubspec.yaml` for exact versions):

### Core & State Management
- **`flutter_riverpod`**: Robust, compile-safe state management.
- **`shared_preferences`**: Local persistence for user sessions.
- **`flutter_dotenv`**: Environment variable management (`.env`).

### Networking & Real-Time
- **`dio` / `retrofit`**: Network clients for interacting with the Macktech REST APIs.
- **`stomp_dart_client`**: WebSocket STOMP client for real-time Agent-Customer live chat.

### Firebase Integration
- **`firebase_core`**: Base Firebase plugin.
- **`firebase_auth`**: Email/Password authentication.
- **`google_sign_in` / `flutter_facebook_auth`**: Social login integration.
- **`firebase_storage`**: Cloud storage for uploading support ticket images.
- **`firebase_messaging` / `flutter_local_notifications`**: Push notifications (FCM).

### UI & Utilities
- **`google_maps_flutter` / `geolocator`**: Location services and maps for addresses.
- **`webview_flutter`**: In-app browser for handling payment gateways.
- **`image_picker`**: Accessing the device camera/gallery for support tickets.
- **`intl_phone_field`**: Phone number formatting and validation.
- **`fl_chart`**: Rendering charts in the admin dashboard.
- **`flutter_markdown`**: Rich text formatting for AI Chatbot responses.
