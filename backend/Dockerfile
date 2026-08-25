FROM python:3.12-slim AS builder

WORKDIR /app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.12-slim

RUN useradd --create-home --shell /usr/sbin/nologin appuser

WORKDIR /app
COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY --chown=appuser:appuser app app
COPY --chown=appuser:appuser migrations migrations
COPY --chown=appuser:appuser tool tool

USER appuser

EXPOSE 8000

CMD ["sh", "-c", "python tool/migrate.py && uvicorn app.main:app --host 0.0.0.0 --port 8000"]
