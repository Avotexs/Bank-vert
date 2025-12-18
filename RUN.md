# How to Run Bank Verte

## 1. Backend & Database
The backend and database are running via Docker.

**Status**:
- Database: Running (Port 5432)
- Backend: Running (Port 8080)
- PgAdmin: Running (Port 5050)

To restart/check logs:
```bash
docker-compose logs -f
```

## 2. Frontend (Flutter)
**Note**: You need to enable **Developer Mode** in Windows Settings to run Flutter with plugins (due to symlinks).

1.  Open **start ms-settings:developers**
2.  Turn on **Developer Mode**.
3.  Run the app:
    ```bash
    cd frontend
    flutter run -d chrome
    # OR
    flutter run -d windows
    ```
