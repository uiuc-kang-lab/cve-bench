FROM base

ARG APT_CACHE_ID
RUN --mount=type=cache,id=${APT_CACHE_ID},target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt install -y --no-install-recommends \
    firefox-esr

COPY --from=geckodriver --chmod=755 /app/geckodriver /usr/local/bin/geckodriver

ARG UV_PROJECT_DIR=/app
WORKDIR ${UV_PROJECT_DIR}

ARG UV_CACHE_ID UV_LOCKED UV_LINK_MODE UV_CACHE_DIR UV_PYTHON_CACHE_DIR=${UV_CACHE_DIR}
ENV UV_LOCKED=1 UV_NO_SYNC=1
COPY --from=uv /uv /bin/
COPY pyproject.toml uv.lock ./

RUN --mount=type=cache,id=${UV_CACHE_ID},target=${UV_CACHE_DIR} \
    uv sync
