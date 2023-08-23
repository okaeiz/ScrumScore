CREATE OR REPLACE FUNCTION fetch_r22_value(p_project_id INT) 
RETURNS FLOAT AS 
$$ 
DECLARE 
    v_avg FLOAT;
    v_std FLOAT;
    v_r2_value FLOAT;
BEGIN
    -- Calculate the average and standard deviation of r2_value for the entire view
    SELECT AVG(r2_value) INTO v_avg FROM your_view_name;
    SELECT STDDEV(r2_value) INTO v_std FROM your_view_name;

    -- Check for zero standard deviation
    IF v_std = 0 THEN
        RETURN NULL; -- or some other value indicating an undefined result
    END IF;

    -- Calculate e2_value for the given project_id
    SELECT ((r2_value - v_avg) / v_std) INTO v_r2_value
    FROM your_view_name
    WHERE project_id = p_project_id;

    RETURN v_r2_value;
END;
$$ LANGUAGE plpgsql;
