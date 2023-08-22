CREATE OR REPLACE VIEW online_scores AS
WITH CTE AS (SELECT
    sp.ref AS project_id,
    (SELECT "id"
        FROM "public"."milestones_milestone"
        WHERE "public"."milestones_milestone"."project_id" = sp.ref
        ORDER BY "estimated_finish" DESC
        LIMIT 1
    ) AS milestone_id,
    COALESCE(fetch_a_value(sp.ref), 0) AS a_value, -- Assuming you're getting a_value from a function
    COALESCE(fetch_b_value(sp.ref, sp.task_done_id), 0) AS b_value, -- Assuming you're getting a_value from a function
    COALESCE(fetch_c_value(sp.ref), 0) AS c_value, -- Assuming c_value is a column in scrum_projects
    COALESCE(fetch_d_value(sp.ref), 0) AS d_value, -- Assuming d_value is a column in scrum_projects
    COALESCE(fetch_e_value(sp.ref), 0) AS e_value, -- Assuming e_value is a column in scrum_projects
    COALESCE( fetch_r2_value(sp.ref), 0) AS r2_value -- Assuming r2_value is a column in scrum_projects

FROM
    scrum_projects sp)

SELECT project_id,
       milestone_id,
       a_value,
       b_value,
       c_value,
       d_value,
       e_value,
       r2_value,
       (a_value*((0.2*c_value)+(0.2*b_value)+(0.6*d_value))*r2_value) AS final_score,
       (a_value*((0.2*c_value)+(0.2*b_value)+(0.6*d_value))*(1+e_value)) AS methode_2
FROM CTE;

