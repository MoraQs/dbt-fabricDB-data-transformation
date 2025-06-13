import os
import pyodbc
from dotenv import load_dotenv

load_dotenv()

# CONFIGURATION

FABRIC_SERVER = os.getenv("FABRIC_SERVER")
FABRIC_DATABASE = os.getenv("FABRIC_DATABASE")
FABRIC_SCHEMA = os.getenv("FABRIC_SCHEMA")

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
STAGING_DIR = os.path.join(SCRIPT_DIR, "models", "staging")
SOURCE_NAME = FABRIC_SCHEMA

# Ensure staging folder exists
os.makedirs(STAGING_DIR, exist_ok=True)

# Connect to Fabric (ODBC Driver 17 required)
conn_str = (
    f"Driver={{ODBC Driver 17 for SQL Server}};"
    f"Server={FABRIC_SERVER};"
    f"Database={FABRIC_DATABASE};"
    f"Authentication=ActiveDirectoryInteractive;"
    f"Encrypt=yes;"
    f"TrustServerCertificate=no;"
)

conn = pyodbc.connect(conn_str)
cursor = conn.cursor()

# Get all table names in the schema
print(f"🔍 Running for schema: {FABRIC_SCHEMA}")

cursor.execute(f"""
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = ? AND table_type = 'BASE TABLE';
""", FABRIC_SCHEMA)

tables = cursor.fetchall()

print(f"📋 Found {len(tables)} tables in schema '{FABRIC_SCHEMA}'")

# Generate .sql file for each table
for (table_name,) in tables:
    filename = f"stg_{table_name.lower()}.sql"
    file_path = os.path.join(STAGING_DIR, filename)

    with open(file_path, "w") as f:
        f.write(f"-- Auto-generated DBT model for {table_name}\n")
        f.write("{{ config(materialized='view') }}\n\n")
        f.write(f"SELECT * FROM {SOURCE_NAME}.{table_name}\n")

print(f"✅ Created {len(tables)} model files in {STAGING_DIR}")

cursor.close()
conn.close()
