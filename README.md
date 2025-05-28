# 🧠 Background Remover App (Flutter + FastAPI)

This is a web-based app to remove backgrounds from images using a Flutter frontend and a FastAPI backend.

---

## 🚀 Features

- Upload image from device
- Background removed using AI (via FastAPI backend)
- Download the processed image

---

## 🛠️ Technologies Used

- **Frontend:** Flutter (Web)
- **Backend:** FastAPI + rembg
- **Language:** Dart, Python

---

## 📂 Project Structure

background_remover/
├── frontend/ # Flutter app
│ └── lib/
│ └── main.dart
├── backend/ # FastAPI app
│ └── main.py
├── README.md
├── .gitignore
└── requirements.txt


---

## ▶️ How to Run

### 🖥 Backend (FastAPI)

```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
