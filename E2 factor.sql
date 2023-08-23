CREATE OR REPLACE FUNCTION fetch_e2_value(p_project_id INT) 
RETURNS FLOAT AS 
$$ 
DECLARE 
    v_avg FLOAT;
    v_std FLOAT;
    v_e2_value FLOAT;
BEGIN
    -- Calculate the average and standard deviation of e_value for the entire view
    SELECT AVG(e_value) INTO v_avg FROM your_view_name;
    SELECT STDDEV(e_value) INTO v_std FROM your_view_name;

    -- Check for zero standard deviation
    IF v_std = 0 THEN
        RETURN NULL; -- or some other value indicating an undefined result
    END IF;

    -- Calculate e2_value for the given project_id
    SELECT ((e_value - v_avg) / v_std) INTO v_e2_value
    FROM your_view_name
    WHERE project_id = p_project_id;

    RETURN v_e2_value;
END;
$$ LANGUAGE plpgsql;
