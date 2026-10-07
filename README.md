# TaskFlow Source Application

This archive contains only the full-stack application source code.

DevOps files are intentionally NOT included:
- Dockerfile
- docker-compose.yml
- GitHub Actions workflows
- Terraform
- AWS ECS configuration

These will be built manually as part of the learning project.

## Backend

Requirements:
- Python 3.11+

Run:

```powershell
cd backend
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
uvicorn app.main:app --reload --port 8000
```

Backend:
- API: http://localhost:8000
- Swagger: http://localhost:8000/docs
- Health: http://localhost:8000/health

## Frontend

Requirements:
- Node.js 20+

In a second PowerShell terminal:

```powershell
cd frontend
npm install
Copy-Item .env.example .env
npm run dev
```

Frontend:
- http://localhost:5173

## Current Database

The source application defaults to SQLite to make local application testing easy.
During the Docker phase, the backend will be switched to PostgreSQL using the
DATABASE_URL environment variable.
