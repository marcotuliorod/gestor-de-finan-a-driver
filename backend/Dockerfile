FROM python:3.12-slim AS builder

WORKDIR /app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.12-slim

WORKDIR /app
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY app app
COPY migrations migrations
COPY tool tool

EXPOSE 8000

CMD ["sh", "-c", "python tool/migrate.py && uvicorn app.main:app --host 0.0.0.0 --port 8000"]
