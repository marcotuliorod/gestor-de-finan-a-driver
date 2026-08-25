import uuid

import pytest

from tests.conftest import sign_in


def _uuid() -> str:
    return str(uuid.uuid4())


async def test_vehicle_upsert_create_and_update(authed_client):
    vehicle_id = _uuid()
    payload = {
        "make": "Chevrolet",
        "model": "Onix",
        "year": 2022,
        "license_plate": "ABC1D23",
        "fuel_type": "flex",
        "tank_capacity_l": 44.0,
        "purchase_price_cents": 8000000,
        "current_odometer": 15000,
    }
    create = await authed_client.put(f"/api/v1/vehicles/{vehicle_id}", json=payload)
    assert create.status_code == 204

    payload["current_odometer"] = 15500
    update = await authed_client.put(f"/api/v1/vehicles/{vehicle_id}", json=payload)
    assert update.status_code == 204


async def _create_vehicle(authed_client) -> str:
    vehicle_id = _uuid()
    response = await authed_client.put(
        f"/api/v1/vehicles/{vehicle_id}",
        json={
            "make": "Chevrolet",
            "model": "Onix",
            "year": 2022,
            "license_plate": "ABC1D23",
            "fuel_type": "flex",
            "tank_capacity_l": 44.0,
            "purchase_price_cents": 8000000,
        },
    )
    assert response.status_code == 204
    return vehicle_id


async def _create_platform(authed_client) -> str:
    platform_id = _uuid()
    response = await authed_client.put(
        f"/api/v1/platforms/{platform_id}", json={"type": "uber"}
    )
    assert response.status_code == 204
    return platform_id


async def test_platform_upsert(authed_client):
    platform_id = await _create_platform(authed_client)
    response = await authed_client.put(
        f"/api/v1/platforms/{platform_id}",
        json={"type": "uber", "is_active": False},
    )
    assert response.status_code == 204


async def test_trip_upsert_and_delete(authed_client):
    platform_id = await _create_platform(authed_client)
    trip_id = _uuid()

    create = await authed_client.put(
        f"/api/v1/trips/{trip_id}",
        json={
            "platform_id": platform_id,
            "gross_amount_cents": 5000,
            "trip_date": "2026-08-01",
        },
    )
    assert create.status_code == 204

    update = await authed_client.put(
        f"/api/v1/trips/{trip_id}",
        json={
            "platform_id": platform_id,
            "gross_amount_cents": 5500,
            "duration_minutes": 25,
            "trip_date": "2026-08-01",
        },
    )
    assert update.status_code == 204

    delete = await authed_client.delete(f"/api/v1/trips/{trip_id}")
    assert delete.status_code == 204

    delete_again = await authed_client.delete(f"/api/v1/trips/{trip_id}")
    assert delete_again.status_code == 204  # already soft-deleted, still same row


async def test_expense_upsert_and_delete(authed_client):
    expense_id = _uuid()
    create = await authed_client.put(
        f"/api/v1/expenses/{expense_id}",
        json={
            "category": "toll",
            "amount_cents": 1200,
            "expense_date": "2026-08-01",
        },
    )
    assert create.status_code == 204

    delete = await authed_client.delete(f"/api/v1/expenses/{expense_id}")
    assert delete.status_code == 204


async def test_fuel_record_upsert_writes_expense_and_fuel_record(authed_client):
    vehicle_id = await _create_vehicle(authed_client)
    expense_id = _uuid()
    fuel_id = _uuid()

    response = await authed_client.put(
        f"/api/v1/fuel-records/{fuel_id}",
        json={
            "expense_id": expense_id,
            "vehicle_id": vehicle_id,
            "amount_cents": 25000,
            "expense_date": "2026-08-01",
            "liters": 40.5,
            "odometer": 15200,
            "fuel_type": "ethanol",
        },
    )
    assert response.status_code == 204

    # Updating with the same fuel_id/expense_id should upsert cleanly.
    response = await authed_client.put(
        f"/api/v1/fuel-records/{fuel_id}",
        json={
            "expense_id": expense_id,
            "vehicle_id": vehicle_id,
            "amount_cents": 26000,
            "expense_date": "2026-08-01",
            "liters": 41.0,
            "odometer": 15220,
            "fuel_type": "ethanol",
        },
    )
    assert response.status_code == 204


async def test_mileage_record_upsert(authed_client):
    vehicle_id = await _create_vehicle(authed_client)
    record_id = _uuid()
    response = await authed_client.put(
        f"/api/v1/mileage-records/{record_id}",
        json={
            "vehicle_id": vehicle_id,
            "start_odometer": 1000,
            "end_odometer": 1100,
            "work_km": 80,
            "personal_km": 20,
            "record_date": "2026-08-01",
        },
    )
    assert response.status_code == 204


async def test_mileage_record_rejects_inconsistent_km_sum(authed_client):
    vehicle_id = await _create_vehicle(authed_client)
    record_id = _uuid()
    response = await authed_client.put(
        f"/api/v1/mileage-records/{record_id}",
        json={
            "vehicle_id": vehicle_id,
            "start_odometer": 1000,
            "end_odometer": 1100,
            "work_km": 999,
            "personal_km": 999,
            "record_date": "2026-08-01",
        },
    )
    # chk_km_sum CHECK constraint violation -> mapped to 400 by the global
    # asyncpg.PostgresError handler.
    assert response.status_code == 400


async def test_maintenance_record_upsert_and_delete(authed_client):
    vehicle_id = await _create_vehicle(authed_client)
    record_id = _uuid()
    create = await authed_client.put(
        f"/api/v1/maintenance-records/{record_id}",
        json={
            "vehicle_id": vehicle_id,
            "type": "oil_change",
            "cost_cents": 15000,
            "odometer": 15000,
            "maintenance_date": "2026-08-01",
        },
    )
    assert create.status_code == 204

    delete = await authed_client.delete(f"/api/v1/maintenance-records/{record_id}")
    assert delete.status_code == 204


async def test_goal_upsert(authed_client):
    goal_id = _uuid()
    response = await authed_client.put(
        f"/api/v1/goals/{goal_id}",
        json={
            "monthly_target_cents": 500000,
            "period_start": "2026-08-01",
            "period_end": "2026-08-31",
        },
    )
    assert response.status_code == 204


async def test_rls_blocks_cross_user_delete(client):
    owner = await sign_in(client, sub="owner-sub", email="owner@example.com")
    client.headers["Authorization"] = f"Bearer {owner['access_token']}"
    expense_id = _uuid()
    create = await client.put(
        f"/api/v1/expenses/{expense_id}",
        json={
            "category": "toll",
            "amount_cents": 1200,
            "expense_date": "2026-08-01",
        },
    )
    assert create.status_code == 204

    other = await sign_in(client, sub="intruder-sub", email="intruder@example.com")
    client.headers["Authorization"] = f"Bearer {other['access_token']}"

    # RLS scopes the UPDATE to the intruder's own rows — the owner's
    # expense is invisible, so the delete affects 0 rows and 404s instead
    # of silently deleting (or leaking) another user's data.
    delete = await client.delete(f"/api/v1/expenses/{expense_id}")
    assert delete.status_code == 404
