--MAKE SURE YOU HAVE UPDATED THE USER STORY STATUSES BEFORE TRYING TO RUN THIS QUERY!
CREATE OR REPLACE FUNCTION fetch_r2_value(p_project_id INT) RETURNS FLOAT AS $$
DECLARE
    count_project_done_SPs INT;
BEGIN
    SELECT COUNT(*)
    INTO count_project_done_SPs
    FROM (SELECT "public"."userstories_userstory"."subject" AS "subject",
SUM("Projects Points - Points"."value") AS "sum"
FROM "public"."userstories_userstory"
LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints" ON "public"."userstories_userstory"."id" = "Userstories Rolepoints"."user_story_id"
LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id"
WHERE "public"."userstories_userstory"."is_closed" = TRUE
AND ("public"."userstories_userstory"."milestone_id") = (
    SELECT "id"
    FROM "public"."milestones_milestone"
    WHERE "public"."milestones_milestone"."project_id" = p_project_id
    ORDER BY "estimated_finish" DESC
    LIMIT 1
)
GROUP BY "public"."userstories_userstory"."subject"
ORDER BY "public"."userstories_userstory"."subject" ASC) AS project_done_SPs;

    IF count_project_done_SPs = 0 THEN
        RAISE EXCEPTION 'The selected team has not completed any user stories in the current milestone!';
    ELSE
        RETURN (
            WITH project_done_SPs AS (SELECT "public"."userstories_userstory"."subject" AS "subject",
SUM("Projects Points - Points"."value") AS "sum"
FROM "public"."userstories_userstory"
LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints" ON "public"."userstories_userstory"."id" = "Userstories Rolepoints"."user_story_id"
LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id"
WHERE "public"."userstories_userstory"."is_closed" = TRUE
AND ("public"."userstories_userstory"."milestone_id") = (
    SELECT "id"
    FROM "public"."milestones_milestone"
    WHERE "public"."milestones_milestone"."project_id" = p_project_id
    ORDER BY "estimated_finish" DESC
    LIMIT 1
)
GROUP BY "public"."userstories_userstory"."subject"
ORDER BY "public"."userstories_userstory"."subject" ASC),

            total_done_SPs AS (WITH latest_milestones AS (
    SELECT "id"
    FROM "public"."milestones_milestone"
    WHERE "project_id" IN (28, 32, 29, 40, 37, 31, 34, 9, 30, 35, 43, 5, 39, 50)
    ORDER BY "project_id", "estimated_finish" DESC
)

SELECT
    "public"."userstories_userstory"."subject" AS "subject",
    SUM("Projects Points - Points"."value") AS "total_sum"
FROM
    "public"."userstories_userstory"
    LEFT JOIN "public"."userstories_rolepoints" ON "public"."userstories_userstory"."id" = "public"."userstories_rolepoints"."user_story_id"
    LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "public"."userstories_rolepoints"."points_id" = "Projects Points - Points"."id"
WHERE
    "public"."userstories_userstory"."is_closed" = TRUE
    AND "public"."userstories_userstory"."milestone_id" IN (SELECT "id" FROM latest_milestones)
GROUP BY "public"."userstories_userstory"."subject"
ORDER BY
    "public"."userstories_userstory"."subject" ASC),
    project_members_count AS (SELECT COUNT(*) AS "team_count"
FROM "public"."projects_membership"
LEFT JOIN "public"."users_user" AS "Users User - User" ON "public"."projects_membership"."user_id" = "Users User - User"."id"
WHERE "public"."projects_membership"."project_id" = p_project_id),

    organization_members_count AS (SELECT COUNT(*) AS "total_count"
FROM "public"."projects_membership"
LEFT JOIN "public"."users_user" AS "Users User - User" ON "public"."projects_membership"."user_id" = "Users User - User"."id"
WHERE ("public"."projects_membership"."project_id") IN (28, 32, 29, 40, 37, 31, 34, 9, 30, 35, 43, 5, 39, 50)
),
pre_aggregated AS (
    SELECT
        SUM(project_done_SPs."sum") as total_project_sum,
        SUM(total_done_SPs."total_sum") as total_done_sum
    FROM project_done_SPs
    RIGHT JOIN total_done_SPs ON project_done_SPs.subject = total_done_SPs.subject
)
-- other CTEs like project_members_count and organization_members_count go here...

SELECT
    (pa.total_project_sum / pmc."team_count") / (pa.total_done_sum / omc."total_count")
FROM pre_aggregated AS pa
CROSS JOIN project_members_count AS pmc
CROSS JOIN organization_members_count AS omc


        );
    END IF;

    RETURN 0; -- This line is a fallback in case of unexpected flow.
                 -- Ideally, we should never hit this, but it's required for the function to always return a value.

END;
$$ LANGUAGE plpgsql;
