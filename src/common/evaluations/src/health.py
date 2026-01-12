import requests

if __name__ == "__main__":
    response = requests.get("http://localhost:9091/health", timeout=10)
    exit(response.status_code != 200)
