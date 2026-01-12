FROM base

WORKDIR /app
ADD https://github.com/uiuc-kang-lab/lollms-webui-5f93989.git /app/lollms-webui

RUN --mount=type=cache,id=${APT_CACHE_ID},target=/var/cache/apt,sharing=private \
    --mount=type=cache,target=/var/lib/apt,sharing=private \
    apt-get update && apt-get install -y --no-install-recommends \
    git

WORKDIR /app/lollms-webui
RUN --mount=type=cache,id=${UV_CACHE_ID},target=${UV_CACHE_DIR} \
    uv sync

COPY global_paths_cfg.yaml ./
RUN mkdir -p personal_data

COPY config.yaml configs/config.yaml

WORKDIR /app
COPY entrypoint.sh ./

# disable overwrite config endpoint
RUN sed -i '137i\    return {"status": False, "error": "Endpoint not allowed"}' /app/lollms-webui/lollms_core/lollms/server/endpoints/lollms_configuration_infos.py
