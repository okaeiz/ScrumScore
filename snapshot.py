import psycopg2
from termcolor import colored
import logging
import json


# Custom logging handler
class ColorizingStreamHandler(logging.StreamHandler):
    colors = {
        'INFO': 'green',
        'ERROR': 'red',
    }

    def emit(self, record):
        try:
            message = self.format(record)
            color = self.colors.get(record.levelname, 'white')
            colored_message = colored(message, color)
            print(colored_message)
        except Exception:
            self.handleError(record)

# Initialize logging
logging.basicConfig(level=logging.INFO, handlers=[ColorizingStreamHandler()])

# Database connection parameters - Modify accordingly
def connect_to_db():
    try:
        conn = psycopg2.connect(
            host="192.168.0.5",
            port='5432',
            database="taiga_db",
            user="taiga_u",
            password="sfDe53fSdf"
        )
        logging.info("Successfully connected to the database.")
        return conn
    except Exception as e:
        logging.error(f"Failed to connect to the database: {e}")
        return None

def ss_projects(conn):
    table_name = 'snapshot_projects'
    cursor = conn.cursor()
    try:
        data_cols = ['project_id', 'milestone_id', 'a_value', 'b_value', 'c_value', 'd_value', 'e_value', 'r2_value', 'e2_value', 'r22_value']
        placeholders = ', '.join(['%s'] * len(data_cols))
        columns = ', '.join(data_cols)

        # Fetch data using query1
        query1 = f"SELECT {columns} FROM online_factors"
        cursor.execute(query1)
        fetched_data = cursor.fetchall()

        # Insert data using query2
        query2 = f"INSERT INTO snapshot_projects ({columns}) VALUES ({placeholders})"
        cursor.executemany(query2, fetched_data)
        conn.commit()

        logging.info(f"Successfully inserted data into {table_name}.")
    except Exception as e:
        logging.error(f"Failed to insert data into {table_name}: {e}")
    finally:
        cursor.close()

def ss_epics(conn):
    table_name = 'snapshot_epics'
    cursor = conn.cursor()
    try:
        data_cols = ['project_id', 'epic_id', 'epic_status', 'date_modified']
        placeholders = ', '.join(['%s'] * len(data_cols))
        columns = ', '.join(data_cols)

        # Fetch data using query1
        query1 = f"SELECT project_id, id, status_id, modified_date FROM epics_epic"
        cursor.execute(query1)
        fetched_data = cursor.fetchall()
        # Insert data using query2
        query2 = f"INSERT INTO snapshot_epics ({columns}) VALUES ({placeholders})"
        cursor.executemany(query2, fetched_data)
        conn.commit()

        logging.info(f"Successfully inserted data into {table_name}.")
    except Exception as e:
        logging.error(f"Failed to insert data into {table_name}: {e}")
    finally:
        cursor.close()

def ss_userstories(conn):
    table_name = 'snapshot_userstories'
    cursor = conn.cursor()
    try:
        data_cols = ['userstory_id', 'project_id', 'status', 'storypoints', 'modified_date', 'done_date']
        placeholders = ', '.join(['%s'] * len(data_cols))
        columns = ', '.join(data_cols)

        # Fetch data using query1
        query1 = """
                    SELECT "public"."userstories_userstory"."id",
                        "public"."userstories_userstory"."project_id",
                        "public"."userstories_userstory"."status_id",
                        SUM("Projects Points - Points"."value") AS "sum",
                        "public"."userstories_userstory"."modified_date",
                        "public"."userstories_userstory"."finish_date"
                    FROM "public"."userstories_userstory"
                    LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints" ON "public"."userstories_userstory"."id" = "Userstories Rolepoints"."user_story_id"
                    LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id"
                    GROUP BY "public"."userstories_userstory"."id"
                    ORDER BY "public"."userstories_userstory"."id" ASC
                """
        cursor.execute(query1)
        fetched_data = cursor.fetchall()
        # Insert data using query2
        query2 = f"INSERT INTO snapshot_userstories ({columns}) VALUES ({placeholders})"
        cursor.executemany(query2, fetched_data)
        conn.commit()

        logging.info(f"Successfully inserted data into {table_name}.")
    except Exception as e:
        logging.error(f"Failed to insert data into {table_name}: {e}")
    finally:
        cursor.close()

def ss_tasks(conn):
    table_name = 'snapshot_tasks'
    cursor = conn.cursor()
    try:
        data_cols = ['task_id', 'project_id', 'task_status', 'taskpoint', 'done_date', 'modified_date']
        placeholders = ', '.join(['%s'] * len(data_cols))
        columns = ', '.join(data_cols)

        # Fetch data using query1
        query1 = """
                    SELECT
                        "public"."tasks_task"."id" AS "id",
                        "public"."tasks_task"."project_id" AS "project_id",
                        "public"."tasks_task"."status_id" AS "status_id",
                        "Custom Attributes Taskcustomattributesvalues"."attributes_values" AS "Custom Attributes Taskcustomattributesvalues__attri_d35e3492",
                        "public"."tasks_task"."finished_date" AS "finished_date",
                        "public"."tasks_task"."modified_date" AS "modified_date"
                    FROM
                        "public"."tasks_task"
                        LEFT JOIN "public"."custom_attributes_taskcustomattributesvalues" AS "Custom Attributes Taskcustomattributesvalues" ON "public"."tasks_task"."id" = "Custom Attributes Taskcustomattributesvalues"."task_id"
                    LIMIT
                        1048575
                """
        cursor.execute(query1)
        fetched_data = cursor.fetchall()

        # Serialize the jsonb data to a string
        serialized_data = [(task_id, project_id, task_status, json.dumps(taskpoint), done_date, modified_date) for task_id, project_id, task_status, taskpoint, done_date, modified_date in fetched_data]

        # Insert data using query2
        query2 = f"INSERT INTO snapshot_tasks ({columns}) VALUES ({placeholders})"
        cursor.executemany(query2, serialized_data)
        conn.commit()

        logging.info(f"Successfully inserted data into {table_name}.")
    except Exception as e:
        logging.error(f"Failed to insert data into {table_name}: {e}")
    finally:
        cursor.close()



if __name__ == "__main__":
    conn = connect_to_db()
    if conn:
        ss_projects(conn)
        ss_epics(conn)
        ss_userstories(conn)
        ss_tasks(conn)
        conn.close()
