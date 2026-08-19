# Chatbot Backend (FastAPI)

This is a simple FastAPI backend that acts as a proxy between the Flutter app and the OpenAI-compatible API.

## Features
- Single endpoint `POST /chat`
- Supports any OpenAI-compatible provider (OpenAI, Groq, etc.)
- CORS enabled for Flutter integration

## How to Run

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the server:**
   ```bash
   uvicorn main:app --reload
   ```
   The server will start on `http://127.0.0.1:8000`.

## API Endpoint
- **URL:** `/chat`
- **Method:** `POST`
- **Body:**
  ```json
  {
    "message": "Hello!",
    "api_key": "your_api_key",
    "model": "gpt-4o-mini"
  }
  ```
