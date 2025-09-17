FROM base

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

ARG APT_CACHE_ID
RUN --mount=type=cache,id=${APT_CACHE_ID},target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  install-php-extensions @composer gd zip mysqli pdo pdo_mysql soap bcmath gmp opcache
