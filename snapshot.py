import psycopg2
from termcolor import cprint, colored
import logging

# Initialize logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Database connection parameters - Modify accordingly
def connect_to_db():
    try:
        conn = psycopg2.connect(
            host="192.168.0.5",
            port = '5432',
            database="taiga_db",
            user="taiga_u",
            password="sfDe53fSdf"
        )
        logging.info("Successfully connected to the database.")
        return conn
    except Exception as e:
        logging.error(f"Failed to connect to the database: {e}")
        return None

# Queries
queries = {

    'A_value': """
SELECT * FROM users_user
    """
}

def ss_projects(conn):
    table_name = 'snapshot_projects' 
    cursor = conn.cursor()
    try:
        data_cols = ['project_id',
                'milestone_id',
                'a_value',
                'b_value',
                'c_value',
                'd_value',
                'e_value',
                'r2_value',
                'e2_value',
                'r22_value',]
        placeholders = ', '.join(['%s'] * len(data_cols))
        columns = ', '.join(data_cols)
        sql = f"INSERT INTO snapshot_projects ({columns}) VALUES ({placeholders})"
        cursor.execute(sql)
        conn.commit()
        logging.info(f"Successfully inserted data into {table_name}.")
    except Exception as e:
        err = colored(f"Failed to insert data into {table_name}: {e}", 'red')
        logging.error(err)
    finally:
        cursor.close()

if __name__ == "__main__":
    conn = connect_to_db()
    if conn:
        ss_projects(conn, 'snapshot_projects')

        # Close the cursor and the connection
        conn.close()






