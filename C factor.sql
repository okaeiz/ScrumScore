-- MAKE SURE YOU HAVE REPORTED YOUR DAILY SCRUM MEETINGS BEFORE TRYING TO RUN THIS QUERY!
CREATE OR REPLACE FUNCTION fetch_c_value(pid INT)
RETURNS FLOAT AS $$
DECLARE
    avg_score FLOAT;
BEGIN

WITH date_series AS (
    -- Generating a series of dates for each milestone
    SELECT m.id AS milestone_id,
           generate_series(
               date_trunc('day', m.estimated_start)::date,
               date_trunc('day', m.estimated_finish)::date,
               '1 day'::interval
           ) AS date
    FROM milestones_milestone m
    WHERE m.project_id = pid
    AND (m.id) = (
        SELECT "id"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = pid
        ORDER BY "estimated_finish" DESC
        LIMIT 1
    )
),

scored_dates AS (
    -- Assigning scores based on meetings
    SELECT ds.milestone_id,
           ds.date,
           CASE WHEN sm.meeting_date IS NOT NULL THEN 1 ELSE 0 END AS score
    FROM date_series ds
    LEFT JOIN scrum_meetings sm ON ds.date = sm.meeting_date AND sm.project = pid
)

-- Calculating the average score for each milestone
SELECT AVG(score)
INTO avg_score
FROM scored_dates
GROUP BY milestone_id
ORDER BY milestone_id;

RETURN avg_score;

END;
$$ LANGUAGE plpgsql;
