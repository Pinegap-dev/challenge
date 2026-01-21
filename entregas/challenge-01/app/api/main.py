import os
import secrets
from typing import Dict

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials

app = FastAPI()
security = HTTPBasic()


def load_admin_credentials() -> Dict[str, bytes]:
    """Read admin credentials from env and fail fast if missing."""
    user = os.getenv("ADMIN_USER")
    password = os.getenv("ADMIN_PASS")
    if not user or not password:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="ADMIN_USER/ADMIN_PASS not configured",
        )
    return {"username": user.encode("utf-8"), "password": password.encode("utf-8")}


def get_current_username(credentials: HTTPBasicCredentials = Depends(security)):
    current_username_bytes = credentials.username.encode("utf-8")
    current_password_bytes = credentials.password.encode("utf-8")

    admin_credentials = load_admin_credentials()

    is_correct_username = secrets.compare_digest(
        current_username_bytes, admin_credentials["username"]
    )
    is_correct_password = secrets.compare_digest(
        current_password_bytes, admin_credentials["password"]
    )

    if not (is_correct_username and is_correct_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username


@app.get("/")
def main_route(username: str = Depends(get_current_username)):
    return {"message": "Welcome to Vars!", "username": username}
