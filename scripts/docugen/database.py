import sqlite3

def connect_to_database():
    conn = sqlite3.connect('docugen.db')
    c = conn.cursor()
    
    return conn, c

def initialize_tables(args):
    conn, c = connect_to_database()

    # First drop
    c.execute('DROP TABLE IF EXISTS FullChangelog')
    c.execute('DROP TABLE IF EXISTS BetaChangelog')

    # Create tables
    c.execute('CREATE TABLE FullChangelog(modVersion int not null, key varchar2(100), value varchar2(100))')
    c.execute('CREATE TABLE BetaChangelog(modVersion int not null, betaVersion int not null, key varchar2(100), value varchar2(100))')
