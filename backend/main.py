from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import httpx
import uvicorn
import google.generativeai as genai

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str
    api_key: str
    model: str
    provider: str = "auto"
    base_url: str = ""

class ModelsRequest(BaseModel):
    api_key: str
    provider: str = "auto"

PROVIDERS = {
    "openai": "https://api.openai.com/v1",
    "groq": "https://api.groq.com/openai/v1",
    "openrouter": "https://openrouter.ai/api/v1",
    "deepseek": "https://api.deepseek.com/v1",
    "mistral": "https://api.mistral.ai/v1",
    "together": "https://api.together.xyz/v1",
    "fireworks": "https://api.fireworks.ai/inference/v1",
    "xai": "https://api.x.ai/v1",
    "perplexity": "https://api.perplexity.ai",
}

def detect_provider(api_key: str) -> str:
    key = api_key.strip()

    if key.startswith("AIza") or key.startswith("AQ."):
        return "gemini"
    if key.startswith("sk-ant-"):
        return "anthropic"
    if key.startswith("gsk_"):
        return "groq"
    if key.startswith("sk-or-"):
        return "openrouter"
    if key.startswith("sk-"):
        return "openai"

    return "openai"

@app.post("/models")
async def get_models(request: ModelsRequest):
    api_key = request.api_key.strip()
    if not api_key:
        raise HTTPException(status_code=400, detail="API Key is required")

    provider = request.provider if request.provider != "auto" else detect_provider(api_key)
    print(f"\n--- Detected Provider: {provider} ---")

    try:
        # ==================== GEMINI ====================
        if provider == "gemini":
            genai.configure(api_key=api_key)
            models = list(genai.list_models())
            gemini_models = []
            for m in models:
                if "generateContent" in m.supported_generation_methods:
                    name = m.name.replace("models/", "")
                    gemini_models.append(name)

            return {
                "provider": "gemini",
                "models": gemini_models,
                "base_url": ""
            }

        # ==================== ANTHROPIC ====================
        if provider == "anthropic":
            models = [
                "claude-3-5-sonnet-20241022",
                "claude-3-5-haiku-20241022",
                "claude-3-opus-20240229",
                "claude-3-sonnet-20240229",
                "claude-3-haiku-20240307",
                "claude-sonnet-4-20250514",
                "claude-opus-4-20250514"
            ]
            return {
                "provider": "anthropic",
                "models": models,
                "base_url": "https://api.anthropic.com/v1"
            }

        # ==================== OPENAI COMPATIBLE ====================
        base_url = PROVIDERS.get(provider, "https://api.openai.com/v1")
        url = f"{base_url}/models"

        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }

        if provider == "openrouter":
            headers["HTTP-Referer"] = "http://localhost"
            headers["X-Title"] = "Chatbot"

        async with httpx.AsyncClient() as client:
            response = await client.get(url, headers=headers, timeout=20.0)

        print(f"Status Code: {response.status_code}")

        if response.status_code != 200:
            raise HTTPException(
                status_code=400,
                detail=f"{provider.upper()} Error: {response.status_code} - {response.text}"
            )

        data = response.json()
        raw_models = data.get("data", [])
        if not raw_models and isinstance(data, list):
            raw_models = data

        models = []
        skip_keywords = [
            "whisper", "tts", "audio", "embed", "embedding",
            "moderation", "guard", "image", "dall-e", "clip",
            "realtime", "transcribe", "speech", "vision"
        ]

        for m in raw_models:
            model_id = None
            if isinstance(m, dict):
                model_id = m.get("id") or m.get("name")
            elif isinstance(m, str):
                model_id = m

            if not model_id:
                continue

            model_lower = model_id.lower()

            # Automatically skip non-chat models
            if any(keyword in model_lower for keyword in skip_keywords):
                continue

            models.append(model_id)

        # Remove duplicates while keeping order
        models = list(dict.fromkeys(models))

        print(f"Chat models found: {len(models)}")
        print(f"First 10 models: {models[:10]}")

        if not models:
            raise HTTPException(status_code=400, detail="No chat models found")

        return {
            "provider": provider,
            "models": models,
            "base_url": base_url
        }

    except HTTPException:
        raise
    except Exception as e:
        print(f"Unexpected Error: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))

@app.post("/chat")
async def chat(request: ChatRequest):
    try:
        provider = request.provider if request.provider != "auto" else detect_provider(request.api_key)
        print(f"Chat using provider: {provider} | model: {request.model}")

        if provider == "gemini":
            return await handle_gemini(request)
        elif provider == "anthropic":
            return await handle_anthropic(request)
        else:
            return await handle_openai_compatible(request, provider)

    except Exception as e:
        print(f"Chat Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

async def handle_gemini(request: ChatRequest):
    try:
        genai.configure(api_key=request.api_key)
        model = genai.GenerativeModel(request.model)
        response = await model.generate_content_async(request.message)
        return {"reply": response.text}
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Gemini Error: {str(e)}")

async def handle_anthropic(request: ChatRequest):
    url = "https://api.anthropic.com/v1/messages"
    headers = {
        "x-api-key": request.api_key,
        "anthropic-version": "2023-06-01",
        "Content-Type": "application/json"
    }
    payload = {
        "model": request.model,
        "max_tokens": 1024,
        "messages": [{"role": "user", "content": request.message}]
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(url, headers=headers, json=payload, timeout=40.0)

    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail=response.text)

    data = response.json()
    return {"reply": data["content"][0]["text"]}

async def handle_openai_compatible(request: ChatRequest, provider: str):
    base_url = request.base_url or PROVIDERS.get(provider, "https://api.openai.com/v1")
    url = f"{base_url}/chat/completions"

    headers = {
        "Authorization": f"Bearer {request.api_key}",
        "Content-Type": "application/json"
    }

    if provider == "openrouter":
        headers["HTTP-Referer"] = "http://localhost:8000"
        headers["X-Title"] = "Flutter Chatbot"

    payload = {
        "model": request.model,
        "messages": [{"role": "user", "content": request.message}]
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(url, headers=headers, json=payload, timeout=40.0)

    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail=response.text)

    data = response.json()
    return {"reply": data["choices"][0]["message"]["content"]}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)