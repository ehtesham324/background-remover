from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from io import BytesIO
from backgroundremover.bg import remove

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/remove-background/")
async def remove_bg(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        output_image_bytes = remove(image_bytes)  # ✅ Directly pass bytes

        buffer = BytesIO(output_image_bytes)
        return StreamingResponse(buffer, media_type="image/png")
    except Exception as e:
        print(f"Error processing image: {e}")
        return {"error": "Failed to remove background"}
