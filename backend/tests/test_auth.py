from unittest.mock import AsyncMock, patch

from app.auth.apple_verifier import AppleUserInfo
from app.auth.google_verifier import GoogleUserInfo


def _mock_google(sub="google-sub-1", email="driver@example.com"):
    return patch(
        "app.auth.router.verify_google_id_token",
        new=AsyncMock(
            return_value=GoogleUserInfo(
                sub=sub, email=email, name="Driver Test", picture=None
            )
        ),
    )


def _mock_apple(sub="apple-sub-1", email="driver@example.com"):
    return patch(
        "app.auth.router.verify_apple_identity_token",
        new=AsyncMock(return_value=AppleUserInfo(sub=sub, email=email)),
    )


async def test_google_sign_in_creates_user(client):
    with _mock_google():
        response = await client.post(
            "/api/v1/auth/google", json={"id_token": "fake"}
        )
    assert response.status_code == 200
    body = response.json()
    assert body["user"]["email"] == "driver@example.com"
    assert body["access_token"]
    assert body["refresh_token"]


async def test_google_sign_in_twice_returns_same_user(client):
    with _mock_google():
        first = await client.post("/api/v1/auth/google", json={"id_token": "fake"})
        second = await client.post("/api/v1/auth/google", json={"id_token": "fake"})
    assert first.json()["user"]["id"] == second.json()["user"]["id"]


async def test_apple_sign_in_creates_user(client):
    with _mock_apple():
        response = await client.post(
            "/api/v1/auth/apple", json={"identity_token": "fake"}
        )
    assert response.status_code == 200
    assert response.json()["user"]["email"] == "driver@example.com"


async def test_me_requires_bearer_token(client):
    response = await client.get("/api/v1/auth/me")
    assert response.status_code == 401


async def test_me_returns_current_user(client):
    with _mock_google():
        signed_in = await client.post(
            "/api/v1/auth/google", json={"id_token": "fake"}
        )
    access_token = signed_in.json()["access_token"]

    response = await client.get(
        "/api/v1/auth/me", headers={"Authorization": f"Bearer {access_token}"}
    )
    assert response.status_code == 200
    assert response.json()["email"] == "driver@example.com"


async def test_update_display_name(client):
    with _mock_google():
        signed_in = await client.post(
            "/api/v1/auth/google", json={"id_token": "fake"}
        )
    access_token = signed_in.json()["access_token"]

    response = await client.patch(
        "/api/v1/auth/me",
        json={"display_name": "Novo Nome"},
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert response.status_code == 200
    assert response.json()["display_name"] == "Novo Nome"


async def test_refresh_token_rotation(client):
    with _mock_google():
        signed_in = await client.post(
            "/api/v1/auth/google", json={"id_token": "fake"}
        )
    old_refresh = signed_in.json()["refresh_token"]

    refreshed = await client.post(
        "/api/v1/auth/refresh", json={"refresh_token": old_refresh}
    )
    assert refreshed.status_code == 200
    assert refreshed.json()["refresh_token"] != old_refresh

    # Old refresh token is single-use — reusing it must fail.
    reused = await client.post(
        "/api/v1/auth/refresh", json={"refresh_token": old_refresh}
    )
    assert reused.status_code == 401


async def test_logout_revokes_refresh_token(client):
    with _mock_google():
        signed_in = await client.post(
            "/api/v1/auth/google", json={"id_token": "fake"}
        )
    refresh_token = signed_in.json()["refresh_token"]

    logout_response = await client.post(
        "/api/v1/auth/logout", json={"refresh_token": refresh_token}
    )
    assert logout_response.status_code == 204

    refreshed = await client.post(
        "/api/v1/auth/refresh", json={"refresh_token": refresh_token}
    )
    assert refreshed.status_code == 401


async def test_delete_account(client):
    with _mock_google():
        signed_in = await client.post(
            "/api/v1/auth/google", json={"id_token": "fake"}
        )
    access_token = signed_in.json()["access_token"]

    delete_response = await client.delete(
        "/api/v1/auth/account",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert delete_response.status_code == 204

    me_response = await client.get(
        "/api/v1/auth/me", headers={"Authorization": f"Bearer {access_token}"}
    )
    assert me_response.status_code == 404
