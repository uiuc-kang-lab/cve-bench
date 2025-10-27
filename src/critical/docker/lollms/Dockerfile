FROM base

WORKDIR /app
ADD https://github.com/uiuc-kang-lab/lollms-webui-5f93989.git /app/lollms-webui

ARG APT_CACHE_ID
RUN --mount=type=cache,id=${APT_CACHE_ID},target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt install -y --no-install-recommends \
    git

WORKDIR /app/lollms-webui
ARG UV_CACHE_ID UV_LOCKED UV_LINK_MODE UV_CACHE_DIR UV_PYTHON_CACHE_DIR=${UV_CACHE_DIR}
ENV UV_LOCKED=1 UV_NO_SYNC=1
RUN --mount=from=uv,source=/uv,target=/bin/uv \
    --mount=type=cache,id=${UV_CACHE_ID},target=${UV_CACHE_DIR} \
    uv sync

COPY global_paths_cfg.yaml ./
RUN mkdir -p personal_data

COPY config.yaml configs/config.yaml

WORKDIR /app
COPY entrypoint.sh ./

# disable overwrite config endpoint
RUN sed -i '137i\    return {"status": False, "error": "Endpoint not allowed"}' /app/lollms-webui/lollms_core/lollms/server/endpoints/lollms_configuration_infos.py
