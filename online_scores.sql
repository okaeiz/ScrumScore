create view public.online_scores
            (project_id, milestone_id, a_value, b_value, c_value, d_value, e_value, f_value, plan_value,
             review_value, retro_value, ccs1_value, ccs2_value)
as
WITH cte AS (SELECT sp.ref                                                                AS project_id,
                    (SELECT milestones_milestone.id
                     FROM milestones_milestone
                     WHERE milestones_milestone.project_id = sp.ref
                       AND now()::date >= milestones_milestone.estimated_start
                       AND now()::date <= milestones_milestone.estimated_finish
                     ORDER BY milestones_milestone.estimated_finish DESC
                     LIMIT 1)                                                             AS milestone_id,
                    COALESCE(fetch_a_value(sp.ref), 0::double precision)                  AS a_value,
                    COALESCE(fetch_b_value(sp.ref, sp.task_done_id), 0::double precision) AS b_value,
                    COALESCE(fetch_c_value(sp.ref), 0::double precision)                  AS c_value,
                    COALESCE(fetch_d_value(sp.ref), 0::double precision)                  AS d_value,
                    COALESCE(fetch_e_value(sp.ref), 0::double precision)                  AS e_value,
                    COALESCE(fetch_f_value(sp.ref, sp.task_done_id), 0::double precision) AS f_value,
                    COALESCE(((SELECT fetch_sprint_plan.is_sprintplan
                               FROM fetch_sprint_plan(sp.ref) fetch_sprint_plan(project_id, milestone_id, is_sprintplan)))::double precision,
                             0::double precision)                                         AS plan_value,
                    COALESCE(((SELECT fetch_sprint_review.is_sprintreview
                               FROM fetch_sprint_review(sp.ref) fetch_sprint_review(project_id, milestone_id, is_sprintreview)))::double precision,
                             0::double precision)                                         AS review_value,
                    COALESCE(((SELECT fetch_sprint_retro.is_sprintretro
                               FROM fetch_sprint_retro(sp.ref) fetch_sprint_retro(project_id, milestone_id, is_sprintretro)))::double precision,
                             0::double precision)                                         AS retro_value,
                    COALESCE(((SELECT fetch_ccs1.coord_counc_s1
                               FROM fetch_ccs1(sp.ref) fetch_ccs1(project_id, milestone_id, coord_counc_s1)))::double precision,
                             0::double precision)                                         AS ccs1_value,
                    COALESCE(((SELECT fetch_ccs2.coord_counc_s2
                               FROM fetch_ccs2(sp.ref) fetch_ccs2(project_id, milestone_id, coord_counc_s2)))::double precision,
                             0::double precision)                                         AS ccs2_value
             FROM scrum_projects sp)
SELECT cte.project_id,
       cte.milestone_id,
       cte.a_value,
       cte.b_value,
       cte.c_value,
       cte.d_value,
       cte.e_value,
       cte.f_value,
       cte.plan_value,
       cte.review_value,
       cte.retro_value,
       cte.ccs1_value,
       cte.ccs2_value
FROM cte;

alter table public.online_scores
    owner to taiga_u;
