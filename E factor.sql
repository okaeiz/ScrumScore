--MAKE SURE YOU HAVE UPDATED THE USER STORY STATUSES BEFORE TRYING TO RUN THIS QUERY!
CREATE 
OR REPLACE FUNCTION fetch_E_value(p_project_id INT) RETURNS FLOAT AS $$ DECLARE count_project_done_SPs INT;
BEGIN 
SELECT 
  COUNT(*) INTO count_project_done_SPs 
FROM 
  (
    SELECT 
      "public"."userstories_userstory"."subject" AS "subject", 
      SUM(
        "Projects Points - Points"."value"
      ) AS "sum" 
    FROM 
      "public"."userstories_userstory" 
      LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints" ON "public"."userstories_userstory"."id" = "Userstories Rolepoints"."user_story_id" 
      LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id" 
    WHERE 
      "public"."userstories_userstory"."is_closed" = TRUE 
      AND (
        "public"."userstories_userstory"."milestone_id"
      ) = (
        SELECT 
          "id" 
        FROM 
          "public"."milestones_milestone" 
        WHERE 
          "public"."milestones_milestone"."project_id" = p_project_id 
        ORDER BY 
          "estimated_finish" DESC 
        LIMIT 
          1
      ) 
    GROUP BY 
      "public"."userstories_userstory"."subject" 
    ORDER BY 
      "public"."userstories_userstory"."subject" ASC
  ) AS project_done_SPs;
IF count_project_done_SPs = 0 THEN RETURN 0;
ELSE RETURN (
  WITH project_done_SPs AS (
    SELECT 
      "public"."userstories_userstory"."subject" AS "subject", 
      SUM(
        "Projects Points - Points"."value"
      ) AS "sum" 
    FROM 
      "public"."userstories_userstory" 
      LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints" ON "public"."userstories_userstory"."id" = "Userstories Rolepoints"."user_story_id" 
      LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id" 
    WHERE 
      "public"."userstories_userstory"."is_closed" = TRUE 
      AND (
        "public"."userstories_userstory"."milestone_id"
      ) = (
        SELECT 
          "id" 
        FROM 
          "public"."milestones_milestone" 
        WHERE 
          "public"."milestones_milestone"."project_id" = p_project_id 
        ORDER BY 
          "estimated_finish" DESC 
        LIMIT 
          1
      ) 
    GROUP BY 
      "public"."userstories_userstory"."subject" 
    ORDER BY 
      "public"."userstories_userstory"."subject" ASC
  ), 
  total_done_SPs AS (
    WITH latest_milestones AS (
      SELECT 
        "id" 
      FROM 
        "public"."milestones_milestone" 
      WHERE 
        "project_id" IN (
          28, 32, 29, 40, 37, 31, 34, 9, 30, 35, 43, 
          5, 39, 50
        ) 
      ORDER BY 
        "project_id", 
        "estimated_finish" DESC
    ) 
    SELECT 
      "public"."userstories_userstory"."subject" AS "subject", 
      SUM(
        "Projects Points - Points"."value"
      ) AS "total_sum" 
    FROM 
      "public"."userstories_userstory" 
      LEFT JOIN "public"."userstories_rolepoints" ON "public"."userstories_userstory"."id" = "public"."userstories_rolepoints"."user_story_id" 
      LEFT JOIN "public"."projects_points" AS "Projects Points - Points" ON "public"."userstories_rolepoints"."points_id" = "Projects Points - Points"."id" 
    WHERE 
      "public"."userstories_userstory"."is_closed" = TRUE 
      AND "public"."userstories_userstory"."milestone_id" IN (
        SELECT 
          "id" 
        FROM 
          latest_milestones
      ) 
    GROUP BY 
      "public"."userstories_userstory"."subject" 
    ORDER BY 
      "public"."userstories_userstory"."subject" ASC
  ),
  tsp AS (SELECT SUM("sum")::float AS "sum" FROM project_done_SPs),
  psp AS (SELECT SUM("total_sum")::float AS "total_sum" FROM total_done_SPs)
  SELECT 
    "sum" / "total_sum" 
  FROM 
    psp 
    CROSS JOIN tsp
);
END IF;
RETURN 0;
-- This line is a fallback in case of unexpected flow.
-- Ideally, we should never hit this, but it''s required for the function to always return a value.
END;
$$ LANGUAGE plpgsql;
