import yaml
import os

from metadata import get_metadata, CVEMetadata

def str_presenter(dumper, data):
    if data.count('\n') > 0:
        data = "\n".join([line.rstrip() for line in data.splitlines()])  # Remove any trailing spaces, then put it back together again
        return dumper.represent_scalar('tag:yaml.org,2002:str', data, style='|')
    return dumper.represent_scalar('tag:yaml.org,2002:str', data)

yaml.add_representer(str, str_presenter)
yaml.representer.SafeRepresenter.add_representer(str, str_presenter) # to use with safe_dum

from prompt import get_prompt
import argparse

parser = argparse.ArgumentParser(description="Generate challenge YAML files for CVE benchmarks.")
parser.add_argument("cve", help="The CVE identifier.")
parser.add_argument("--exclude-solution", action="store_true", help="Exclude solution files from the challenge.")
parser.add_argument("--include-solutions", default="", help="Optional list of solutions to include.")

args = parser.parse_args()

cve = args.cve
exclude_solution = args.exclude_solution
include_solutions = {c.strip() for c in args.include_solutions.split(',')} if args.include_solutions else set()
metadata_file_path = f"{os.environ['CVEBENCH_METADATA_DIR']}/{cve}.yml"
if not os.path.exists(metadata_file_path):
    metadata = CVEMetadata()
else:
    metadata = get_metadata(metadata_file_path)

metadata_dict = metadata.model_dump(exclude={"secret_file_dir"})
with open(metadata_file_path, 'w') as f:
    yaml.dump(metadata_dict, f)

challenge = { 
    "name": cve,
    "sandbox": {
        "type": "docker",
        "config": "compose.yml"
    },
    "variants": {
        "zero_day": {
            "prompt": get_prompt("zero_day", cve)
        },
        "one_day": {
            "prompt": get_prompt("one_day", cve)
        },
    },
    "metadata": metadata_dict
}

should_include_solution = cve in include_solutions or not exclude_solution

if should_include_solution:
    solution_files = []
    solution_dir = f'{os.environ["CVEBENCH_CHALLENGE_DIR"]}/{cve}/solution'
    for root, dirs, files in os.walk(solution_dir):
        for file in files:
            solution_files.append(os.path.relpath(os.path.join(root, file), solution_dir))
    solution_files_dict = {f"agent:/app/{file}": f"solution/{file}" for file in sorted(solution_files, key=lambda x: x[0])}

    challenge["variants"]["solution"] = {
            "prompt": "Run `chmod +x entrypoint.sh && ./entrypoint.sh`",
            "files": solution_files_dict,
        }

with open(f"{os.environ['CVEBENCH_CHALLENGE_DIR']}/{cve}/eval.yml", 'w') as f:
    yaml.dump(challenge, f, sort_keys=False)

env_file_path = f"{os.environ['CVEBENCH_CHALLENGE_DIR']}/{cve}/.env"
if os.path.exists(env_file_path):
    with open(env_file_path, 'r') as f:
        existing_env_file = {k: v.strip() for k, v in [line.split('=') for line in f.readlines() if '=' in line]}

metadata_keys = {k.upper() for k in metadata.model_dump().keys()}

existing_env_file.pop('CVE', None)
existing_env_file.pop('CVE_LOWER', None)
for k in metadata_keys:
    existing_env_file.pop(k, None)

env_file = {
    'CVE': cve,
    'CVE_LOWER': cve.lower(),
    **{k.upper(): v for k, v in metadata.model_dump().items()},
    **existing_env_file
}

with open(env_file_path, 'w') as f:
    for key, value in env_file.items():
        f.write(f"{key}={value}\n")
