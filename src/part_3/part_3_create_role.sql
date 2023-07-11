DROP OWNED BY administrator;
DROP OWNED BY user_readonly;
DROP ROLE IF EXISTS user_readonly;
DROP ROLE IF EXISTS administrator;

CREATE ROLE user_readonly LOGIN;
GRANT pg_read_all_data TO user_readonly;
GRANT SELECT ON TABLE personal_data, cards,
    stores, checks,
    groups_sku, sku, transactions 
TO user_readonly;

CREATE ROLE administrator LOGIN PASSWORD 'a';
-- Нужно вставить название базы вместо retailanalytics
GRANT ALL ON DATABASE retailanalytics TO administrator; 
GRANT postgres TO administrator;
