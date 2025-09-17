import json, os, time
from collections import deque
from flask import Flask, jsonify, request
from threading import Thread
from grader import Grader

from utils import write_file_locked, SECRET_UPLOAD_FILENAME


def get_grader() -> Grader:
    application = os.getenv("APPLICATION_NAME")
    if application == "cacti":
        from cacti_grader import CactiGrader

        return CactiGrader()
    elif application == "fluent_bit":
        from fluent_bit_grader import FluentBitGrader

        return FluentBitGrader()
    elif application == "llama_cpp_python":
        from llama_cpp_python_grader import LlamaCppPythonGrader

        return LlamaCppPythonGrader()
    elif application == "prestashop":
        from prestashop_grader import PrestashopGrader

        return PrestashopGrader()
    elif application == "pwas_firefox":
        from pwas_firefox_grader import PWAsForFirefoxGrader

        return PWAsForFirefoxGrader()
    elif application == "genie":
        from genie_grader import GenieGrader

        return GenieGrader()
    elif application == "wordpress":
        from wordpress_grader import WordPressGrader

        return WordPressGrader()
    elif application == "spin":
        from spin_grader import SpinGrader

        return SpinGrader()
    elif application == "lobe_chat":
        from lobe_chat_grader import LobeChatGrader

        return LobeChatGrader()
    elif application == "wp_fluent_forms":
        from wp_fluent_forms_grader import WPFluentFormsGrader

        return WPFluentFormsGrader()
    elif application == "wp_htmega":
        from wp_htmega_grader import WPHTMegaGrader

        return WPHTMegaGrader()
    elif application == "dolibarr":
        from dolibarr_grader import DolibarrGrader

        return DolibarrGrader()
    elif application == "stalwart":
        from stalwart_grader import StalwartGrader

        return StalwartGrader()
    elif application == "lollms":
        from lollms_grader import LollmsGrader

        return LollmsGrader()
    elif application == "omos":
        from omos_grader import OmosGrader

        return OmosGrader()
    elif application == "spage":
        from spage_grader import SpageGrader

        return SpageGrader()
    elif application == "jan":
        from jan_grader import JanGrader

        return JanGrader()
    elif application == "seacms":
        from seacms_grader import SeacmsGrader

        return SeacmsGrader()
    elif application == "suitecrm":
        from suitecrm_grader import SuiteCRMGrader

        return SuiteCRMGrader()
    elif application == "billing":
        from billing_grader import BillingGrader

        return BillingGrader()
    elif application == "payroll":
        from payroll_grader import PayrollGrader
        
        return PayrollGrader()
    elif application == "zabbix":
        from zabbix_grader import ZabbixGrader

        return ZabbixGrader()
    elif application == "froxlor":
        from froxlor_grader import FroxlorGrader
        
        return FroxlorGrader()
    elif application == "stock":
        from stock_grader import StockGrader

        return StockGrader()
    elif application == "anythingllm":
        from anythingllm_grader import AnythingLLMGrader

        return AnythingLLMGrader()
    elif application == "opencart":
        from opencart_grader import OpencartGrader

        return OpencartGrader()
    else:
        return Grader()


grader = get_grader()
app = Flask(__name__)

ringbuffer = deque(maxlen=5)


def health_loop():
    while True:
        ringbuffer.append(grader.check_service_health())
        print("background health ringbuffer: ", ringbuffer)
        time.sleep(3)

Thread(target=health_loop, daemon=True).start()


@app.route("/health")
def health():
    if len(ringbuffer) == ringbuffer.maxlen and all(ringbuffer):
        return jsonify(message="Service is healthy"), 200
    else:
        return jsonify(message="Service is unhealthy"), 500


@app.route("/done")
def done():
    status, message = grader.check_attack_success()
    return jsonify({"status": status, "message": message})


@app.route("/upload", methods=["POST"])
def upload():
    data = request.get_json()

    # Validate that data contains only string-to-string mappings
    if not isinstance(data, dict):
        return jsonify(error="Data must be a dictionary"), 400

    # Validate that dictionary contains exactly one key-value pair
    if len(data) != 1:
        return jsonify(error=f"Dictionary must contain exactly one key-value pair, found {len(data)}"), 400

    for key, value in data.items():
        if not isinstance(key, str):
            return jsonify(error=f"All keys must be strings, found {type(key).__name__}"), 400
        if not isinstance(value, str):
            return jsonify(error=f"All values must be strings, found {type(value).__name__} for key '{key}'"), 400

        # Validate maximum length of 256 characters
        if len(key) > 256:
            return jsonify(error=f"Key length must be at most 256 characters, found {len(key)} characters"), 400
        if len(value) > 256:
            return jsonify(error=f"Value length must be at most 256 characters, found {len(value)} characters for key '{key}'"), 400

    write_file_locked(SECRET_UPLOAD_FILENAME, json.dumps(data))

    return jsonify(message="Data uploaded successfully"), 200


@app.route("/target_info", methods=["GET"])
def target_attacks():
    return jsonify(grader.get_info()), 200
