import sys
import os
import re
from variable_parser import var_parser
from config_loader import load_general_config, get_ns2_install_path

re_comments = re.compile("--.*\n")

def check_for_unique_var_usage(var, mod_src_path, mod_tokens):
    for (dirpath, dirnames, filenames) in os.walk(mod_src_path):
        for file in filenames:
            if file.endswith(".lua"):
                if check_for_var_in_file(var, os.path.join(dirpath, file), file == "Balance.lua", mod_tokens):
                    return True

    return False


def check_for_var_in_file(var : str, filepath : str, balancefile : bool, mod_tokens : dict):
    data = None
    with open(filepath, "r") as f:
        data = f.read()

    data = re_comments.sub("", data)
    # We want to retain the newline data for the regex matching, otherwise it gets difficult to determine what's on the rhs of the equals sign
    # data = data.replace("\n", " ")

    if balancefile:
        # Look for token in value of any mod_token
        for value in mod_tokens.values():
            if var in value:
                return True
    else:
        return data.find(var) != -1


def main():
    config = load_general_config()
    install_path = get_ns2_install_path()

    mod_name = config["mod_name"]
    mod_src_path = config["mod_src_dir"]
    mod_balance_filepath = config["balance_lua_file"]
    vanilla_balance_filepath = os.path.join(install_path, "ns2", "lua", "Balance.lua")
    vanilla_balance_health_filepath = os.path.join(install_path, "ns2", "lua", "BalanceHealth.lua")
    vanilla_balance_misc_filepath = os.path.join(install_path, "ns2", "lua", "BalanceMisc.lua")

    mod_tokens, vanilla_tokens = var_parser.parse_local_and_vanilla(
        mod_balance_filepath,
        vanilla_balance_filepath,
        vanilla_balance_health_filepath,
        vanilla_balance_misc_filepath
    )

    for var in mod_tokens:
        c_value = mod_tokens[var]
        if not var in vanilla_tokens:
            if not check_for_unique_var_usage(var, mod_src_path, mod_tokens):
                print("Warning: {} is not in vanilla and is not used in {}".format(var, mod_name))
            continue

        v_value = vanilla_tokens[var]

        try:
            c_value_float = float(c_value)
            v_value_float = float(v_value)

            c_value = c_value_float
            v_value = v_value_float
        except:
            pass

        if c_value == v_value:
            print("Warning: {} has the same value in vanilla ({})".format(var, v_value))


if __name__ == "__main__":
    main()