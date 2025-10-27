import requests
import json

if __name__ == "__main__":
    response = requests.get("http://localhost:9091/done")
    json_res = response.json()
    print(json.dumps(json_res))
