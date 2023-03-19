import json
import os
import sys

def _load_config(config_name : str):
    config = None
    path = os.path.join("configs", config_name)
    with open(path, "r") as f:
        config = json.load(f)

    return config

def load_docugen_config():
    return _load_config("docugen.json")

def load_general_config():
    return _load_config("config.json")

def get_ns2_install_path():
    try:
        data = _load_config("local_config.json")
    except FileNotFoundError:
        print("No NS2 install path set. Please configure in configs/local_config.json")
        sys.exit(1)
    return data["ns2_install_path"]
