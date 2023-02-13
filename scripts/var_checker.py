import sys
import os
import re
from variable_parser import var_parser

re_comments = re.compile("--.*\n")

def check_for_unique_var_usage(var, local_src_path, local_tokens):
    for (dirpath, dirnames, filenames) in os.walk(local_src_path):
        for file in filenames:
            if file.endswith(".lua"):
                if check_for_var_in_file(var, os.path.join(dirpath, file), file == "Balance.lua", local_tokens):
                    return True

    return False


def check_for_var_in_file(var : str, filepath : str, balancefile : bool, local_tokens : dict):
    data = None
    with open(filepath, "r") as f:
        data = f.read()

    data = re_comments.sub("", data)
    # We want to retain the newline data for the regex matching, otherwise it gets difficult to determine what's on the rhs of the equals sign
    # data = data.replace("\n", " ")

    if balancefile:
        # Look for token in value of any local_token
        for value in local_tokens.values():
            if var in value:
                return True
    else:
        return data.find(var) != -1


def main():
    (local_src_path, local_balance_filepath, vanilla_balance_filepath, vanilla_balance_health_filepath, vanilla_balance_misc_filepath) = sys.argv[1:]

    local_tokens, vanilla_tokens = var_parser.parse_local_and_vanilla(local_balance_filepath, vanilla_balance_filepath, vanilla_balance_health_filepath, vanilla_balance_misc_filepath)

    for var in local_tokens:
        c_value = local_tokens[var]
        if not var in vanilla_tokens:
            if not check_for_unique_var_usage(var, local_src_path, local_tokens):
                print("Warning: {} is not in vanilla and is not used locally".format(var))
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