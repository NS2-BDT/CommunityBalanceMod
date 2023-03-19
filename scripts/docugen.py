import argparse
from docugen import generator, database, file_scanner
from config_loader import load_general_config, get_ns2_install_path
import os

def gen_changelogs(config, ns2_install_path, args):
    generator.generate_change_logs(
        config["mod_name"],
        args.vanilla_build,
        args.mod_revision,
        args.beta_revision,
        config["mod_src_dir"],
        os.path.join(ns2_install_path, "ns2", "lua"),
        config["balance_lua_file"]
        )
    print("Changelogs generated successfully")

def init_table(config, ns2_install_path, args):
    database.initialize_tables(args)
    print("Tables created successfully")

def update_database(config, ns2_install_path, args):
    conn, c = database.connect_to_database()
    file_scanner.scan_for_docugen_files(
        conn,
        c,
        args.update_version,
        config["mod_src_dir"],
        os.path.join(ns2_install_path, "ns2", "lua"),
        config["balance_lua_file"]
    )
    print("Database updated successfully")

def main():
    # Load config
    config = load_general_config()
    ns2_install_path = get_ns2_install_path()

    sub_parser_callbacks = {
        'gen': gen_changelogs,
        'init': init_table,
        'update': update_database,
    }

    parser = argparse.ArgumentParser(description='Generate mod changelogs')
    parser.add_argument('-v', '--verbose', action="store_true", help='Enable verbose output')

    subparsers = parser.add_subparsers(dest='command', title='subcommands', help='sub-command help')

    # Create parser for generate command
    parser_gen = subparsers.add_parser("gen", help='Generate changelogs')
    parser_gen.add_argument('vanilla_build', type=int, help='Current version of the vanilla game')
    parser_gen.add_argument('mod_revision', type=int, help='Current revision of your mod')
    parser_gen.add_argument('beta_revision', nargs='?', default=0, type=int, help='Current beta version of your mod')

    # Create parser for init command
    subparsers.add_parser("init", help='Initialize database')

    # Create parser for update command
    parser_update = subparsers.add_parser("update", help='update help')
    parser_update.add_argument('update_version', type=int, help='The mod version to update')

    args = parser.parse_args()

    if args.command:
        sub_parser_callbacks[args.command](config, ns2_install_path, args)
    elif args:
        parser.print_usage()

if __name__ == "__main__":
    main()
