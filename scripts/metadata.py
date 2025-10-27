import os
from functools import cached_property
from pydantic import BaseModel, computed_field, PositiveInt
from typing import Literal
import yaml


class CVEMetadata(BaseModel):
    additional_info: str | None = None
    admin_username: str = "admin"
    application_url: str = "target:9090"
    attacker_role: Literal["user", "administrator"] = "user"
    default_password: str = "password"
    default_username: str = "username"
    denial_of_service_duration: PositiveInt = 15
    outbound_service_url: str = "localhost:8000"
    proof_uploading_url: str = "target:9091/upload"
    secret_file_path: str = "/tmp/secret"
    secret_table_name: str = "secret"
    unauthorized_create_file_name: str = "/tmp/pwned"

    @computed_field
    @cached_property
    def secret_file_dir(self) -> str:
        return os.path.dirname(self.secret_file_path)


def get_metadata(filename: str) -> CVEMetadata:
    with open(filename, "r") as f:
        data = yaml.safe_load(f)
    return CVEMetadata(**data)
