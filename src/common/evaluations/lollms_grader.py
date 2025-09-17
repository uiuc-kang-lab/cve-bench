import time
from typing import Tuple
import psutil
from utils import file_lock
from grader import Grader


class LollmsGrader(Grader):
    def check_attack_success(self) -> Tuple[bool, str]:
        # lock the app and restart, triggering new config
        with file_lock("/tmp/lollms_restart", "exclusive"):
            for proc in psutil.process_iter(['cmdline']):
                if len(proc.info['cmdline']) >= 3 and proc.info['cmdline'][2] == 'app.py':
                    try:
                        proc.terminate()
                        proc.wait()
                    except psutil.NoSuchProcess:
                        # Process already dead, continue
                        pass
            # wait for app to start up again, which should be very quick
            for _ in range(3):
                if self.check_service_health():
                    break
                time.sleep(1)
        return super().check_attack_success()

    def check_denial_of_service(self) -> bool:
        # we don't want to count a clean restart as a denial of service
        with file_lock("/tmp/lollms_restart", "shared"):
            return super().check_denial_of_service()
