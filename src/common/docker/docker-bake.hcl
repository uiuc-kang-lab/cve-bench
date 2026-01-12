variable "CVEBENCH_COMPRESSION" {
  type = string
  required = true
  default = "uncompressed"
}

variable "CVEBENCH_ORGANIZATION" {
  type = string
  required = true
  default = "cvebench"
}

variable "CVEBENCH_TAG" {
  type = string
  required = true
}

variable "CVEBENCH_UBUNTU_IMAGE" {
  type = string
  required = true
  default = "ubuntu:22.04"
}

variable "CVEBENCH_PHP7_APACHE_IMAGE" {
  type = string
  required = true
  default = "php:7.4-apache"
}

variable "CVEBENCH_PHP7_FPM_IMAGE" {
  type = string
  required = true
  default = "php:7.4-fpm"
}

variable "CVEBENCH_PHP8_APACHE_IMAGE" {
  type = string
  required = true
  default = "php:8.3-apache"
}

variable "CVEBENCH_UV_IMAGE" {
  type = string
  required = true
  default = "ghcr.io/astral-sh/uv:0.9"
}

variable "CVEBENCH_WORDPRESS_IMAGE" {
  type = string
  required = true
  # changing wordpress minor version may trigger database updates, so pin it
  default = "wordpress:6.8-php8.3-apache"
}

variable "CVEBENCH_RUST_IMAGE" {
  type = string
  required = true
  default = "rust:1.92-slim"
}

variable "CVEBENCH_RUBY_IMAGE" {
  type = string
  required = true
  default = "ruby:3.2-slim"
}

variable "CVEBENCH_RUBY_BUILDER_IMAGE" {
  type = string
  required = true
  default = "ruby:3.2"
}

variable "CVEBENCH_KALI_IMAGE" {
  type = string
  required = true
  default = "kalilinux/kali-last-release:latest"
}

variable "CVEBENCH_METADATA_DIR" {
  type = string
  required = true
}

variable "CVEBENCH_CHALLENGE_DIR" {
  type = string
  required = true
}

variable "CVEBENCH_VERSION_DOCKER_DIR" {
  type = string
  required = true
}

variable "CVEBENCH_DOCKER_DIR" {
  type = string
  required = true
}

variable "CVEBENCH_EVALUATIONS_DIR" {
  type = string
  required = true
}

variable "CVEBENCH_VERSION_EVALUATIONS_DIR" {
  type = string
  required = true
}

variable "CVEBENCH_SANDBOXES_DIR" {
  type = string
  required = true
}

variable "CVEBENCH_CVES" {
    type = list(object({
        CVE = string
        BASE = string
        APPLICATION_NAME = string
        CONTEXTS = map(string)
    }))
    required = true
}

variable "CVEBENCH_AUXILIARY" {
  type = list(object({
    CVE = string
    BASE = string
    SERVICE = string
  }))
  required = true
  default = []
}

variable "CVEBENCH_CVES_EVALUATOR_UV_EXTRA_ARGS" {
  type = map(string)
  required = true
  default = {}
}

group "default" {
  targets = ["target", "auxiliary", "kali-core"]
}

target "_common" {
  platforms = ["linux/amd64"]
  args = {
    UV_CACHE_ID = "uv-cache"
    APT_CACHE_ID = "apt-cache"

    UV_CACHE_DIR = "/root/.cache/uv"
    UV_PYTHON_INSTALL_DIR = "/root/.local/share/uv/python"
  }
  output = ["type=cacheonly"]
}

target "common" {
  inherits = ["_common"]
  contexts = {
    uv = "docker-image://${CVEBENCH_UV_IMAGE}"
  }
}

target "image" {
  inherits = ["_common"]
  output = ["type=docker,compression=${CVEBENCH_COMPRESSION}"]
}

target "target-base" {
  inherits = ["common"]

  name = item.NAME
  matrix = {
    item = [
        {
            NAME = "ubuntu"
            BASE = "docker-image://${CVEBENCH_UBUNTU_IMAGE}"
        },
        {
            NAME = "wordpress-base"
            BASE = "docker-image://${CVEBENCH_WORDPRESS_IMAGE}"
        },
        {
            NAME = "php7-apache-base"
            BASE = "docker-image://${CVEBENCH_PHP7_APACHE_IMAGE}"
        },
        {
            NAME = "php7-fpm-base"
            BASE = "docker-image://${CVEBENCH_PHP7_FPM_IMAGE}"
        },
        {
            NAME = "php8-apache-base"
            BASE = "docker-image://${CVEBENCH_PHP8_APACHE_IMAGE}"
        },
        {
          NAME = "ruby"
          BASE = "docker-image://${CVEBENCH_RUBY_IMAGE}"
        },
    ]
  }

  dockerfile = "${CVEBENCH_DOCKER_DIR}/Dockerfile.target-base"
  contexts = {
    base = item.BASE
  }
}

target "selenium" {
  inherits = ["common"]

  context = "${CVEBENCH_DOCKER_DIR}/selenium-base"
  contexts = {
    base = "target:ubuntu"
    geckodriver = "target:geckodriver"
  }
}

target "mysql-base" {
  inherits = ["common"]

  name = item.NAME
  matrix = {
    item = [
        {
            NAME = "wordpress"
            BASE = "target:wordpress-base"
        },
        {
            NAME = "mysql"
            BASE = "target:ubuntu"
        },
        {
            NAME = "php7-apache-base-mysql"
            BASE = "target:php7-apache-base"
        },
        {
            NAME = "php7-fpm-base-mysql"
            BASE = "target:php7-fpm-base"
        },
        {
            NAME = "php8-apache-base-mysql"
            BASE = "target:php8-apache-base"
        },
    ]
  }

  dockerfile = "${CVEBENCH_DOCKER_DIR}/mariadb/Dockerfile.client"
  contexts = {
    base = item.BASE
  }
}

target "php" {
  inherits = ["common"]

  name = "php${item}"
  matrix = { item = ["7-apache", "7-fpm", "8-apache"] }

  dockerfile = "${CVEBENCH_DOCKER_DIR}/Dockerfile.php"

  contexts = {
    base = "target:php${item}-base-mysql"
  }
}

target "node" {
  inherits = ["common"]

  name = "node${item}"
  matrix = { item = ["20"] }

  dockerfile = "${CVEBENCH_DOCKER_DIR}/Dockerfile.node"

  contexts = {
    base = "target:ubuntu"
  }

  args = {
    NODE_VERSION = "${item}"
  }
}

target "stalwart-cli" {
    inherits = ["_common"]

    context = "${CVEBENCH_DOCKER_DIR}"
    dockerfile = "Dockerfile.stalwart-cli"
    contexts = {
      base = "target:ubuntu"
    }
}

target "geckodriver" {
    inherits = ["_common"]

    context = "${CVEBENCH_DOCKER_DIR}"
    dockerfile = "Dockerfile.geckodriver"
    contexts = {
      base = "target:ubuntu"
    }
}

target "auxiliary" {
  inherits = ["common", "image"]

  name = "${item.CVE}-${item.SERVICE}"
  matrix = {
    item = CVEBENCH_AUXILIARY
  }

  dockerfile = "Dockerfile.${item.SERVICE}"
  context = "${CVEBENCH_CHALLENGE_DIR}/${item.CVE}/${item.SERVICE}"
  tags = ["${CVEBENCH_ORGANIZATION}/${lower(item.CVE)}-${item.SERVICE}:${CVEBENCH_TAG}"]
  contexts = {
    base = item.BASE
  }
}

function "target-base-context" {
  params = [cve, base]
  result = equal(base, "target:wordpress") ? "${CVEBENCH_DOCKER_DIR}/wordpress" : "${CVEBENCH_CHALLENGE_DIR}/${cve}/target"
}

target "target-app" {
  inherits = ["common"]

  name = "${item.CVE}-target-base"
  matrix = {
    item = CVEBENCH_CVES
  }

  context = target-base-context(item.CVE, item.BASE)
  dockerfile = "Dockerfile.target"

  contexts = merge({
    base = item.BASE
    plugins = "${CVEBENCH_CHALLENGE_DIR}/${item.CVE}/target"
  }, try(item.CONTEXTS, {}))
}

target "target" {
  inherits = ["common", "image"]

  name = "${item.CVE}-target"
  matrix = {
    item = CVEBENCH_CVES
  }

  dockerfile = "Dockerfile.target"
  context = "${CVEBENCH_DOCKER_DIR}"

  tags = ["${CVEBENCH_ORGANIZATION}/${lower(item.CVE)}-target:${CVEBENCH_TAG}"]

  args = {
    APPLICATION_NAME = item.APPLICATION_NAME
    EVALUATOR_EXTRAS = lookup(CVEBENCH_CVES_EVALUATOR_UV_EXTRA_ARGS, item.CVE, "")
  }

  contexts = {
    evaluation = "${CVEBENCH_EVALUATIONS_DIR}"
    version-evaluation = "${CVEBENCH_VERSION_EVALUATIONS_DIR}"
    base = "target:${item.CVE}-target-base"
  }
}

target "kali" {
  inherits = ["common", "image"]
  name = "kali-${item.size}"
  matrix = {
    item = [
        {
            size = "core"
            base = "docker-image://${CVEBENCH_KALI_IMAGE}"
        },
        {
            size = "large"
            base = "target:kali-core"
        },
    ]
  }
  tags = ["${CVEBENCH_ORGANIZATION}/kali-${item.size}:${CVEBENCH_TAG}"]
  dockerfile = "Dockerfile.${item.size}"
  context = "${CVEBENCH_SANDBOXES_DIR}/kali"
  contexts = {
    base = item.base
    geckodriver = "target:geckodriver"
    stalwart-cli = "target:stalwart-cli"
  }
}
