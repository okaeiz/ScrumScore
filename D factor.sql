-- MAKE SURE YOU HAVE UPDATES THE USER STORY STATUSES BEFORE TRYING TO RUN THIS QUERY!
WITH Q1 AS (
    With DoneUSs AS (SELECT
    "source"."id" AS "id",
    "source"."subject" AS "subject",
    SUM("Projects Points - Points"."value") AS "sum"
FROM
    (
        WITH TaskStatusCount AS (
            SELECT
                uu."id" AS "userstory_id",
                SUM(
                    CASE
                        WHEN tt."status_id" NOT IN (24, 25) THEN 1
                        ELSE 0
                    END
                ) AS "not_139_count"
            FROM
                "public"."userstories_userstory" AS uu
                LEFT JOIN "public"."tasks_task" AS tt ON uu."id" = tt."user_story_id"
            WHERE
                uu."project_id" = 5
            GROUP BY
                uu."id"
        )
        SELECT
            uu."id",
            uu."subject",
            MAX(pus."name") AS "Projects Userstorystatus - Status__name"
        FROM
            "public"."userstories_userstory" AS uu
            LEFT JOIN "public"."tasks_task" AS tt ON uu."id" = tt."user_story_id"
            LEFT JOIN "public"."projects_userstorystatus" AS pus ON uu."status_id" = pus."id"
            INNER JOIN TaskStatusCount AS tsc ON uu."id" = tsc."userstory_id"
        WHERE
            uu."project_id" = 5
            AND pus."name" = 'تکمیل شده'
            AND tsc."not_139_count" = 0
            AND ("uu"."milestone_id") = (
                SELECT
                    "id"
                FROM
                    "public"."milestones_milestone"
                WHERE
                    "public"."milestones_milestone"."project_id" = 5
                ORDER BY
                    "estimated_finish" DESC
                LIMIT
                    1
            )
        GROUP BY
            uu."id",
            uu."subject"
        LIMIT
            1048575
    ) AS "source"
    LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints" ON "source"."id" = "Userstories Rolepoints"."user_story_id"
    LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id"
GROUP BY
    "source"."id",
    "source"."subject"
ORDER BY
    "source"."id" ASC,
    "source"."subject" ASC)

SELECT 
    CASE 
            WHEN SUM(DoneUSs.sum) IS NULL THEN 0
            ELSE SUM(DoneUSs.sum) 
        END AS "sum"
        FROM DoneUSs
),


Q2 AS (SELECT SUM("SPs"."sum") AS "total_SPs" FROM (SELECT "public"."userstories_userstory"."subject" AS "subject",
    SUM("Projects Points - Points"."value") AS "sum"
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
ORDER BY "public"."userstories_userstory"."subject" ASC) AS "SPs")

SELECT Q1."sum"/Q2."total_SPs"
        FROM Q1, Q2
