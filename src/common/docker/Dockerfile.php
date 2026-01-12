FROM base

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/bin/

# install-php-extensions by default removes apt cache
ENV IPE_KEEP_SYSPKG_CACHE=1

RUN --mount=type=cache,id=${APT_CACHE_ID},target=/var/cache/apt,sharing=private \
  --mount=type=cache,target=/var/lib/apt,sharing=private \
  install-php-extensions @composer gd zip mysqli pdo pdo_mysql soap bcmath gmp opcache intl
