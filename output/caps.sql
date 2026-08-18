CREATE TABLE policy_features (
    policy_id             VARCHAR2(128),
    policy_tenure         NUMBER(38,9),
    age_of_car            NUMBER(38,2),
    age_of_policyholder   NUMBER(38,9),
    area_cluster          VARCHAR2(100),
    population_density    NUMBER(38),

    CONSTRAINT policy_features_pk
        PRIMARY KEY (policy_id),

    CONSTRAINT policy_tenure_ck
        CHECK (policy_tenure >= 0),

    CONSTRAINT age_of_car_ck
        CHECK (age_of_car >= 0),

    CONSTRAINT age_of_policyholder_ck
        CHECK (age_of_policyholder >= 0),

    CONSTRAINT population_density_ck
        CHECK (population_density >= 0)
);

CREATE TABLE carfeatures (
    policy_id                            VARCHAR2(128),
    make                                 NUMBER(38),
    segment                              VARCHAR2(128),
    model                                VARCHAR2(100),
    fuel_type                            VARCHAR2(100),
    max_torque                           VARCHAR2(100),
    max_power                            VARCHAR2(100),
    engine_type                          VARCHAR2(100),
    airbags                              NUMBER(38),
    is_esc                               VARCHAR2(100),
    is_adjustable_steering               VARCHAR2(100),
    is_tpms                              VARCHAR2(100),
    is_parking_sensors                   VARCHAR2(100),
    is_parking_camera                    VARCHAR2(100),
    rear_brakes_type                     VARCHAR2(100),
    displacement                         NUMBER(38),
    cylinder                             NUMBER(38),
    transmission_type                    VARCHAR2(100),
    gear_box                             NUMBER(38),
    steering_type                        VARCHAR2(100),
    turning_radius                       NUMBER(38,2),
    length                               NUMBER(38),
    width                                NUMBER(38),
    height                               NUMBER(38),
    gross_weight                         NUMBER(38),
    is_front_fog_lights                  VARCHAR2(100),
    is_rear_window_wiper                 VARCHAR2(100),
    is_rear_window_washer                VARCHAR2(100),
    is_rear_window_defogger              VARCHAR2(100),
    is_brake_assist                      VARCHAR2(100),
    is_power_door_locks                  VARCHAR2(100),
    is_central_locking                   VARCHAR2(100),
    is_power_steering                    VARCHAR2(100),
    isdriverseat_height_adjustable       VARCHAR2(100),
    is_day_night_rear_view_mirror        VARCHAR2(26),
    is_ecw                               VARCHAR2(100),
    is_speed_alert                       VARCHAR2(100),
    ncap_rating                          NUMBER(38),

    CONSTRAINT carfeatures_pk
        PRIMARY KEY (policy_id),

    CONSTRAINT carfeatures_policy_fk
        FOREIGN KEY (policy_id)
        REFERENCES policy_features (policy_id),

    CONSTRAINT carfeatures_airbags_ck
        CHECK (airbags >= 0),

    CONSTRAINT carfeatures_weight_ck
        CHECK (gross_weight > 0),

    CONSTRAINT carfeatures_ncap_ck
        CHECK (ncap_rating BETWEEN 0 AND 5)
);

CREATE TABLE insurance_claim (
    policy_id   VARCHAR2(128),
    is_claim    NUMBER(1) NOT NULL,

    CONSTRAINT insurance_claim_pk
        PRIMARY KEY (policy_id),

    CONSTRAINT insurance_claim_policy_fk
        FOREIGN KEY (policy_id)
        REFERENCES policy_features (policy_id),

    CONSTRAINT insurance_claim_flag_ck
        CHECK (is_claim IN (0, 1))
);


INSERT INTO policy_features (
    policy_id,
    policy_tenure,
    age_of_car,
    age_of_policyholder,
    area_cluster,
    population_density
)
SELECT
    policy_id,
    policy_tenure,
    age_of_car,
    age_of_policyholder,
    area_cluster,
    population_density
FROM policy_features_stg;

INSERT INTO carfeatures (
    policy_id,
    make,
    segment,
    model,
    fuel_type,
    max_torque,
    max_power,
    engine_type,
    airbags,
    is_esc,
    is_adjustable_steering,
    is_tpms,
    is_parking_sensors,
    is_parking_camera,
    rear_brakes_type,
    displacement,
    cylinder,
    transmission_type,
    gear_box,
    steering_type,
    turning_radius,
    length,
    width,
    height,
    gross_weight,
    is_front_fog_lights,
    is_rear_window_wiper,
    is_rear_window_washer,
    is_rear_window_defogger,
    is_brake_assist,
    is_power_door_locks,
    is_central_locking,
    is_power_steering,
    isdriverseat_height_adjustable,
    is_day_night_rear_view_mirror,
    is_ecw,
    is_speed_alert,
    ncap_rating
)
SELECT
    policy_id,
    make,
    segment,
    model,
    fuel_type,
    max_torque,
    max_power,
    engine_type,
    airbags,
    is_esc,
    is_adjustable_steering,
    is_tpms,
    is_parking_sensors,
    is_parking_camera,
    rear_brakes_type,
    displacement,
    cylinder,
    transmission_type,
    gear_box,
    steering_type,
    turning_radius,
    length,
    width,
    height,
    gross_weight,
    is_front_fog_lights,
    is_rear_window_wiper,
    is_rear_window_washer,
    is_rear_window_defogger,
    is_brake_assist,
    is_power_door_locks,
    is_central_locking,
    is_power_steering,
    isdriverseat_height_adjustable,
    is_day_night_rear_view_mirror,
    is_ecw,
    is_speed_alert,
    ncap_rating
FROM carfeatures_stg;

INSERT INTO insurance_claim (
    policy_id,
    is_claim
)
SELECT
    policy_id,
    is_claim
FROM insurance_claim_stg;

COMMIT;



-- 1. Average population density for policies with and without claims
--    in different area clusters

SELECT
    p.area_cluster,
    i.is_claim,
    AVG(p.population_density) AS avg_population_density
FROM insurance_claim i
JOIN policy_features p
    ON i.policy_id = p.policy_id
GROUP BY
    p.area_cluster,
    i.is_claim
ORDER BY
    p.area_cluster,
    i.is_claim;


-- 2. Cars with a safety rating above 4,
--    gross weight below 2000 kg, and policy tenure above 5 years

SELECT
    cf.policy_id,
    cf.make AS make_id,
    cf.model,
    cf.segment,
    cf.ncap_rating,
    cf.gross_weight,
    pf.policy_tenure
FROM carfeatures cf
JOIN policy_features pf
    ON cf.policy_id = pf.policy_id
WHERE cf.ncap_rating > 4
  AND cf.gross_weight < 2000
  AND pf.policy_tenure > 5
ORDER BY
    pf.policy_tenure DESC;


-- 3. Car segments with more than 100 policies

SELECT
    cf.segment,
    COUNT(DISTINCT cf.policy_id) AS policy_count
FROM carfeatures cf
GROUP BY
    cf.segment
HAVING COUNT(DISTINCT cf.policy_id) > 100
ORDER BY
    policy_count DESC;


-- 4. Policies with the highest policy tenure
--    and their corresponding car make and model

SELECT
    pf.policy_id,
    pf.age_of_policyholder,
    cf.make AS make_id,
    cf.model,
    pf.policy_tenure
FROM policy_features pf
JOIN carfeatures cf
    ON pf.policy_id = cf.policy_id
WHERE pf.policy_tenure = (
    SELECT MAX(policy_tenure)
    FROM policy_features
)
ORDER BY
    pf.policy_tenure DESC;


-- 5. Policies with the highest policy tenure
--    in each car age category

WITH categorized_policies AS (
    SELECT
        pf.policy_id,
        cf.make AS make_id,
        cf.model,
        pf.policy_tenure,
        pf.age_of_car,
        pf.age_of_policyholder,
        pf.area_cluster,
        pf.population_density,
        CASE
            WHEN pf.age_of_car < 3 THEN '0-3 Years'
            WHEN pf.age_of_car < 6 THEN '3-6 Years'
            ELSE '6+ Years'
        END AS age_category
    FROM policy_features pf
    JOIN carfeatures cf
        ON pf.policy_id = cf.policy_id
    WHERE pf.age_of_car IS NOT NULL
),
ranked_policies AS (
    SELECT
        cp.*,
        RANK() OVER (
            PARTITION BY cp.age_category
            ORDER BY cp.policy_tenure DESC NULLS LAST
        ) AS tenure_rank
    FROM categorized_policies cp
)
SELECT
    policy_id,
    make_id,
    model,
    age_category,
    age_of_car,
    policy_tenure,
    age_of_policyholder,
    area_cluster,
    population_density
FROM ranked_policies
WHERE tenure_rank = 1
ORDER BY
    CASE age_category
        WHEN '0-3 Years' THEN 1
        WHEN '3-6 Years' THEN 2
        WHEN '6+ Years' THEN 3
    END,
    policy_id;


-- 6. Top three car models with the highest average policy tenure
--    among policies with a claim

WITH claimed_policies AS (
    SELECT DISTINCT
        policy_id
    FROM insurance_claim
    WHERE is_claim = 1
),
model_averages AS (
    SELECT
        cf.model,
        AVG(pf.policy_tenure) AS avg_policy_tenure
    FROM claimed_policies cp
    JOIN policy_features pf
        ON cp.policy_id = pf.policy_id
    JOIN carfeatures cf
        ON pf.policy_id = cf.policy_id
    GROUP BY
        cf.model
),
ranked_models AS (
    SELECT
        model,
        avg_policy_tenure,
        ROW_NUMBER() OVER (
            ORDER BY avg_policy_tenure DESC, model
        ) AS model_rank
    FROM model_averages
)
SELECT
    model,
    avg_policy_tenure
FROM ranked_models
WHERE model_rank <= 3
ORDER BY
    avg_policy_tenure DESC,
    model;
