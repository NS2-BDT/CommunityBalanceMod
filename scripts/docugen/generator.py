from datetime import date
from .database import connect_to_database
from .file_scanner import scan_for_docugen_files
from . import markdown_generator
from . import changelog
from config_loader import load_docugen_config

import re

def find_last_mod_version(c, mod_version, beta_version):
    # If we have a beta version try and find the previous beta version (it may not exist as this could be the first beta release)
    if beta_version > 0:
        line = c.execute('SELECT modVersion, betaVersion FROM BetaChangelog WHERE modVersion = ? AND betaVersion < ? ORDER BY betaVersion DESC, modVersion DESC LIMIT 1''', [mod_version, beta_version]).fetchone()
        # If we found a match then return it, otherwise look for a previous mod_version
        if line:
            return int(line[0]), int(line[1])

    line = c.execute('SELECT modVersion FROM FullChangeLog WHERE modVersion <> ? ORDER BY modVersion DESC LIMIT 1', [mod_version]).fetchone()

    if not line:
        print("Failed to find previous mod version. Defaulting to 0")
        return 0, 0

    return int(line[0]), 0

def get_changelog(c, mod_version, beta_version):
    if beta_version > 0:
        changelog = c.execute('SELECT key,value FROM BetaChangelog WHERE modVersion = ? AND betaVersion = ? ORDER BY key ASC', [mod_version, beta_version]).fetchall()
    else:
        changelog = c.execute('SELECT key,value FROM FullChangelog WHERE modVersion = ? ORDER BY key ASC', [mod_version]).fetchall()

    return changelog

def get_revision_names(mod_version, beta_version):
    if mod_version == 0:
        return None, None

    short_revision_name = "{}".format(mod_version)
    long_revision_name = "{}".format(mod_version)
    if beta_version > 0:
        short_revision_name = short_revision_name + "b{}".format(beta_version)
        long_revision_name = long_revision_name + " beta {}".format(beta_version)
    
    return short_revision_name, long_revision_name

def generate_change_logs(
    mod_name : str,
    vanilla_build : int,
    mod_revision : int,
    beta_revision : int,
    mod_src_path : str,
    vanilla_src_path : str,
    mod_balance_path : str
    ):

    conn, c = connect_to_database()
    prev_mod_revision, prev_beta_revision = find_last_mod_version(c, mod_revision, beta_revision)

    print("Starting docugen for {}".format(mod_name))
    print("Vanilla Version: {}".format(vanilla_build))
    print("{} Version: {}".format(mod_name, mod_revision))
    if beta_revision > 0:
        print("Beta Mod Version: {}".format(beta_revision))
    print("Previous Mod Version: {}".format(prev_mod_revision))

    # Generate index.md file
    create_index_page(mod_name, mod_revision, beta_revision)

    # Populate database for new version
    scan_for_docugen_files(
        conn,
        c,
        mod_revision,
        beta_revision,
        mod_src_path,
        vanilla_src_path,
        mod_balance_path
    )

    # Grab changelogs
    curr_changelog = get_changelog(c, mod_revision, beta_revision)
    prev_changelog = get_changelog(c, prev_mod_revision, prev_beta_revision)

    # Grab revision strings
    short_name, long_name = get_revision_names(mod_revision, beta_revision)
    short_name_prev, long_name_prev = get_revision_names(prev_mod_revision, prev_beta_revision)

    # Generate full changelog
    create_changelog_against_vanilla(mod_name, curr_changelog, vanilla_build, short_name, long_name)

    # Generate partial changelog
    create_changelog_stub(mod_name, curr_changelog, prev_changelog, short_name, long_name, short_name_prev)

def create_index_page(mod_name, mod_version, beta_version):
    docugen_config = load_docugen_config()
    is_beta = beta_version > 0
    index_data = docugen_config["index_data"]["beta" if is_beta else "release"]
    with open("docs/index.md", "w+") as f:
        f.write(index_data["title"].format(mod_name, mod_version, beta_version))
        for line in index_data["body"]:
            f.write(line)
        f.write("# Changes\n")

        revision_name = "revision{}".format(mod_version)
        if (is_beta):
            if "changes_note" in index_data:
                f.write(index_data["changes_note"])
            revision_name = "{}b{}".format(revision_name, beta_version)
    
        f.write('For a full list of changes from vanilla see [here](changelog "{} ChangeLog") or see [here](revisions/{} "Latest Revision") for the most recent changes\n'.format(mod_name, revision_name))

def create_changelog_against_vanilla(mod_name, curr_changelog, vanilla_version, short_name, long_name):
    # Create tree from table
    tree = changelog.ChangeLogTree(curr_changelog)

    # Generate markdown text and write to changelog file
    with open("docs/changelog.md", "w+") as f:
        f.write("# Changes between {} [revision {}](revisions/revision{}.md) and Vanilla Build {}\n".format(mod_name, long_name, short_name, vanilla_version))
        f.write("<br/>\n")
        f.write("\n")
        markdown_generator.generate(f, tree.root_node)
        f.write("\n")
        f.write("<br/>\n")
        f.write("<hr/>\n")
        f.write("<br/>\n")
        f.write("\n")
        f.write("Last updated: {}\n".format(date.today().strftime("%d %B %Y")))

def create_changelog_stub(mod_name, curr_changelog, prev_changelog, short_name, long_name, short_name_prev):
    # Diff both changelogs
    diff = changelog.diff(curr_changelog, prev_changelog)

    # Create tree from diff
    tree = changelog.ChangeLogTree(diff)

    # Write generated markdown to file
    with open("docs/revisions/revision{}.md".format(short_name), "w+") as f:
        # Create nav bar
        generate_nav_bar(f, long_name, short_name_prev)

        # Write out header
        f.write("# {} revision {} - ({})\n".format(mod_name, long_name, date.today().strftime("%d/%m/%Y")))

        # Generate our partial changelog if there are any changes, otherwise tell them there's no changes
        if len(diff) > 0:
            markdown_generator.generate_partial(f, tree.root_node)
        else:
            f.write("\n* No changes for this revision")
        
        f.write("\n<br/>\n\n")

    # If we have a previous mod version then update the links to point to our new version
    if short_name_prev:
        update_prev_nav_bar(short_name, short_name_prev)
        
def generate_nav_bar(f, long_name, short_name_prev):
    f.write('<div style="width:100%;background-color:#373737;color:#FFFFFF;text-align:center">\n')

    f.write('<div style="display:inline-block;float:left;padding-left:20%">\n')
    if short_name_prev:
        f.write('<a href="revision{}">\n'.format(short_name_prev))
        f.write('[ <- Previous ]\n')
        f.write('</a>\n')
    else:
        f.write('[ <- Previous ]\n')
    f.write('</div>\n')

    f.write('<div style="display:inline-block;">\n')
    f.write('Revision {}\n'.format(long_name))
    f.write('</div>\n')

    f.write('<div style="display:inline-block;float:right;padding-right:20%">\n')
    f.write('[ Next -> ]\n')
    f.write('</div>\n')

    f.write('</div>\n')

    f.write('\n<br />\n\n')

def update_prev_nav_bar(short_name, short_name_prev):
    lines = None
    filepath = "docs/revisions/revision{}.md".format(short_name_prev)
        
    with open(filepath, "r") as f:
        lines = f.readlines()
    
    i = 0
    for line in lines:
        i += 1
        if line == '<div style="display:inline-block;float:right;padding-right:20%">\n':
            break

    firstLines = lines[0:i]

    # If the next line is a link to the next page, skip the opening, closing and link text lines (3 lines). If it's not then just skip the link text (1 line)
    p = re.compile('^<a href=\"revision[0-9]+(?:b[0-9]+)\">$')
    if p.match(lines[i]):
        i += 3
    else:
        i += 1
    
    afterLines = lines[i:]

    with open(filepath, "w") as f:
        f.writelines(firstLines)
        f.write('<a href="revision{}">\n'.format(short_name))
        f.write('[ Next -> ]\n')
        f.write('</a>\n')
        f.writelines(afterLines)
