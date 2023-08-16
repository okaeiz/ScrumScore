--THIS QUERY CALCULATES THE TASK POINTS OF THE TASKS THAT ARE MODIFIED WITHIN THE CURRENT SPRINT!
SELECT AVG("source"."ratio") AS "avg"
FROM (WITH
Query1 AS (
    SELECT "public"."userstories_userstory"."subject" AS "subject",
           SUM("Projects Points - Points"."value") AS "sum1"
    FROM "public"."userstories_userstory"
   
LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints" ON "public"."userstories_userstory"."id" = "Userstories Rolepoints"."user_story_id"
    LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id"
   
WHERE "public"."userstories_userstory"."project_id" = 5
   
   AND ("public"."userstories_userstory"."milestone_id") = (
        SELECT "id"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = 5
       
ORDER BY "estimated_finish" DESC
       
LIMIT 1
    )
   
GROUP BY "public"."userstories_userstory"."subject"
),
Query2 AS (
    SELECT "Userstories Userstory - User Story"."subject" AS "subject",
           SUM(("Custom Attributes Taskcustomattributesvalues"."attributes_values"#>> array['2']::text[])::double precision) AS "sum2"
    FROM "public"."tasks_task"
    LEFT JOIN "public"."userstories_userstory" AS "Userstories Userstory - User Story" ON "public"."tasks_task"."user_story_id" = "Userstories Userstory - User Story"."id"
    LEFT JOIN "public"."custom_attributes_taskcustomattributesvalues" AS "Custom Attributes Taskcustomattributesvalues" ON "public"."tasks_task"."id" = "Custom Attributes Taskcustomattributesvalues"."task_id"
    LEFT JOIN "public"."milestones_milestone" AS "Milestones Milestone - Milestone" ON "public"."tasks_task"."milestone_id" = "Milestones Milestone - Milestone"."id"
    WHERE "Userstories Userstory - User Story"."project_id" = 5
    AND ("public"."tasks_task"."modified_date") > (
        SELECT "estimated_start"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = 5
        ORDER BY "estimated_finish" DESC
        LIMIT 1
    )
    AND ("public"."tasks_task"."modified_date") <= (
        SELECT "estimated_finish"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = 5
        ORDER BY "estimated_finish" DESC
        LIMIT 1
    )
    AND ("Userstories Userstory - User Story"."milestone_id") = (
        SELECT "id"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = 5
        ORDER BY "estimated_finish" DESC
        LIMIT 1
    )
    GROUP BY "Userstories Userstory - User Story"."subject"
)
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
ORDER BY Q1."subject" ASC) AS "source"