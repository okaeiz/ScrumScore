-- MAKE SURE YOU HAVE UPDATES THE USER STORY STATUSES BEFORE TRYING TO RUN THIS QUERY!
CREATE OR REPLACE FUNCTION fetch_d_value(pid INT)
    RETURNS FLOAT AS
$$
DECLARE
    result_value FLOAT;
BEGIN

    WITH Q1 AS (With DoneUSs AS (SELECT "source"."id"                           AS "id",
                                        "source"."subject"                      AS "subject",
                                        SUM("Projects Points - Points"."value") AS "sum"
                                 FROM (SELECT uu."id",
                                              uu."subject"
                                       FROM "public"."userstories_userstory" AS uu
                                       WHERE uu."project_id" = pid
                                         AND uu."is_closed" = TRUE
                                         AND uu."milestone_id" = (SELECT "id"
                                                                  FROM "public"."milestones_milestone"
                                                                  WHERE "project_id" = pid
                                                                  ORDER BY "estimated_finish" DESC
                                                                  LIMIT 1)
                                       GROUP BY uu."id",
                                                uu."subject") AS "source"
                                          LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints"
                                                    ON "source"."id" = "Userstories Rolepoints"."user_story_id"
                                          LEFT JOIN "public"."projects_points" AS "Projects Points - Points"
                                                    ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id"
                                 GROUP BY "source"."id",
                                          "source"."subject"
                                 ORDER BY "source"."id" ASC,
                                          "source"."subject" ASC)

                SELECT CASE
                           WHEN SUM(DoneUSs.sum) IS NULL THEN 0
                           ELSE SUM(DoneUSs.sum)
                           END AS "sum"
                FROM DoneUSs),

         Q2 AS (SELECT SUM("SPs"."sum") AS "total_SPs"
                FROM (SELECT "userstories_userstory"."subject"       AS "subject",
                             SUM("Projects Points - Points"."value") AS "sum"
                      FROM "public"."userstories_userstory"
                               LEFT JOIN "public"."userstories_rolepoints" AS "Userstories Rolepoints"
                                         ON "userstories_userstory"."id" = "Userstories Rolepoints"."user_story_id"
                               LEFT JOIN "public"."projects_points" AS "Projects Points - Points"
                                         ON "Userstories Rolepoints"."points_id" = "Projects Points - Points"."id"
                      WHERE "userstories_userstory"."project_id" = pid
                        AND "userstories_userstory"."milestone_id" = (SELECT "id"
                                                                      FROM "public"."milestones_milestone"
                                                                      WHERE "project_id" = pid
                                                                      ORDER BY "estimated_finish" DESC
                                                                      LIMIT 1)
                      GROUP BY "userstories_userstory"."subject") AS "SPs")

    SELECT CASE
               WHEN Q2."total_SPs" IS NULL OR Q1."sum" IS NULL THEN 0
               ELSE Q1."sum" / Q2."total_SPs"
            END AS "res"

    INTO result_value
    FROM Q1,
         Q2;

    RETURN result_value;

END;
$$ LANGUAGE plpgsql;
