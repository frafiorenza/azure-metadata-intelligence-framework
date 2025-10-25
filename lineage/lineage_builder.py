"""
lineage_builder.py
Azure Metadata Intelligence Framework – Lineage Engine v1
Author: Francesco Fiorenza
"""

import pyodbc
import os

# ============================================================
# CONFIGURAZIONE CONNESSIONE
# ============================================================
# Inserisci i valori del tuo Azure SQL (puoi creare variabili d'ambiente)
SQL_SERVER   = os.getenv("SQL_SERVER",   "<servername>.database.windows.net")
SQL_DATABASE = os.getenv("SQL_DATABASE", "<databasename>")
SQL_USERNAME = os.getenv("SQL_USERNAME", "<utente>")
SQL_PASSWORD = os.getenv("SQL_PASSWORD", "<password>")

conn_str = (
    f"Driver={{ODBC Driver 18 for SQL Server}};"
    f"Server={SQL_SERVER};Database={SQL_DATABASE};Uid={SQL_USERNAME};Pwd={SQL_PASSWORD};Encrypt=yes;"
)

# ============================================================
# FUNZIONI PRINCIPALI
# ============================================================

def connect():
    """Apre la connessione al database."""
    try:
        conn = pyodbc.connect(conn_str)
        print("✅ Connessione riuscita")
        return conn
    except Exception as e:
        print("❌ Errore di connessione:", e)
        raise

def insert_relation(conn, src_name, dst_name, rel_type, confidence=1.0, extractor='manual'):
    """
    Inserisce una relazione nella tabella metadata.md_relation
    tra due oggetti identificati dal loro qualified_name.
    """
    cursor = conn.cursor()
    cursor.execute("""
        DECLARE @src BIGINT, @dst BIGINT;
        SELECT @src = id FROM metadata.md_object WHERE qualified_name = ?;
        SELECT @dst = id FROM metadata.md_object WHERE qualified_name = ?;
        IF @src IS NOT NULL AND @dst IS NOT NULL
            INSERT INTO metadata.md_relation (src_object_id, dst_object_id, rel_type, confidence, extractor)
            VALUES (@src, @dst, ?, ?, ?);
    """, (src_name, dst_name, rel_type, confidence, extractor))
    conn.commit()
    print(f"🔗 Inserita relazione: {src_name} -> {dst_name} ({rel_type})")

def show_relations(conn):
    """Mostra le relazioni registrate."""
    cursor = conn.cursor()
    cursor.execute("""
        SELECT o1.qualified_name AS source, r.rel_type, o2.qualified_name AS target
        FROM metadata.md_relation r
        JOIN metadata.md_object o1 ON r.src_object_id = o1.id
        JOIN metadata.md_object o2 ON r.dst_object_id = o2.id
    """)
    rows = cursor.fetchall()
    print("\\n📊 LINEAGE MAP:")
    for row in rows:
        print(f"{row.source} --[{row.rel_type}]--> {row.target}")

# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    conn = connect()

    # Esempio dati fittizi (sostituisci con oggetti reali estratti)
    sample_relations = [
        ("adf.pipeline.CopySales", "sql.table.Sales_Staging", "writes_to"),
        ("sql.table.Sales_Staging", "sql.view.Sales_Report", "feeds"),
        ("sql.view.Sales_Report", "pbi.dataset.Sales", "exposes_to"),
    ]

    for src, dst, rel_type in sample_relations:
        insert_relation(conn, src, dst, rel_type)

    show_relations(conn)
    conn.close()
