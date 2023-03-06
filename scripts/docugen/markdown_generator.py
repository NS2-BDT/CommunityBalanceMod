from config_loader import load_docugen_config

def read_node_data_from_config():
    config = load_docugen_config()
    inodes : list = config["initial_nodes"]
    inodes.sort(key = lambda row : int(row["order"]))

    initial_node_order = list()
    images_for_nodes = dict()
    for node in inodes:
        initial_node_order.append(node["name"])
        images_for_nodes[node["name"]] = node["img_url"]
    
    return initial_node_order, images_for_nodes, config["enable_image_output"]

def generate(f, root_node):
    initial_node_order, images_for_nodes, enable_image_output = read_node_data_from_config()

    line_no = 0
    for initial_node in initial_node_order:
        image_url = None
        if enable_image_output:
            image_url = images_for_nodes[initial_node]

        if root_node.haschild(initial_node):
            line_no = render(root_node.getchild(initial_node), f, image_url=image_url, line_no=line_no)
        
    for child in root_node.children:
        if child.key in initial_node_order:
            continue

        line_no = render(child, f, line_no=line_no)

def generate_partial(f, root_node):
    initial_node_order, images_for_nodes, enable_image_output = read_node_data_from_config()
    
    line_no = 0
    for initial_node in initial_node_order:
        if root_node.haschild(initial_node):
            line_no = render(root_node.getchild(initial_node), f, additional_header_level=1, line_no=line_no)

    for child in root_node.children:
        if child.key in initial_node_order:
            continue

        line_no = render(child, f, additional_header_level=1, line_no=line_no)

def render(root, f, indent_index=0, line_no=0, image_url=None, additional_header_level=0):
    key = root.key
    values = root.values

    # First we write the key, heading/bullet point level depends on indent_index
    # We can control the initial header level by changing additional_header_level
    if indent_index == 0 or indent_index == 1:
        # Write a new line between the key unless it's the first line
        if line_no != 0:
            f.write("\n")

        f.write("#"*additional_header_level + "#"*(indent_index+1) + " {}\n".format(key))
    elif indent_index == 2 and additional_header_level == 0:
        # This is only really useful with no additional_header_level
        f.write("* ### {}\n".format(key))
    else:
        f.write(("  "*(indent_index-2)) + "* {}\n".format(key))

    # Increment line_no and indent_index
    line_no += 1
    indent_index += 1

    # Write image tag out if we have one
    if image_url != None:
        f.write('![alt text]({} "{}")\n'.format(image_url, key))

    # Write all values
    for value in values:
        orig_indent_index = indent_index
        i = 0

        # Values can be prefixed with ">" to indent.
        # Increment indent_index for each occurrence
        for c in value:
            if c == ">":
                indent_index += 1
                i += 1
            else:
                break

        # Remove any leading ">" chars
        value = value[i:]

        # Write vaue
        f.write(("  "*(indent_index-2)) + "* {}\n".format(value))

        # Restore original indent_index
        indent_index = orig_indent_index

    # Increment line_no by the number of values written
    line_no += len(values)

    # Call render recursively for every child node
    for child in root.children:
        line_no = render(child, f, indent_index=indent_index, line_no=line_no, additional_header_level=additional_header_level)

    return line_no
