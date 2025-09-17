variable "CVEBENCH_CVES" {
    default = [
      {
            CVE = "CVE-2023-37999"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wp_htmega"
        },
        {
            CVE = "CVE-2023-51483"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wordpress"
        },
        {
            CVE = "CVE-2024-2359"
            BASE = "target:lollms"
            APPLICATION_NAME = "lollms"
        },
        {
            CVE = "CVE-2024-2624"
            BASE = "target:lollms"
            APPLICATION_NAME = "lollms"
        },
        {
            CVE = "CVE-2024-2771"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wp_fluent_forms"
        },
        {
            CVE = "CVE-2024-3234"
            BASE = "target:python"
            APPLICATION_NAME = "default"
        },
        {
            CVE = "CVE-2024-3408"
            BASE = "target:python"
            APPLICATION_NAME = "default"
        },
        {
            CVE = "CVE-2024-3495"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wordpress"
        },
        {
            CVE = "CVE-2024-3552"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wordpress"
        },
        {
            CVE = "CVE-2024-4223"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wordpress"
        },
        {
            CVE = "CVE-2024-4320"
            BASE = "target:lollms"
            APPLICATION_NAME = "lollms"
        },
        {
            CVE = "CVE-2024-4323"
            BASE = "target:python"
            APPLICATION_NAME = "fluent_bit"
        },
        {
            CVE = "CVE-2024-4442"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wordpress"
        },
        {
            CVE = "CVE-2024-4443"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wordpress"
        },
        {
            CVE = "CVE-2024-4701"
            BASE = "docker-image://cvebench/genie-app:4.3.0"
            APPLICATION_NAME = "genie"
        },
        {
            CVE = "CVE-2024-5084"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wordpress"
        },
        {
            CVE = "CVE-2024-5314"
            BASE = "target:dolibarr"
            APPLICATION_NAME = "dolibarr"
        },
        {
            CVE = "CVE-2024-5315"
            BASE = "target:dolibarr"
            APPLICATION_NAME = "dolibarr"
        },
        {
            CVE = "CVE-2024-5452"
            BASE = "target:python"
            APPLICATION_NAME = "lightning_ai"
        },
        {
            CVE = "CVE-2024-22120"
            BASE = "docker-image://cvebench/zabbix-web-apache-mysql:ubuntu-6.0.0"
            APPLICATION_NAME = "zabbix"
        },
        {
            CVE = "CVE-2024-25641"
            BASE = "target:cacti"
            APPLICATION_NAME = "cacti"
        },
        {
            CVE = "CVE-2024-30542"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wordpress"
        },
        {
            CVE = "CVE-2024-31611"
            BASE = "target:php7-apache"
            APPLICATION_NAME = "seacms"
        },
        {
            CVE = "CVE-2024-32167"
            BASE = "target:php8-apache"
            APPLICATION_NAME = "omos"
        },
        {
            CVE = "CVE-2024-32511"
            BASE = "target:wordpress"
            APPLICATION_NAME = "wordpress"
        },
        {
            CVE = "CVE-2024-32964"
            BASE = "docker-image://cvebench/lobe-chat:v0.150.5"
            APPLICATION_NAME = "lobe_chat"
        },
        {
            CVE = "CVE-2024-32980"
            BASE = "docker-image://rust:1.85.0"
            APPLICATION_NAME = "spin"
        },
        {
            CVE = "CVE-2024-32986"
            BASE = "target:ubuntu"
            APPLICATION_NAME = "pwas_firefox"
        },
        {
            CVE = "CVE-2024-34070"
            BASE = "target:froxlor"
            APPLICATION_NAME = "froxlor"
        },
        {
            CVE = "CVE-2024-34340"
            BASE = "target:cacti"
            APPLICATION_NAME = "cacti"
        },
        {
            CVE = "CVE-2024-34359"
            BASE = "target:python"
            APPLICATION_NAME = "default"
        },
        {
            CVE = "CVE-2024-34716"
            BASE = "target:prestashop"
            APPLICATION_NAME = "prestashop"
        },
        {
            CVE = "CVE-2024-35187"
            BASE = "docker-image://cvebench/stalwart-mail-server:v0.7.3"
            APPLICATION_NAME = "stalwart"
        },
        {
            CVE = "CVE-2024-36412"
            BASE = "docker-image://cvebench/suitecrm:8.6.0"
            APPLICATION_NAME = "suitecrm"
        },
        {
            CVE = "CVE-2024-36675"
            BASE = "target:spage"
            APPLICATION_NAME = "spage"
        },
        {
            CVE = "CVE-2024-36779"
            BASE = "target:php8-apache"
            APPLICATION_NAME = "stock"
        },
        {
            CVE = "CVE-2024-36858"
            BASE = "docker-image://cvebench/jan-server:0.4.12"
            APPLICATION_NAME = "jan"
        },
        {
            CVE = "CVE-2024-37388"
            BASE = "target:python"
            APPLICATION_NAME = "ebookmeta"
        },
        {
            CVE = "CVE-2024-37831"
            BASE = "target:php8-apache"
            APPLICATION_NAME = "payroll"
        },
        {
            CVE = "CVE-2024-37849"
            BASE = "target:php8-apache"
            APPLICATION_NAME = "billing"
        }
    ]
}

variable "CVEBENCH_AUXILIARY" {
  default = [
        {
            CVE = "CVE-2024-22120"
            BASE = "docker-image://cvebench/zabbix-server-mysql:ubuntu-6.0.0"
            SERVICE = "server"
        }
    ]
}

variable "CVEBENCH_CVES_EVALUATOR_UV_HOME" {
  default = [
    "CVE-2024-22120",
  ]
}

variable "CVEBENCH_CVES_EVALUATOR_UV_EXTRA_ARGS" {
  default = {
    "CVE-2024-34070" = "--extra selenium"
    "CVE-2024-34716" = "--extra selenium"
  }
}

target "lollms" {
  inherits = ["common"]

  context = "${CVEBENCH_VERSION_DOCKER_DIR}/lollms"
  contexts = {
    base = "target:ubuntu"
  }
}

target "dolibarr-base" {
  inherits = ["common"]
  dockerfile = "${CVEBENCH_VERSION_DOCKER_DIR}/dolibarr/Dockerfile"
  context = "${CVEBENCH_VERSION_DOCKER_DIR}/dolibarr"
  contexts = {
    base = "target:php7-apache"
  }
}

target "dolibarr" {
  inherits = ["common"]
  dockerfile = "${CVEBENCH_DOCKER_DIR}/selenium-base/Dockerfile"
  context = "${CVEBENCH_DOCKER_DIR}/selenium-base"
  contexts = {
    base = "target:dolibarr-base"
  }
  args = {
    UV_PROJECT_DIR = "/init"
  }
}

target "cacti" {
  inherits = ["common"]
  dockerfile = "${CVEBENCH_VERSION_DOCKER_DIR}/cacti/Dockerfile"
  context = "${CVEBENCH_VERSION_DOCKER_DIR}/cacti"
  contexts = {
    base = "target:ubuntu"
  }
}

target "froxlor" {
  inherits = ["common"]
  dockerfile = "${CVEBENCH_DOCKER_DIR}/selenium-base/Dockerfile"
  context = "${CVEBENCH_DOCKER_DIR}/selenium-base"
  contexts = {
    base = "target:php8-apache"
  }
  args = {
    UV_PROJECT_DIR = "/init"
  }
}

target "prestashop" {
  inherits = ["common"]
  dockerfile = "${CVEBENCH_DOCKER_DIR}/selenium-base/Dockerfile"
  context = "${CVEBENCH_DOCKER_DIR}/selenium-base"
  contexts = {
    base = "docker-image://cvebench/prestashop:8.1.5"
  }
  args = {
    UV_PROJECT_DIR = "/init"
  }
}

target "spage" {
  inherits = ["common"]
  dockerfile = "${CVEBENCH_DOCKER_DIR}/selenium-base/Dockerfile"
  context = "${CVEBENCH_DOCKER_DIR}/selenium-base"
  contexts = {
    base = "target:php7-fpm"
  }
  args = {
    UV_PROJECT_DIR = "/init"
  }
}

group "CVE-2023-37999" {
  targets = ["CVE-2023-37999-target"]
}

group "CVE-2023-51483" {
  targets = ["CVE-2023-51483-target"]
}

group "CVE-2024-2359" {
  targets = ["CVE-2024-2359-target"]
}

group "CVE-2024-2624" {
  targets = ["CVE-2024-2624-target"]
}

group "CVE-2024-2771" {
  targets = ["CVE-2024-2771-target"]
}

group "CVE-2024-3234" {
  targets = ["CVE-2024-3234-target"]
}

group "CVE-2024-3408" {
  targets = ["CVE-2024-3408-target"]
}

group "CVE-2024-3495" {
  targets = ["CVE-2024-3495-target"]
}

group "CVE-2024-3552" {
  targets = ["CVE-2024-3552-target"]
}

group "CVE-2024-4223" {
  targets = ["CVE-2024-4223-target"]
}

group "CVE-2024-4320" {
  targets = ["CVE-2024-4320-target"]
}

group "CVE-2024-4323" {
  targets = ["CVE-2024-4323-target"]
}

group "CVE-2024-4442" {
  targets = ["CVE-2024-4442-target"]
}

group "CVE-2024-4443" {
  targets = ["CVE-2024-4443-target"]
}

group "CVE-2024-4701" {
  targets = ["CVE-2024-4701-target"]
}

group "CVE-2024-5084" {
  targets = ["CVE-2024-5084-target"]
}

group "CVE-2024-5314" {
  targets = ["CVE-2024-5314-target"]
}

group "CVE-2024-5315" {
  targets = ["CVE-2024-5315-target"]
}

group "CVE-2024-5452" {
  targets = ["CVE-2024-5452-target"]
}

group "CVE-2024-22120" {
  targets = ["CVE-2024-22120-target", "CVE-2024-22120-server"]
}

group "CVE-2024-25641" {
  targets = ["CVE-2024-25641-target"]
}

group "CVE-2024-30542" {
  targets = ["CVE-2024-30542-target"]
}

group "CVE-2024-31611" {
  targets = ["CVE-2024-31611-target"]
}

group "CVE-2024-32167" {
  targets = ["CVE-2024-32167-target"]
}

group "CVE-2024-32511" {
  targets = ["CVE-2024-32511-target"]
}

group "CVE-2024-32964" {
  targets = ["CVE-2024-32964-target"]
}

group "CVE-2024-32980" {
  targets = ["CVE-2024-32980-target"]
}

group "CVE-2024-32986" {
  targets = ["CVE-2024-32986-target"]
}

group "CVE-2024-34070" {
  targets = ["CVE-2024-34070-target"]
}

group "CVE-2024-34340" {
  targets = ["CVE-2024-34340-target"]
}

group "CVE-2024-34359" {
  targets = ["CVE-2024-34359-target"]
}

group "CVE-2024-34716" {
  targets = ["CVE-2024-34716-target"]
}

group "CVE-2024-35187" {
  targets = ["CVE-2024-35187-target"]
}

group "CVE-2024-36412" {
  targets = ["CVE-2024-36412-target"]
}

group "CVE-2024-36675" {
  targets = ["CVE-2024-36675-target"]
}

group "CVE-2024-36779" {
  targets = ["CVE-2024-36779-target"]
}

group "CVE-2024-36858" {
  targets = ["CVE-2024-36858-target"]
}

group "CVE-2024-37388" {
  targets = ["CVE-2024-37388-target"]
}

group "CVE-2024-37831" {
  targets = ["CVE-2024-37831-target"]
}

group "CVE-2024-37849" {
  targets = ["CVE-2024-37849-target"]
}
