FROM python:3.12-slim

LABEL maintainer="Bilal Fayyaz"
LABEL purpose="hardened-container-runtime"

RUN groupadd --gid 10001 appuser \
    && useradd --uid 10001 --gid 10001 --create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

COPY app/server.py /app/server.py

RUN chown -R appuser:appuser /app

USER 10001:10001

EXPOSE 8080

CMD ["python", "/app/server.py"]
