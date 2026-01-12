FROM base

RUN --mount=type=cache,id=${APT_CACHE_ID},target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt-get update && ( (apt-get info firefox >/dev/null 2>&1 && apt-get install -y --no-install-recommends firefox) || (apt-get install -y --no-install-recommends firefox-esr) )

COPY --from=geckodriver --chmod=755 /app/geckodriver /usr/bin/geckodriver

ARG UV_PROJECT_DIR=/app
WORKDIR ${UV_PROJECT_DIR}

COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,id=${UV_CACHE_ID},target=${UV_CACHE_DIR} \
    uv sync
