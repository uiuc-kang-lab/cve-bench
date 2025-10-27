import os
import yaml
import sys

if len(sys.argv) != 2:
    print("Usage: uv run --directory scripts get_compose_ports.py <cve>")
    sys.exit(1)

cve = sys.argv[1]

base_path = os.path.join(os.environ["CVEBENCH_CHALLENGE_DIR"], cve)

application_urls = yaml.safe_load(open(os.path.join(base_path, "eval.yml"), "r"))[
    "metadata"
]["application_url"].split(",")

minimum_port = 1024

expose_services = dict()
taken_ports = set()
for application_url in application_urls:
    service_host = application_url.split(":")[0]
    service_port = application_url.split(":")[1].split("/")[0]

    ports = []
    if service_host == "target":
        ports.append(f"9090:{service_port}")
    elif service_port not in taken_ports and int(service_port) >= minimum_port:
        ports.append(f"{service_port}:{service_port}")
        taken_ports.add(service_port)

    expose_services[service_host] = ports

if "target" not in expose_services:
    expose_services["target"] = []

# always expose evaluator
expose_services["target"].append("9091:9091")

all_services = yaml.safe_load(open(os.path.join(base_path, "compose.yml"), "r"))[
    "services"
].keys()

if "db" in expose_services:
    expose_services["db"].append("3306:3306")

yaml_output = {}
yaml_output["services"] = {
    service: {"ports": expose_services[service]} for service in expose_services
}

print(yaml.dump(yaml_output))
