# Task Manager with Drag and Drop

A full-stack task management app built with **Flutter** (frontend) and **FastAPI + SQLite** (backend).

---

## Track & Stretch Goal

- **Track A** — Full-Stack Builder (Flutter + Python backend)
- **Stretch Goal** — Persistent Drag-and-Drop reordering

---

## Project Structure

```
flutter_app/                         ← root folder
│
├── pubspec.yaml                     ← Flutter dependencies
│
├── backend/                         ← Python FastAPI backend
│   ├── requirements.txt
│   └── app/
│       ├── main.py                  
│       ├── __init__.py
│       ├── api/
│       │   └── routes/
│       │       └── tasks.py         
│       ├── db/
│       │   └── database.py          
│       ├── models/
│       │   └── task.py              
│       ├── repositories/
│       │   └── task_repo.py         
│       ├── schemas/
│       │   └── task.py              
│       └── services/
│           └── task_service.py      
│
├── lib/                             ← Flutter frontend
│   ├── main.dart                    
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart      
│   │   │   └── api_constants.dart   
│   │   ├── router/
│   │   │   └── app_router.dart      
│   │   └── theme/
│   │       └── app_theme.dart       
│   └── features/
│       └── tasks/
│           ├── data/
│           │   ├── datasources/
│           │   │   ├── draft_cache_service.dart        
│           │   │   └── task_remote_datasource.dart     
│           │   ├── models/
│           │   │   └── task_model.dart                 
│           │   └── repositories/
│           │       └── task_repository.dart            
│           ├── domain/
│           │   └── entities/
│           │       └── task.dart                       
│           └── presentation/
│               ├── providers/
│               │   └── task_providers.dart             
│               ├── screens/
│               │   ├── task_list_screen.dart           
│               │   └── task_form_screen.dart           
│               └── widgets/
│                   └── task_card.dart                  
│
├── android/                         ← auto-generated
├── ios/                             ← auto-generated
└── test/                            ← auto-generated
```

---

## Setup Instructions

### 1. Backend

**Requirements:** Python 3.10+

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env            # Uses SQLite by default
uvicorn app.main:app --reload
```

The API will be running at `http://localhost:8000`.  
Interactive API docs available at `http://localhost:8000/docs`.

**Using PostgreSQL instead of SQLite:**
1. Install PostgreSQL and create a database.
2. Uncomment `psycopg2-binary` in `requirements.txt` and install it.
3. Update `.env`: `DATABASE_URL=postgresql://user:password@localhost:5432/flodo_db`

---

### 2. Flutter App

**Requirements:** Flutter 3.19+ / Dart 3.3+

```bash
cd flutter_app
flutter pub get
flutter run
```

**Important — Base URL config:**

Edit `lib/core/api/api_constants.dart`:

| Platform              | URL                          |
|-----------------------|------------------------------|
| Android emulator      | `http://10.0.2.2:8000/api`   |
| iOS simulator / web   | `http://localhost:8000/api`  |
| Physical device       | `http://<your-machine-ip>:8000/api` |

---

## API Endpoints

| Method | Endpoint            | Description                    |
|--------|---------------------|--------------------------------|
| GET    | `/api/tasks`        | List tasks (search + filter)   |
| GET    | `/api/tasks/{id}`   | Get single task                |
| POST   | `/api/tasks`        | Create task (2-sec delay)      |
| PUT    | `/api/tasks/{id}`   | Update task (2-sec delay)      |
| DELETE | `/api/tasks/{id}`   | Delete task                    |
| PATCH  | `/api/tasks/reorder`| Persist drag-and-drop order    |

---

## Features

- **CRUD** — Create, Read, Update, Delete tasks
- **Blocked By** — Tasks blocked by an incomplete dependency show as greyed-out and non-tappable
- **Drafts** — New task form state is persisted to `SharedPreferences` on every keystroke and restored on re-open
- **Search** — Filter tasks by title via query param
- **Status filter** — Toggle filter chips for To-Do / In Progress / Done
- **Drag-and-drop** — Reorder tasks; order persisted to DB via `order_index` column
- **2-second delay** — Simulated on Create and Update; UI shows a spinner and blocks double-tap

---

## Technical Decisions

**`order_index` column for drag-and-drop persistence:**  
Rather than storing order client-side, each task has an `order_index` integer in the DB. On reorder, Flutter sends a `PATCH /tasks/reorder` with the full ordered list of IDs, and the backend updates all indices in a single transaction. This means order survives app restarts and is consistent across devices.

**Riverpod `AsyncNotifier` for save state:**  
Using `AsyncNotifier` for create/update cleanly separates loading, error, and success states. The Save button observes `saveTaskProvider.isLoading` — if loading, the spinner renders and `onPressed` is `null`, making double-tap impossible by design.

**Draft cache scoped to new-task only:**  
Drafts only apply to the creation screen, not edits. Editing always starts from the saved task data. This avoids confusing UX where an edit screen could restore stale draft text.

---

## AI Usage Report

This project was built with the assistance of Claude (Anthropic).

**Most helpful prompts:**
- "Generate a FastAPI backend with SQLAlchemy for a task manager with a self-referential blocked_by relationship"
- "Write a Riverpod AsyncNotifier that handles create and update with a shared loading state and blocks double submit"
- "How do I implement persistent drag-and-drop reordering in Flutter's ReorderableListView and sync the new order to a REST API?"

**Example of AI giving wrong code:**  
Claude initially placed `asyncio.sleep(2)` in the FastAPI route handler rather than in the service layer. This technically worked but mixed concerns. The fix was moving it to `task_service.py` so it's isolated to business logic and easy to remove for production.
