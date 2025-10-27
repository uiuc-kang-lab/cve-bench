variable "organization" {
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
  default = "ubuntu:22.04@sha256:ed1544e454989078f5dec1bfdabd8c5cc9c48e0705d07b678ab6ae3fb61952d2"
}

variable "CVEBENCH_PYTHON_IMAGE" {
  type = string
  required = true
  default = "ghcr.io/astral-sh/uv:bookworm-slim"
}

variable "CVEBENCH_UV_IMAGE" {
  type = string
  required = true
  default = "ghcr.io/astral-sh/uv:0.8"
}

variable "CVEBENCH_WORDPRESS_IMAGE" {
  type = string
  required = true
  default = "wordpress:6.6.1-php8.3-apache@sha256:7807997102f57c8a7d8e6e49204cfecc557785140a9e1c6c7f730b42141a8347"
}

variable "CVEBENCH_KALI_IMAGE" {
  type = string
  required = true
  default = "kalilinux/kali-last-release:latest@sha256:e0044dd12d63778c784219cdd721980f5c1488d3db433dbfb248ff7304055b98"
}

variable "CVEBENCH_BUILDER_IMAGE" {
  type = string
  required = true
  default = "buildpack-deps:plucky@sha256:a58f7fd6f906557f75b57515a288bf9b0b004c619762b0db6d86dcfe38fa52c9"
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

variable "CVEBENCH_SANDBOXES_DIR" {
  type = string
  required = true
}

variable "CVEBENCH_CVES" {
    type = list(object({
        CVE = string
        BASE = string
        APPLICATION_NAME = string
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

variable "CVEBENCH_CVES_EVALUATOR_UV_HOME" {
  type = list(string)
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
    # ARG
    UV_CACHE_ID = "uv-cache"
    APT_CACHE_ID = "apt-cache"

    # ENV
    UV_LINK_MODE = "copy"
    UV_CACHE_DIR = "/root/.cache/uv"
  }
  output = [{ type = "cacheonly" }]
}

target "common" {
  inherits = ["_common"]
  contexts = {
    uv = "docker-image://${CVEBENCH_UV_IMAGE}"
    builder = "docker-image://${CVEBENCH_BUILDER_IMAGE}"
    stalwart-cli = "target:stalwart-cli"
    geckodriver = "target:geckodriver"
  }
}

target "image" {
  inherits = ["_common"]
  output = [{ type = "docker" }]
}

target "selenium" {
  inherits = ["common"]

  context = "${CVEBENCH_DOCKER_DIR}/selenium-base"
  contexts = {
    base = "target:python"
  }
}

target "mysql-base" {
  inherits = ["common"]

  name = item.NAME
  matrix = {
    item = [
        {
            NAME = "wordpress"
            BASE = "docker-image://${CVEBENCH_WORDPRESS_IMAGE}"
        },
        {
            NAME = "ubuntu"
            BASE = "docker-image://${CVEBENCH_UBUNTU_IMAGE}"
        },
        {
            NAME = "python"
            BASE = "docker-image://${CVEBENCH_PYTHON_IMAGE}"
        },
        {
            NAME = "php-base"
            BASE = "docker-image://${CVEBENCH_PYTHON_IMAGE}"
        },
        {
            NAME = "php7-apache-base"
            BASE = "docker-image://php:7.4-apache@sha256:c9d7e608f73832673479770d66aacc8100011ec751d1905ff63fae3fe2e0ca6d"
        },
        {
            NAME = "php7-fpm-base"
            BASE = "docker-image://php:7.4-fpm@sha256:3ac7c8c74b2b047c7cb273469d74fc0d59b857aa44043e6ea6a0084372811d5b"
        },
        {
            NAME = "php8-apache-base"
            BASE = "docker-image://php:8.3-apache@sha256:c3338496ce01bae7c172f0e70e43a25fb698812c920c03467fa474f635c075a3"
        },
    ]
  }

  dockerfile = "${CVEBENCH_DOCKER_DIR}/Dockerfile.mysql-client"
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
    base = "target:php${item}-base"
  }
}

target "stalwart-cli" {
    inherits = ["_common"]

    context = "${CVEBENCH_DOCKER_DIR}"
    dockerfile = "Dockerfile.stalwart-cli"
    contexts = {
      base = "docker-image://${CVEBENCH_BUILDER_IMAGE}"
    }
}

target "geckodriver" {
    inherits = ["_common"]

    context = "${CVEBENCH_DOCKER_DIR}"
    dockerfile = "Dockerfile.geckodriver"
    contexts = {
      base = "docker-image://${CVEBENCH_BUILDER_IMAGE}"
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
  tags = ["${organization}/${lower(item.CVE)}-${item.SERVICE}:${CVEBENCH_TAG}"]
  contexts = {
    base = item.BASE
  }
}

function "target-base-context" {
  params = [cve, base]
  result = equal(base, "target:wordpress") ? "${CVEBENCH_DOCKER_DIR}/wordpress" : "${CVEBENCH_CHALLENGE_DIR}/${cve}/target"
}

target "target-base" {
  inherits = ["common"]

  name = "${item.CVE}-target-base"
  matrix = {
    item = CVEBENCH_CVES
  }

  context = target-base-context(item.CVE, item.BASE)
  dockerfile = "Dockerfile.target"

  contexts = {
    base = item.BASE
    plugins = "${CVEBENCH_CHALLENGE_DIR}/${item.CVE}/target"
  }
}

target "target" {
  inherits = ["common", "image"]

  name = "${item.CVE}-target"
  matrix = {
    item = CVEBENCH_CVES
  }

  dockerfile = "Dockerfile.target"
  context = "${CVEBENCH_DOCKER_DIR}"

  tags = ["${organization}/${lower(item.CVE)}-target:${CVEBENCH_TAG}"]

  args = {
    APPLICATION_NAME = item.APPLICATION_NAME
    EVALUATOR_EXTRAS = lookup(CVEBENCH_CVES_EVALUATOR_UV_EXTRA_ARGS, item.CVE, "")
  }

  contexts = {
    evaluation = "${CVEBENCH_EVALUATIONS_DIR}"
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
        },
        {
            size = "large"
        },
    ]
  }
  tags = ["${organization}/kali-${item.size}:${CVEBENCH_TAG}"]
  context = "${CVEBENCH_SANDBOXES_DIR}/kali"
  contexts = {
    base = "docker-image://${CVEBENCH_KALI_IMAGE}"
  }
  args = {
    CVEBENCH_KALI_SIZE = item.size
  }
}
