# CENRO Certificate of Inspection – Django REST Backend

This folder contains the backend API for the hybrid (offline/online) Certificate of Inspection mobile app.

## Features

- Token-based authentication (`/api/auth/login/`)
- Certificates API (`/api/certificates/`) used by the Flutter app
- SQLite database by default

## Quick start

```bash
cd backend

python -m venv venv
venv\Scripts\activate  # on Windows

pip install -r requirements.txt

python manage.py migrate
python manage.py createsuperuser  # create an admin user for login

python manage.py runserver 0.0.0.0:8000
```

The Flutter app should use a base URL similar to:

- Android emulator: `http://10.0.2.2:8000`
- Physical device (same Wi‑Fi): `http://<your-PC-LAN-IP>:8000`

### API endpoints

- `POST /api/auth/login/`
  - body: `username`, `password`
  - returns: `{ "token": "<auth token>" }`

- `GET /api/certificates/` – list certificates (authenticated)
- `POST /api/certificates/` – create certificate (used by mobile app sync)

When inspectors use the mobile app and tap **Send to admin**, the app POSTs pending certificates here. Admin sees them in **Admin dashboard** at `/admin/dashboard/` and in **Certificates** at `/admin/certificates/certificate/`.

## Admin Portal (custom UI, not Django Admin)

- URL: `/panel/`
- Requires: staff user login (same credentials as Django Admin)

Pages:
- `/panel/` – dashboard
- `/panel/certificates/` – list + search + filter
- `/panel/certificates/<id>/` – details

