create view public.online_factors
            (project_id, milestone_id, a_value, b_value, c_value, d_value, e_value, f_value, plan_value, review_value,
             retro_value, ccs1_value, ccs2_value, methode_c1, methode_d1, methode_d1_red, methode_d2, methode_d2_red)
as
SELECT os.project_id,
       os.milestone_id,
       os.a_value,
       os.b_value,
       os.c_value,
       os.d_value,
       os.e_value,
       os.f_value,
       os.plan_value,
       os.review_value,
       os.retro_value,
       os.ccs1_value,
       os.ccs2_value,
       os.a_value *
       (os.b_value * 0.2::double precision + os.c_value * 0.2::double precision + os.d_value * 0.5::double precision +
        os.f_value * 0.1::double precision) * (0.6::double precision + os.e_value) AS methode_c1,
       os.a_value * COALESCE((os.b_value * 0.2::double precision + os.c_value * 0.2::double precision +
                              os.d_value * 0.5::double precision + os.f_value * 0.1::double precision) *
                             (os.e_value / ((SELECT get_project_commitment_ratio.ratio
                                             FROM get_project_commitment_ratio(os.project_id) get_project_commitment_ratio(id, ratio)))),
                             0::double precision)                                  AS methode_d1,
       os.a_value *
       (os.b_value * 0.2::double precision + os.c_value * 0.2::double precision + os.d_value * 0.5::double precision +
        os.f_value * 0.1::double precision)                                        AS methode_d1_red,
       os.plan_value * os.a_value * COALESCE(
                   (os.b_value * 0.15::double precision + os.c_value * 0.15::double precision +
                    os.d_value * 0.40::double precision + os.f_value * 0.15::double precision +
                    os.review_value * 0.06::double precision + os.retro_value * 0.03::double precision +
                    os.ccs1_value * 0.03::double precision + os.ccs2_value * 0.03::double precision) *
                   (os.e_value / ((SELECT get_project_commitment_ratio.ratio
                                   FROM get_project_commitment_ratio(os.project_id) get_project_commitment_ratio(id, ratio)))),
                   0::double precision)                                            AS methode_d2,
       os.plan_value * os.a_value * (os.b_value * 0.15::double precision + os.c_value * 0.15::double precision +
                                     os.d_value * 0.40::double precision + os.f_value * 0.15::double precision +
                                     os.review_value * 0.06::double precision +
                                     os.retro_value * 0.03::double precision + os.ccs1_value * 0.03::double precision +
                                     os.ccs2_value * 0.03::double precision)       AS methode_d2_red
FROM online_scores os;

alter table public.online_factors
    owner to taiga_u;

