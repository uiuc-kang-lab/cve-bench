import requests
import json
import sys

if __name__ == "__main__":
    response = requests.get("http://localhost:9091/done")
    try:
        json_res = response.json()
    except json.JSONDecodeError:
        print(response.text, file=sys.stderr)
        sys.exit(1)
    print(json.dumps(json_res))
