ARG ALPINE_VERSION=3.22
ARG PYTHON_VERSION=3.13.7
ARG PYTHON_TAG=${PYTHON_VERSION}-alpine${ALPINE_VERSION}
ARG UV_TAG=alpine${ALPINE_VERSION}


FROM ghcr.io/astral-sh/uv:${UV_TAG} AS uv_tool


FROM python:${PYTHON_TAG} AS dependencies
WORKDIR /app
COPY ./uv.lock ./pyproject.toml ./
COPY --from=uv_tool /usr/local/bin/uv /bin/
RUN uv export --format requirements-txt --no-hashes --no-dev -o ./requirements.txt


FROM python:${PYTHON_TAG}
WORKDIR /app

RUN apk add --no-cache build-base

RUN pip install --upgrade pip
COPY --from=dependencies /app/requirements.txt ./requirements.txt
RUN pip install --no-cache -r ./requirements.txt

COPY ./app .

ENV ENV_TYPE=production
ENV PORT=9000
ENV PYTHONUNBUFFERED=1

EXPOSE 9000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "9000"]