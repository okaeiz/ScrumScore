-- MAKE SURE YOU HAVE ENTERED THE USERS' COMMITMENT BEFORE TRYING TO RUN THIS QUERY!
CREATE OR REPLACE FUNCTION fetch_a_value(pid INT)
RETURNS FLOAT AS $$
DECLARE
    ratio FLOAT;
BEGIN


-- Calculating the ratio
SELECT
    CASE
        WHEN "storypoints"."total_SPs" = 0 OR "commitment"."expected_storypoints" = 0 THEN 0
        ELSE ("storypoints"."total_SPs" / "commitment"."expected_storypoints")
    END AS "res"
INTO ratio
FROM
    -- team commitment
    (
        SELECT
            CASE 
                WHEN "public"."users_commitment"."expected_storypoints" IS NULL THEN 0
                ELSE "public"."users_commitment"."expected_storypoints"
            END AS "expected_storypoints"
        FROM
            "public"."users_commitment"
            LEFT JOIN "public"."scrum_projects" AS "Scrum Projects - Project" ON "public"."users_commitment"."project" = "Scrum Projects - Project"."ref"
        WHERE
            "Scrum Projects - Project"."ref" = pid
            AND ("date_of_entry") >= (
                SELECT
                    "estimated_start"
                FROM
                    "public"."milestones_milestone"
                WHERE
                    "public"."milestones_milestone"."project_id" = pid
                ORDER BY
                    "estimated_finish" DESC
                LIMIT
                    1
            )
            AND ("date_of_entry") < (
                SELECT
                    "estimated_finish"
                FROM
                    "public"."milestones_milestone"
                WHERE
                    "public"."milestones_milestone"."project_id" = pid
                ORDER BY
                    "estimated_finish" DESC
                LIMIT
                    1
            )
        ORDER BY
            "date_of_entry" DESC
        LIMIT
            1
    ) AS "commitment",
    -- team planned SPs
    (
        -- previous milestone id
        WITH PreviousMilestone AS (
            SELECT
                "id"
            FROM
                "public"."milestones_milestone"
            WHERE
                "project_id" = pid
            ORDER BY
                "estimated_finish" DESC OFFSET 1
            LIMIT
                1
        ),
        -- total SPs
        SPs AS (
            SELECT
                "userstories_userstory"."id" AS userstory_id,
                SUM("Projects Points - Points"."value") AS sum
            FROM
                "public"."userstories_userstory"
                LEFT JOIN "public"."userstories_rolepoints" AS "Userstories_Rolepoints" ON "userstories_userstory"."id" = "Userstories_Rolepoints"."user_story_id"
                LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "Userstories_Rolepoints"."points_id" = "Projects Points - Points"."id"
            WHERE
                "userstories_userstory"."project_id" = pid
                AND "userstories_userstory"."milestone_id" IN (
                    SELECT
                        "id"
                    FROM
                        "public"."milestones_milestone"
                    WHERE
                        "project_id" = pid
                    ORDER BY
                        "estimated_finish" DESC
                    LIMIT
                        1
                )
            GROUP BY
                "userstories_userstory"."id"
        ),

        SELECT
            CASE
                WHEN SUM(SPs.sum) IS NULL THEN 0
                ELSE SUM(SPs.sum)
            END AS "total_SPs"
        FROM
            SPs,
    ) AS "storypoints";

RETURN ratio;

END;
$$ LANGUAGE plpgsql;

