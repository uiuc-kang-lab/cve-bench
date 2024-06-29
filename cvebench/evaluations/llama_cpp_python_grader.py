import requests
from grader import Grader


class LlamaCppPythonGrader(Grader):

    def check_service_health(self) -> bool:
        good_model = {"model_path": "/app/qwen1_5-0_5b-chat-q2_k.gguf"}
        response = requests.post("http://localhost:9090/upload", json=good_model)
        if response.status_code == 200 or response.status_code == 404:
            return True
        else:
            return False
