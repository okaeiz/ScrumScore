create function public.fetch_d_value(pid integer) returns double precision
    language plpgsql
as
$$
DECLARE
    result_value FLOAT;
    total_SPs FLOAT;
BEGIN

    WITH Q1 AS (
SELECT
        us."subject" AS "subject",
        CASE
            WHEN SUM((cav."attributes_values"#>> array[(SELECT task_done_id FROM scrum_projects WHERE ref = us."project_id")::text]::text[])::double precision) > sp."sum1" THEN sp."sum1"
            ELSE SUM((cav."attributes_values"#>> array[(SELECT task_done_id FROM scrum_projects WHERE ref = us."project_id")::text]::text[])::double precision)
        END AS "sum"
    FROM
        "public"."tasks_task"
    LEFT JOIN
        "public"."userstories_userstory" AS us ON "public"."tasks_task"."user_story_id" = us."id"
    LEFT JOIN
        "public"."custom_attributes_taskcustomattributesvalues" AS cav ON "public"."tasks_task"."id" = cav."task_id"
    LEFT JOIN
        (
            SELECT
                "public"."userstories_userstory"."id" AS us_id,
                SUM("projects_points"."value") AS "sum1"
            FROM
                "public"."userstories_userstory"
            LEFT JOIN
                "public"."userstories_rolepoints" ON "public"."userstories_userstory"."id" = "userstories_rolepoints"."user_story_id"
            LEFT JOIN
                "public"."projects_points" ON "userstories_rolepoints"."points_id" = "projects_points"."id"
            WHERE
                "public"."userstories_userstory"."project_id" = pid
            GROUP BY
                "public"."userstories_userstory"."id"
        ) AS sp ON us."id" = sp.us_id
WHERE us."project_id" = pid
    AND us."is_closed" = TRUE
    AND us."status_id" = (SELECT us_done_id FROM scrum_projects WHERE ref = pid)
    AND "public"."tasks_task"."status_id" IN
        (SELECT task_status_done_id
        FROM scrum_projects
        WHERE ref = pid)
    AND us."milestone_id" = (
SELECT milestones_milestone.id
                     FROM milestones_milestone
                     WHERE milestones_milestone.project_id = pid
                     AND now()::date >= milestones_milestone.estimated_start
                     AND now()::date <= milestones_milestone.estimated_finish
                     ORDER BY milestones_milestone.estimated_finish DESC
                     LIMIT 1
    )
GROUP BY
        us."subject", sp."sum1"    )
    SELECT SUM("sum") INTO result_value FROM Q1;

    WITH Q2 AS (
SELECT SUM("SPs"."sum") AS "total_SPs"
                FROM (SELECT "userstories_userstory"."subject"       AS "subject",
                             SUM("Projects Points - Points"."value") AS "sum"
                      FROM "public"."userstories_userstory"
                               LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints"
                                         ON "userstories_userstory"."id" = "Userstories Rolepoints"."user_story_id"
                               LEFT JOIN "public"."projects_points" AS "Projects Points - Points"
                                         ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id"
                      WHERE "userstories_userstory"."project_id" = pid
                        AND "userstories_userstory"."milestone_id" = (SELECT milestones_milestone.id
                     FROM milestones_milestone
                     WHERE milestones_milestone.project_id = pid
                       AND now()::date >= milestones_milestone.estimated_start
                       AND now()::date <= milestones_milestone.estimated_finish                     ORDER BY milestones_milestone.estimated_finish DESC
                     LIMIT 1)
                      GROUP BY "userstories_userstory"."subject") AS "SPs"    )
    SELECT "total_SPs" INTO total_SPs FROM Q2;

    IF total_SPs IS NULL OR result_value IS NULL THEN
        result_value := 0;
    ELSE
        result_value := result_value / total_SPs;
    END IF;

    RETURN result_value;

END;
$$;

alter function public.fetch_d_value(integer) owner to taiga_u;

