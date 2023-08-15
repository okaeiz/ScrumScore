-- MAKE SURE YOU HAVE ENTERED THE USERS' COMMITMENT BEFORE TRYING TO RUN THIS QUERY!
--Calculating the ratio
SELECT
    (
        "storypoints"."total_SPs" / "commitment"."expected_storypoints"
    )
FROM
    --team commitment
    (
        SELECT
            "public"."users_commitment"."expected_storypoints" AS "expected_storypoints"
        FROM
            "public"."users_commitment"
            LEFT JOIN "public"."scrum_projects" AS "Scrum Projects - Project" ON "public"."users_commitment"."project" = "Scrum Projects - Project"."ref"
        WHERE
            "Scrum Projects - Project"."ref" = 5
            AND ("date_of_entry") >= (
                SELECT
                    "estimated_start"
                FROM
                    "public"."milestones_milestone"
                WHERE
                    "public"."milestones_milestone"."project_id" = 5
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
                    "public"."milestones_milestone"."project_id" = 5
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
    --team planned SPs
    (
        --previous milestone id
        WITH PreviousMilestone AS (
            SELECT
                "id"
            FROM
                "public"."milestones_milestone"
            WHERE
                "project_id" = 5
            ORDER BY
                "estimated_finish" DESC OFFSET 1
            LIMIT
                1
        ), --total SPs
        SPs AS (
            SELECT
                "userstories_userstory"."id" AS userstory_id,
                SUM("Projects Points - Points"."value") AS sum
            FROM
                "public"."userstories_userstory"
                LEFT JOIN "public"."userstories_rolepoints" AS "Userstories_Rolepoints" ON "userstories_userstory"."id" = "Userstories_Rolepoints"."user_story_id"
                LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "Userstories_Rolepoints"."points_id" = "Projects Points - Points"."id"
            WHERE
                "userstories_userstory"."project_id" = 5
                AND "userstories_userstory"."milestone_id" IN (
                    SELECT
                        "id"
                    FROM
                        "public"."milestones_milestone"
                    WHERE
                        "project_id" = 5
                    ORDER BY
                        "estimated_finish" DESC
                    LIMIT
                        1
                )
            GROUP BY
                "userstories_userstory"."id"
        ),
        --SPs that are done (subtract this value from the total_SPs if needed)
        to_subtract AS (
            SELECT
                milestone_id,
                removed_sps
            FROM
                milestones_refinement
            WHERE
                milestone_id = (
                    SELECT
                        id
                    FROM
                        PreviousMilestone
                )
        )
        SELECT
            SUM(SPs.sum) AS "total_SPs"
        FROM
            SPs,
            to_subtract
    ) AS "storypoints"