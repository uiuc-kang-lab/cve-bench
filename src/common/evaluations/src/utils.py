import fcntl
import os
import tempfile
from contextlib import contextmanager

SECRET_UPLOAD_FILENAME = "upload.json"


def connect_to_mysql_db():
    import pymysql

    connection = pymysql.connect(
        read_default_file=os.path.expanduser("~/.my.cnf"),
        read_default_group="mariadb-client",
    )
    cursor = connection.cursor()
    return connection, cursor


def connect_to_mongo_db():
    import pymongo

    host = os.environ["MONGO_HOST"] if "MONGO_HOST" in os.environ else "db"
    user = "admin"
    password = os.environ["MONGO_INITDB_ROOT_PASSWORD"]
    database = os.environ["MONGO_INITDB_DATABASE"] if "MONGO_INITDB_DATABASE" in os.environ else "appdb"

    client = pymongo.MongoClient(
        host=host,
        username=user,
        password=password,
    )
    database = client.get_database(database)
    return client, database


@contextmanager
def file_lock(lock_path: str, mode: str = "exclusive"):
    with open(lock_path + ".lock", "a") as lock_file:
        lock_type = fcntl.LOCK_EX if mode == "exclusive" else fcntl.LOCK_SH
        fcntl.flock(lock_file.fileno(), lock_type)
        yield


def write_file_locked(filepath, content) -> None:
    with file_lock(filepath, "exclusive"):
        dir_path = os.path.dirname(filepath) or "."
        with tempfile.NamedTemporaryFile(mode="w", dir=dir_path, delete=False) as temp_file:
            temp_file.write(content)
            temp_filename = temp_file.name
        os.replace(temp_filename, filepath)


def read_file_locked(filepath) -> str:
    with file_lock(filepath, "shared"):
        with open(filepath, "r") as f:
            return f.read()


def get_webdriver():
    from selenium import webdriver
    from selenium.webdriver.firefox.service import Service
    from selenium.webdriver.firefox.options import Options

    options = Options()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    service = Service("/usr/bin/geckodriver")

    driver = webdriver.Firefox(service=service, options=options)

    return driver
