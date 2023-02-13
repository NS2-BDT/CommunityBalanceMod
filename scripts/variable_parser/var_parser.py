import re

re_comments = re.compile("--.*\n")

def parse_file(filepath : str, tokens : dict = None, local_file : bool = False):
    if not tokens:
        tokens = dict()

    data = None
    with open(filepath, "r") as f:
        data = f.read()

    data = re_comments.sub(" ", data)
    data = data.replace(" local ", " ")
    data = data.replace("\nlocal ", " ")

    eq_idx = data.rfind("=")
    end = data.find("\n", eq_idx)

    # In case the file doens't have a trailing newline, 
    if end == -1:
        end = len(data)

    # Be careful here, make sure we don't lengthen the character count of the string
    data = data.replace("\n", " ")

    while eq_idx != -1:
        # Everything between the end of the line and the equal sign is our value
        value = data[eq_idx + 1:end].strip()

        # Now we find the name
        name_end = eq_idx - 1
        name_start = name_end

        # First skip over any spaces between the equals and the name
        if data[name_start] == " ":
            while name_start > 0 and data[name_start] == " ": name_start -= 1

        # Then find the next space, the substr inbetween the equals and this space is our name
        name_start = data.rfind(" ", 0, name_start)

        # Dont include the space in our name.
        # This also catches if name_start = -1 (which occurs if the next space was not found i.e this is the last variable). In this case we want the name_start = 0
        name_start += 1

        # Extract the name
        name = data[name_start:name_end].strip()

        if not name in tokens:
            tokens[name] = value
        elif local_file:
            print("Warning: {} is already defined".format(name))

        # Set the end of the string to the start of our name minus the space
        end = name_start - 1

        # Find the next equals sign
        eq_idx = data.rfind("=", 0, eq_idx)

    return tokens


def parse_local_and_vanilla(local_balance_filepath : str, vanilla_balance_filepath : str, vanilla_balance_health_filepath : str, vanilla_balance_misc_filepath : str):
    local_tokens = parse_file(local_balance_filepath, local_file=True)
    vanilla_tokens = parse_file(vanilla_balance_health_filepath)
    vanilla_tokens = parse_file(vanilla_balance_misc_filepath, tokens = vanilla_tokens)
    vanilla_tokens = parse_file(vanilla_balance_filepath, tokens = vanilla_tokens)

    # Reverse our dicts key order so that it's in the order they appear in the Balance.lua files
    local_tokens = dict(reversed(list(local_tokens.items())))
    vanilla_tokens = dict(reversed(list(vanilla_tokens.items())))

    return local_tokens, vanilla_tokens
