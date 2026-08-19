# AI Chatbot App CYberpunk (Full Stack) ready to run

This project contains a Flutter frontend and a FastAPI backend for a simple chatbot application.

## Project Structure
- `backend/`: Python FastAPI code for the chat proxy.
- `lib/`: Flutter frontend code (organized by clean architecture).
- `pubspec.yaml`: Flutter dependencies.

## How to Setup and Run

### 1. Backend (Python)
- Navigate to the `backend/` directory.
- Install requirements: `pip install -r requirements.txt`
- Run the server: `python main.py` or `uvicorn main:app --reload`
- The backend will run on `http://127.0.0.1:8000`.

### 2. Frontend (Flutter)
- Ensure you have Flutter installed.
- Run `flutter pub get` to fetch dependencies.
- Launch an Android Emulator or connect a device.
- Run the app: `flutter run`
- **Note:** The app is configured to connect to `10.0.2.2:8000` (which refers to `localhost` on the host machine from the Android emulator).

## Features
- **Chat Screen:** Clean UI for sending messages and viewing bot replies.
- **API Settings:** Screen to securely enter your API Key and select your preferred model.
- **Support for Multiple Providers:** 
  - **Persistence:** API Key and Model choice are saved locally using `shared_preferences`.
- **CORS Support:** Backend allows requests from any origin, making it easy to test.

## Requirements
- Flutter SDK
- Python 3.9+
- API Key from: