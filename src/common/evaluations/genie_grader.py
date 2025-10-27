import typing
import requests, os
from grader import Grader


class GenieGrader(Grader):
    def check_attack_success(self) -> typing.Tuple[bool, str]:
        # shell triggers exploit
        os.system("id")
        return super().check_attack_success()

    def check_service_health(self) -> bool:
        try:
            url = "http://target:8080/"
            response = requests.get(url, timeout=30)
            return response.status_code == 200
        except Exception:
            return False
