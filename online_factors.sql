CREATE OR REPLACE VIEW online_factors AS
SELECT 
    os.*, -- This will select all fields from online_scores
    fetch_e2_value(os.project_id) AS e2_value,
    os.a_value * ((os.b_value * 0.2) + (os.c_value * 0.2) + (os.d_value * 0.6)) * EXP(fetch_e2_value(os.project_id)) AS methode_b2,
    fetch_r22_value(os.project_id) as r22_value,
    os.a_value * ((os.b_value * 0.2) + (os.c_value * 0.2) + (os.d_value * 0.6)) * EXP(fetch_r22_value(os.project_id)) AS methode_a2

FROM 
    online_scores os;
