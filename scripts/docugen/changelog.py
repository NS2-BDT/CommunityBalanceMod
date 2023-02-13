class ChangeLogTree:
    def __init__(self, raw_changelog):
        self.root_node = ChangeLogNode("root")
        for key,value in raw_changelog:
            self.injestkey(self.root_node, key, value)

    def injestkey(self, root, key, value):
        if "." in key:
            subkeys = key.split(".")
            root_subkey = subkeys[0]
            node = None
            if root.haschild(root_subkey):
                node = root.getchild(root_subkey)
            else:
                node = root.addchild(root_subkey, root)

            if not node:
                raise "Failed to injest key"

            self.injestkey(node, ".".join(subkeys[1:]), value)
        else:
            if root.haschild(key):
                node = root.getchild(key)
            else:
                node = root.addchild(key, root)
            node.addvalue(value)
            
class ChangeLogNode:
    def __init__(self, key, parent=None):
        self.key = key
        self.parent = parent
        self.children = []
        self.values = []

    def getchild(self, key):
        for child in self.children:
            if child.key == key:
                return child
        
        return None

    def haschild(self, key):
        return self.getchild(key) != None

    def addchild(self, key, value):
        child = ChangeLogNode(key, value)
        self.children.append(child)

        return child
    
    def addvalue(self, value):
        self.values.append(value)

def diff(curr, old):
    diff = []
    last_neutral_indent_key = ""
    last_neutral_indent_value = ""

    # Iterate through all key/value pairs in current_changelog
    for key,value in curr:
        found_key = False
        found_value = False
        if not value.startswith(">"):
            last_neutral_indent_key = key
            last_neutral_indent_value = value

        # With a single key/value pair in curr, look for a matching one
        # in the old changelog
        for key2,value2 in old:
            if key == key2:
                found_key = True
                if value2 == value:
                    found_value = True
            elif found_key:
                break

        # If we didn't find a match for the key it means that the key/value was added
        # If we did find a key but didn't find a value, it means that a key/value pair was modified
        if not found_key or not found_value:
            # Append the last neutral key/value pair if our value is manually indented.
            # This is to preserve semantic information that would be lost without the header
            if value.startswith(">") and last_neutral_indent_key != "" and last_neutral_indent_value != "":
                diff.append((last_neutral_indent_key, last_neutral_indent_value))
                last_neutral_indent_key = ""
                last_neutral_indent_value = ""

            diff.append((key, value))
            if key == last_neutral_indent_key and value == last_neutral_indent_value:
                last_neutral_indent_key = ""
                last_neutral_indent_value = ""

    # Check for any deletions
    for key,value in old:
        found_key = False
        found_value = False
        
        # Find matching key in curr
        for key2,value2 in curr:
            if key == key2:
                found_key = True
                if value2 == value:
                    found_value = True
            elif found_key:
                break

        # If a key exists in the old changelog but not in the current one, it's been removed
        # If we did find a key in the old changelog but didn't find the value in the new changelog
        # it's been removed
        if not found_key or not found_value:
            diff.append((key, "== REMOVED == " + value))

    return diff
