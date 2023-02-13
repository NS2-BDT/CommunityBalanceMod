import argparse
from docugen import generator, database, file_scanner, verbose

def gen_changelogs(args):
    generator.generate_change_logs(args)
    print("Changelogs generated successfully")

def init_table(args):
    database.initialize_tables(args)
    print("Tables created successfully")

def update_database(args):
    conn, c = database.connect_to_database()
    file_scanner.scan_for_docugen_files(
        conn, c, args.update_version,
        local_src_path=args.local_src_path,
        vanilla_src_path=args.vanilla_src_path,
        local_balance_filepath=args.local_balance_filepath,
        vanilla_balance_filepath=args.vanilla_balance_filepath,
        vanilla_balance_health_filepath=args.vanilla_balance_health_filepath,
        vanilla_balance_misc_filepath=args.vanilla_balance_misc_filepath
    )
    print("Database updated successfully")

def main():
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
    parser_gen.add_argument('local_src_path', type=str, help='Filepath to the local src directory')
    parser_gen.add_argument('vanilla_src_path', type=str, help='Filepath to the vanilla src directory')
    parser_gen.add_argument('local_balance_filepath', type=str, help='Filepath to the local Balance.lua file')
    parser_gen.add_argument('vanilla_balance_filepath', type=str, help='Filepath to the vanilla Balance.lua file')
    parser_gen.add_argument('vanilla_balance_health_filepath', type=str, help='Filepath to the vanilla BalanceHealth.lua file')
    parser_gen.add_argument('vanilla_balance_misc_filepath', type=str, help='Filepath to the vanilla BalanceMisc.lua file')
    parser_gen.add_argument('vanilla_version', type=int, help='Current version of the vanilla game')
    parser_gen.add_argument('mod_version', type=int, help='Current revision of your mod')
    parser_gen.add_argument('beta_version', nargs='?', default=0, type=int, help='Current beta version of your mod')

    # Create parser for init command
    subparsers.add_parser("init", help='Initialize database')

    # Create parser for update command
    parser_update = subparsers.add_parser("update", help='update help')
    parser_update.add_argument('local_src_path', type=str, help='Filepath to the local src directory')
    parser_update.add_argument('vanilla_src_path', type=str, help='Filepath to the vanilla src directory')
    parser_update.add_argument('local_balance_filepath', type=str, help='Filepath to the local Balance.lua file')
    parser_update.add_argument('vanilla_balance_filepath', type=str, help='Filepath to the vanilla Balance.lua file')
    parser_update.add_argument('vanilla_balance_health_filepath', type=str, help='Filepath to the vanilla BalanceHealth.lua file')
    parser_update.add_argument('vanilla_balance_misc_filepath', type=str, help='Filepath to the vanilla BalanceMisc.lua file')
    parser_update.add_argument('update_version', type=int, help='The mod version to update')

    args = parser.parse_args()

    if args.command:
        verbose.set_verbose(args.verbose)
        sub_parser_callbacks[args.command](args)
    elif args:
        parser.print_usage()

if __name__ == "__main__":
    main()
