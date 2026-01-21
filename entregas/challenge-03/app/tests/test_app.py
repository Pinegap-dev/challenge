import os

from app import app


def test_default_name(monkeypatch):
    monkeypatch.delenv("NAME", raising=False)
    client = app.test_client()

    response = client.get("/")
    assert response.status_code == 200
    assert response.get_data(as_text=True) == "Hello, World!"


def test_custom_name(monkeypatch):
    monkeypatch.setenv("NAME", "FlaskUser")
    client = app.test_client()

    response = client.get("/")
    assert response.status_code == 200
    assert response.get_data(as_text=True) == "Hello, FlaskUser!"
