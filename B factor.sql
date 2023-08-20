--THIS QUERY CALCULATES THE TASK POINTS OF THE TASKS THAT ARE MODIFIED WITHIN THE CURRENT SPRINT!
CREATE OR REPLACE FUNCTION fetch_b_value(pid INT, tpid INT)
RETURNS FLOAT AS $$
DECLARE
    result_value FLOAT;
BEGIN

WITH
Query1 AS (
    SELECT "public"."userstories_userstory"."subject" AS "subject",
           SUM("projects_points"."value") AS "sum1"
    FROM "public"."userstories_userstory"
    LEFT JOIN "public"."userstories_rolepoints" ON "public"."userstories_userstory"."id" = "userstories_rolepoints"."user_story_id"
    LEFT JOIN "public"."projects_points" ON "userstories_rolepoints"."points_id" = "projects_points"."id"
    WHERE "public"."userstories_userstory"."project_id" = pid
    AND "public"."userstories_userstory"."milestone_id" = (
        SELECT "id"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = pid
        ORDER BY "estimated_finish" DESC
        LIMIT 1
    )
    GROUP BY "public"."userstories_userstory"."subject"
),
Query2 AS (
    SELECT "Userstories Userstory"."subject" AS "subject",
           SUM(("CustomAttributesValues"."attributes_values"#>> array[tpid::text]::text[])::double precision) AS "sum2"
    FROM "public"."tasks_task"
    LEFT JOIN "public"."userstories_userstory" AS "Userstories Userstory" ON "public"."tasks_task"."user_story_id" = "Userstories Userstory"."id"
    LEFT JOIN "public"."custom_attributes_taskcustomattributesvalues" AS "CustomAttributesValues" ON "public"."tasks_task"."id" = "CustomAttributesValues"."task_id"
    LEFT JOIN "public"."milestones_milestone" ON "public"."tasks_task"."milestone_id" = "public"."milestones_milestone"."id"
    WHERE "Userstories Userstory"."project_id" = pid
    AND "public"."tasks_task"."modified_date" > (
        SELECT "estimated_start"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = pid
        ORDER BY "estimated_finish" DESC
        LIMIT 1
    )
    AND "public"."tasks_task"."modified_date" <= (
        SELECT "estimated_finish"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = pid
        ORDER BY "estimated_finish" DESC
        LIMIT 1
    )
    AND "Userstories Userstory"."milestone_id" = (
        SELECT "id"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = pid
        ORDER BY "estimated_finish" DESC
        LIMIT 1
    )
    GROUP BY "Userstories Userstory"."subject"
),
ResultQuery AS (
    SELECT Q1."subject",
           Q1."sum1",
           Q2."sum2",
           CASE
               WHEN Q1."sum1" = 0 THEN NULL
               WHEN Q2."sum2" / Q1."sum1" > 1 THEN 1
               ELSE Q2."sum2" / Q1."sum1"
           END AS "ratio"
    FROM Query1 Q1
    JOIN Query2 Q2 ON Q1."subject" = Q2."subject"
)
SELECT AVG("source"."ratio")
INTO result_value
FROM ResultQuery AS "source";

RETURN result_value;

END;
$$ LANGUAGE plpgsql;
