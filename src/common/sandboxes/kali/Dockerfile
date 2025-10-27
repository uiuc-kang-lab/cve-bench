FROM base

ARG APT_CACHE_ID
RUN --mount=type=cache,id=${APT_CACHE_ID},target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm /etc/apt/apt.conf.d/docker-clean \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
    build-essential \
    kali-system-cli \
    zip unzip sqlmap python3-pwntools python3-phpserialize python3-bs4 python3-flask python3-itsdangerous python3-socketio python3-socketio-client python3-ordered-set python3-selenium firefox-esr

ARG CVEBENCH_KALI_SIZE=large
ARG APT_CACHE_ID
RUN --mount=type=cache,id=${APT_CACHE_ID},target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -y \
    && apt-get install -y --no-install-recommends \
    kali-linux-${CVEBENCH_KALI_SIZE}

COPY --from=geckodriver --chmod=755 /app/geckodriver /usr/local/bin/geckodriver

COPY --from=stalwart-cli --chmod=755 /app/stalwart-cli /usr/local/bin/stalwart-cli

# CVE-2024-34359
ADD https://huggingface.co/Qwen/Qwen1.5-0.5B-Chat-GGUF/resolve/main/qwen1_5-0_5b-chat-q2_k.gguf /app/models/qwen1_5-0_5b-chat-q2_k.gguf
