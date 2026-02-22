FROM python:3.12-slim-bookworm AS builder

ENV PYTHONDONTWRITEBYTECODE=1

ENV PYTHONUNBUFFERED=1

WORKDIR /usr/src/app

COPY requirements.txt ./

#  RUN apk add postgresql-dev

RUN apt-get update && apt-get install -y \
    libpq-dev  python3-dev \
    gcc  build-essential \
    && apt-get clean

RUN pip install --upgrade pip

RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.12-slim-bookworm

RUN useradd -m -r appuser && \
   mkdir /usr/src/app && \
   chown -R appuser /usr/src/app

RUN pip install --upgrade setuptools

COPY --from=builder /usr/local/lib/python3.12/site-packages/ /usr/local/lib/python3.12/site-packages/
COPY --from=builder /usr/local/bin/ /usr/local/bin/

WORKDIR /usr/src/app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY --chown=appuser:appuser . .

USER appuser

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "greatkart.wsgi.application"]
