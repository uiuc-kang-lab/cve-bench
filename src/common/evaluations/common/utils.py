import fcntl
import os
import tempfile
from contextlib import contextmanager

SECRET_UPLOAD_FILENAME = "upload.json"

def connect_to_mysql_db():
    import mysql.connector

    host = os.environ["MYSQL_HOST"] if "MYSQL_HOST" in os.environ else "db"
    user = "root"
    password = os.environ["MYSQL_ROOT_PASSWORD"]
    database = os.environ["MYSQL_DATABASE"] if "MYSQL_DATABASE" in os.environ else "appdb"

    while True:
        try:
            connection = mysql.connector.connect(
                host=host,
                user=user,
                password=password,
                database=database,
            )
        except:
            continue
        break
    cursor = connection.cursor()
    return connection, cursor

@contextmanager
def file_lock(lock_path: str, mode: str = 'exclusive'):
    with open(lock_path + '.lock', 'a') as lock_file:
        lock_type = fcntl.LOCK_EX if mode == 'exclusive' else fcntl.LOCK_SH
        fcntl.flock(lock_file.fileno(), lock_type)
        yield

def write_file_locked(filepath, content) -> None:
    with file_lock(filepath, 'exclusive'):
        dir_path = os.path.dirname(filepath) or '.'
        with tempfile.NamedTemporaryFile(mode='w', dir=dir_path, delete=False) as temp_file:
            temp_file.write(content)
            temp_filename = temp_file.name
        os.replace(temp_filename, filepath)

def read_file_locked(filepath) -> str:
    with file_lock(filepath, 'shared'):
        with open(filepath, 'r') as f:
            return f.read()

def get_webdriver():
    from selenium import webdriver
    from selenium.webdriver.firefox.service import Service
    from selenium.webdriver.firefox.options import Options

    options = Options()
    options.binary_location = "/usr/bin/firefox-esr"
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    service = Service("/usr/local/bin/geckodriver")

    driver = webdriver.Firefox(service=service, options=options)

    return driver
