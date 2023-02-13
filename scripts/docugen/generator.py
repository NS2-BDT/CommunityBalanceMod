from datetime import date
from .database import connect_to_database
from .file_scanner import scan_for_docugen_files
from .verbose import verbose_print
from . import markdown_generator
from . import changelog

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

def generate_change_logs(args):
    conn, c = connect_to_database()
    vanilla_version = args.vanilla_version
    mod_version = args.mod_version
    beta_version = args.beta_version
    prev_mod_version, prev_beta_version = find_last_mod_version(c, mod_version, beta_version)

    verbose_print("Starting docugen for Legacy Balance Mod")
    verbose_print("Vanilla Version: {}".format(vanilla_version))
    verbose_print("Mod Version: {}".format(mod_version))
    if beta_version > 0:
        verbose_print("Beta Mod Version: {}".format(beta_version))
    verbose_print("Previous Mod Version: {}".format(prev_mod_version))

    # Generate index.md file
    create_index_page(mod_version, beta_version)

    # Populate database for new version
    scan_for_docugen_files(conn, c, mod_version, beta_version, args.local_src_path, args.vanilla_src_path, args.local_balance_filepath, args.vanilla_balance_filepath, args.vanilla_balance_health_filepath, args.vanilla_balance_misc_filepath)

    # Grab changelogs
    curr_changelog = get_changelog(c, mod_version, beta_version)
    prev_changelog = get_changelog(c, prev_mod_version, prev_beta_version)

    # Grab revision strings
    short_name, long_name = get_revision_names(mod_version, beta_version)
    short_name_prev, long_name_prev = get_revision_names(prev_mod_version, prev_beta_version)

    # Generate full changelog
    create_changelog_against_vanilla(c, curr_changelog, vanilla_version, short_name, long_name)

    # Generate partial changelog
    create_changelog_stub(c, curr_changelog, prev_changelog, short_name, long_name, short_name_prev)

def create_index_page(mod_version, beta_version):
    is_beta = beta_version > 0
    with open("docs/index.md", "w+") as f:
        if (is_beta):
            f.write("# BDT Legacy Balance Mod (Beta) Revision {} Beta {}\n".format(mod_version, beta_version))
        else:
            f.write("# BDT Legacy Balance Mod Revision {}\n".format(mod_version))

        f.write("A Natural Selection 2 balance and feature mod developed and maintained by the BDT.\n\n")
        f.write("# Changes\n")

        revision_name = "revision{}".format(mod_version)
        if (is_beta):
            f.write("*Please note changes in this mod are experimental and are not guaranteed to make it into a Legacy Balance Mod release.\n\n")
            revision_name = "{}b{}".format(revision_name, beta_version)
    
        f.write('For a full list of changes from vanilla see [here](changelog "Legacy Balance Mod ChangeLog") or see [here](revisions/{0} "Latest Revision") for the most recent changes\n'.format(revision_name))

def create_changelog_against_vanilla(c, curr_changelog, vanilla_version, short_name, long_name):
    # Create tree from table
    tree = changelog.ChangeLogTree(curr_changelog)

    # Generate markdown text and write to changelog file
    with open("docs/changelog.md", "w+") as f:
        f.write("# Changes between Legacy Balance Mod [revision {0}](revisions/revision{1}.md) and Vanilla Build {2}\n".format(long_name, short_name, vanilla_version))
        f.write("<br/>\n")
        f.write("\n")
        markdown_generator.generate(f, tree.root_node)
        f.write("\n")
        f.write("<br/>\n")
        f.write("<hr/>\n")
        f.write("<br/>\n")
        f.write("\n")
        f.write("Last updated: {}\n".format(date.today().strftime("%d %B %Y")))

def create_changelog_stub(c, curr_changelog, prev_changelog, short_name, long_name, short_name_prev):
    # Diff both changelogs
    diff = changelog.diff(curr_changelog, prev_changelog)

    # Create tree from diff
    tree = changelog.ChangeLogTree(diff)

    # Write generated markdown to file
    with open("docs/revisions/revision{}.md".format(short_name), "w+") as f:
        # Create nav bar
        generate_nav_bar(f, long_name, short_name_prev)

        # Write out header
        f.write("# Legacy Balance Mod revision {} - ({})\n".format(long_name, date.today().strftime("%d/%m/%Y")))

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
