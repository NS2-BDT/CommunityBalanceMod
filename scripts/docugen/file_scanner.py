import os
import re
from .verbose import verbose_print
from variable_parser import var_parser
from enum import Enum

class FormatType (Enum):
    NONE = 0
    NUMBER = 1
    PERCENTAGE = 2
    INVERSE_PERCENTAGE = 3
    SCALAR = 4
    DAMAGE_TYPE = 5
    RADIANS = 6

format_type_map = {
    "Number": FormatType.NUMBER,
    "Percent": FormatType.PERCENTAGE,
    "InvPercent": FormatType.INVERSE_PERCENTAGE,
    "Scalar": FormatType.SCALAR,
    "DamageType": FormatType.DAMAGE_TYPE,
    "Radians": FormatType.RADIANS
}

re_dynamic_vars = re.compile("\{\{([^ ]+(?:, *[^ ]+ *= *[^$,}]+)*)\}\}")
re_generated_statements = re.compile("^(>*)!(.*)$")
re_additional_args = re.compile("([^ ]+)=([^,$]*)(?=,|$)")
re_comments = re.compile("--.*$")

def process_key(c, key, key_data, mod_version, beta_version):
    if len(key_data) > 0 and key:
        insert_to_database(c, mod_version, beta_version, key, key_data)
        verbose_print(" -> Processed key: {}".format(key))


def insert_to_database(c, mod_version, beta_version, key, key_data):
    for value in key_data:
        if beta_version > 0:
            c.execute("INSERT INTO BetaChangelog(modVersion, betaVersion, key, value) VALUES (?,?,?,?)", [mod_version, beta_version, key, value.strip()])
        else:
            c.execute("INSERT INTO FullChangelog(modVersion, key, value) VALUES (?,?,?)", [mod_version, key, value.strip()])


def scan_for_docugen_files(conn, c, mod_version, beta_version, local_src_path, vanilla_src_path, local_balance_filepath, vanilla_balance_filepath, vanilla_balance_health_filepath, vanilla_balance_misc_filepath):
    local_tokens, vanilla_tokens = var_parser.parse_local_and_vanilla(local_balance_filepath, vanilla_balance_filepath, vanilla_balance_health_filepath, vanilla_balance_misc_filepath)

    # Delete any current entries for mod_version
    if beta_version > 0:
        c.execute("DELETE FROM BetaChangelog WHERE modVersion = ? AND betaVersion = ?", [mod_version, beta_version])
    else:
        c.execute("DELETE FROM FullChangelog WHERE modVersion = ?", [mod_version])

    # Walk docs-data looking for .docugen files
    walk_path = "docs-data"
    verbose_print("Walking path: {}".format(walk_path))
    for root, dirs, files in os.walk(walk_path):
        # Read all docugen files and add entries to database
        for file in files:
            full_filepath = root + os.sep + file
            with open(full_filepath, "r") as f:
                data = f.readlines()
                key_data = []
                key = None
                verbose_print("Processing docugen file: {}".format(file))
                for line in data:
                    # Ignore blank lines
                    if line == "\n":
                        continue

                    # This line is a key, store the value and populate its key_data array
                    if line.startswith("#"):
                        # Process key/values (if there are any)
                        process_key(c, key, key_data, mod_version, beta_version)

                        key = line[1:].strip()
                        key_data = []
                    else:
                        key_entry = line.strip()
                        key_entry = process_dynamic_var(key_entry, local_tokens, local_src_path)
                        key_entry = process_generated_statement(key_entry, local_tokens, vanilla_tokens, local_src_path, vanilla_src_path)
                        key_data.append(key_entry)
                
                # Process the last key if there is one
                process_key(c, key, key_data, mod_version, beta_version)
    
    # Commit table changes
    conn.commit()


# Replace dynamic vars with their values
def process_dynamic_var(key_entry : str, local_tokens : dict, local_src_path : str):
    dynamic_vars = re_dynamic_vars.findall(key_entry)
    for s in dynamic_vars:
        var = None
        fmt = None
        suffix = ""
        suffix_singular = None

        if s.find(",") != -1:
            var = s[0:s.index(",")]
            args = parse_args(s, ["format", "suffix", "suffix_singular"])
            fmt_str = args.get("format")
            suffix = args.get("suffix", "")
            suffix_singular = args.get("suffix_singular")

            if fmt_str:
                fmt = get_format_type(fmt_str)
                if fmt == FormatType.NONE:
                    raise Exception("Invalid format given ({}) for {}".format(fmt_str, s))

            if suffix_singular and not suffix:
                raise Exception("Must provide suffix when using suffix_singular")
        else:
            var = s

        value = resolve_variable(var, local_tokens, local_src_path)
        value = transform_value(value, fmt)
        value = format_value(value, fmt)
        suffix = set_suffix(value, suffix, suffix_singular)
        suffix_space = " " if suffix and len(suffix) > 0 else ""

        value = "{}{}{}".format(value, suffix_space, suffix)

        key_entry = key_entry.replace("{{{{{}}}}}".format(s), value)
    
    return key_entry


def process_generated_statement(key_entry : str, local_tokens : dict, vanilla_tokens : dict, local_src_path : str, vanilla_src_path : str):
    m = re_generated_statements.search(key_entry)
    if not m:
        return key_entry

    (indent, s) = m.groups()
    var = s[0:s.index(",")]
    args = parse_args(s, [
        "description",
        "format",
        "suffix",
        "suffix_singular",
        "vanilla_value"
    ])
    desc = args.get("description")
    fmt = get_format_type(args.get("format"))
    suffix = args.get("suffix", "")
    suffix_singular = args.get("suffix_singular")
    from_val = args.get("vanilla_value")

    if not desc:
        raise Exception("Invalid or missing description")

    if suffix_singular and not suffix:
        raise Exception("Must provide suffix when using suffix_singular")

    if fmt == FormatType.NONE:
        raise Exception("Invalid or missing format for key {}".format(key_entry))

    to_val = resolve_variable(var, local_tokens, local_src_path)
    to_val = transform_value(to_val, fmt)

    if not from_val:
        from_val = resolve_variable(var, vanilla_tokens, vanilla_src_path)
    from_val = transform_value(from_val, fmt)

    verb = get_verb(to_val, from_val, fmt)

    to_val = format_value(to_val, fmt)
    to_suffix = set_suffix(to_val, suffix, suffix_singular)
    to_suffix_space = " " if to_suffix and len(to_suffix) > 0 else ""

    from_val = format_value(from_val, fmt)
    from_suffix = set_suffix(from_val, suffix, suffix_singular)
    from_suffix_space = " " if from_suffix and len(from_suffix) > 0 else ""
    
    return "{}{} {} to {}{}{} from {}{}{}".format(indent, verb, desc, to_val, to_suffix_space, to_suffix, from_val, from_suffix_space, from_suffix)


def set_suffix(val : str, suffix : str, suffix_singular : str):
    if val.isdigit() and int(val) == 1:
        return suffix_singular
        
    return suffix


def parse_args(s : str, valid_args : list):
    additional_args = dict()

    for m in re_additional_args.finditer(s):
        (name,value) = m.groups()
        
        if name not in valid_args:
            raise Exception("Invalid argument \"{}\"".format(name))

        additional_args[name] = value
    
    return additional_args


def transform_value(val, fmt : FormatType):
    if fmt == FormatType.INVERSE_PERCENTAGE:
        return 1 - float(val)
    elif fmt == FormatType.SCALAR:
        return float(val) - 1
    elif fmt == FormatType.RADIANS:
        m = re.match("^Math.Radians\((.*)\)$", val)
        if not m:
            raise Exception("Invalid value for type Radians")
        (v,) = m.groups()
        return v
    else:
        return val


def format_value(val, fmt : FormatType):
    if fmt == FormatType.PERCENTAGE or fmt == FormatType.INVERSE_PERCENTAGE or fmt == FormatType.SCALAR:
        return "{0:g}%".format(round(float(val) * 100, 2))
    elif fmt == FormatType.DAMAGE_TYPE:
        return val.replace("kDamageType.", "")
    else:
        return val


def resolve_variable(var : str, tokens : dict, src_path : str):
    if var.find(":") != -1:
        (filename, varname) = var.split(":")

        return find_val_in_file(filename, varname, src_path)
    else:
        return tokens[var]


def find_val_in_file(filename : str, varname : str, src_path : str):
    re_custom_var = re.compile("{} *= *(.+)$".format(varname))
    for (dirpath, dirnames, filenames) in os.walk(src_path):
        if not filename in filenames:
            continue

        target_filepath = os.path.join(dirpath, filename)

        data = None
        with open(target_filepath, "r") as f:
            data = f.readlines()

        for line in data:
            line = re_comments.sub("", line)
            m = re_custom_var.match(line)
            if not m:
                continue

            value = m.groups()[0].strip()
            return value

    return None


def get_format_type(fmt : str):
    return format_type_map.get(fmt, FormatType.NONE)


def get_verb(to_val, from_val, fmt : FormatType):
    numeric_formats = [
        FormatType.NUMBER,
        FormatType.PERCENTAGE,
        FormatType.INVERSE_PERCENTAGE,
        FormatType.SCALAR,
        FormatType.RADIANS
    ]

    if fmt in numeric_formats:
        to_val = float(to_val)
        from_val = float(from_val)
        return "Decreased" if to_val < from_val else "Increased"
    elif fmt == FormatType.DAMAGE_TYPE:
        return "Changed"
    else:
        raise Exception("Unknown verb for FormatType: {}".format(fmt))
