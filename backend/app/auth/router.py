import asyncpg
from fastapi import APIRouter, Depends, HTTPException, status

from app.auth import repository
from app.auth.apple_verifier import verify_apple_identity_token
from app.auth.google_verifier import verify_google_id_token
from app.auth.schemas import (
    AppleSignInRequest,
    GoogleSignInRequest,
    LogoutRequest,
    RefreshRequest,
    TokenPair,
    UpdateMeRequest,
    UserOut,
)
from app.core.db import authenticated_conn, get_conn
from app.core.security import (
    create_access_token,
    current_user_id,
    generate_refresh_token,
    hash_token,
    refresh_token_expiry,
)

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


def _user_out(user: repository.UserRow) -> UserOut:
    return UserOut(
        id=user.id,
        email=user.email,
        display_name=user.display_name,
        avatar_url=user.avatar_url,
    )


async def _issue_token_pair(
    conn: asyncpg.Connection, user: repository.UserRow
) -> TokenPair:
    access_token = create_access_token(user.id)
    refresh_token = generate_refresh_token()
    await repository.store_refresh_token(
        conn,
        user_id=user.id,
        token_hash=hash_token(refresh_token),
        expires_at=refresh_token_expiry(),
    )
    return TokenPair(
        access_token=access_token,
        refresh_token=refresh_token,
        user=_user_out(user),
    )


@router.post("/google", response_model=TokenPair)
async def sign_in_with_google(
    body: GoogleSignInRequest, conn: asyncpg.Connection = Depends(get_conn)
) -> TokenPair:
    info = await verify_google_id_token(body.id_token)
    user = await repository.get_or_create_by_google_sub(
        conn, sub=info.sub, email=info.email, name=info.name, picture=info.picture
    )
    return await _issue_token_pair(conn, user)


@router.post("/apple", response_model=TokenPair)
async def sign_in_with_apple(
    body: AppleSignInRequest, conn: asyncpg.Connection = Depends(get_conn)
) -> TokenPair:
    info = await verify_apple_identity_token(body.identity_token)
    user = await repository.get_or_create_by_apple_sub(
        conn, sub=info.sub, email=info.email, full_name=body.full_name
    )
    return await _issue_token_pair(conn, user)


@router.post("/refresh", response_model=TokenPair)
async def refresh_tokens(
    body: RefreshRequest, conn: asyncpg.Connection = Depends(get_conn)
) -> TokenPair:
    token_hash = hash_token(body.refresh_token)
    record = await repository.get_valid_refresh_token(conn, token_hash)
    if record is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token inválido, expirado ou revogado",
        )

    # Rotation: the old refresh token is single-use.
    await repository.revoke_refresh_token(conn, token_hash)

    user = await repository.get_by_id(conn, str(record["user_id"]))
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Usuário não encontrado"
        )
    return await _issue_token_pair(conn, user)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    body: LogoutRequest, conn: asyncpg.Connection = Depends(get_conn)
) -> None:
    await repository.revoke_refresh_token(conn, hash_token(body.refresh_token))


@router.get("/me", response_model=UserOut)
async def get_me(
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> UserOut:
    user = await repository.get_by_id(conn, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Usuário não encontrado"
        )
    return _user_out(user)


@router.patch("/me", response_model=UserOut)
async def update_me(
    body: UpdateMeRequest,
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> UserOut:
    user = await repository.update_display_name(conn, user_id, body.display_name)
    return _user_out(user)


@router.delete("/account", status_code=status.HTTP_204_NO_CONTENT)
async def delete_account(
    user_id: str = Depends(current_user_id),
    conn: asyncpg.Connection = Depends(authenticated_conn),
) -> None:
    await repository.delete_account(conn, user_id)
