DROP PROCEDURE IF EXISTS export_csv;
DROP PROCEDURE IF EXISTS export_tsv;

DROP PROCEDURE IF EXISTS export_tsv_personal_data;
DROP PROCEDURE IF EXISTS export_tsv_cards;
DROP PROCEDURE IF EXISTS export_tsv_groups_sku;
DROP PROCEDURE IF EXISTS export_tsv_sku;
DROP PROCEDURE IF EXISTS export_tsv_stores;
DROP PROCEDURE IF EXISTS export_tsv_transaction;
DROP PROCEDURE IF EXISTS export_tsv_checks;

DROP PROCEDURE IF EXISTS export_csv_personal_data;
DROP PROCEDURE IF EXISTS export_csv_cards;
DROP PROCEDURE IF EXISTS export_csv_groups_sku;
DROP PROCEDURE IF EXISTS export_csv_sku;
DROP PROCEDURE IF EXISTS export_csv_stores;
DROP PROCEDURE IF EXISTS export_csv_transaction;
DROP PROCEDURE IF EXISTS export_csv_checks;

-- Export CSV

CREATE OR REPLACE PROCEDURE export_csv(file_name varchar,
                                       table_name varchar,
                                       delimiter varchar)
language plpgsql AS $$
DECLARE
    dir varchar := (SELECT setting AS directory
                    FROM pg_settings
                    WHERE name = 'data_directory') || '/' || file_name;
BEGIN
    EXECUTE format('COPY %s TO %L WITH CSV DELIMITER %L HEADER', quote_ident(table_name), dir, delimiter);
END $$;

-- Export TSV

CREATE OR REPLACE PROCEDURE export_tsv(file_name varchar,
                                       table_name varchar,
                                       delimiter varchar)
language plpgsql AS $$
DECLARE
    dir varchar := (SELECT setting AS directory
                    FROM pg_settings
                    WHERE name = 'data_directory') || '/' || file_name;
BEGIN
    EXECUTE format('COPY %s TO %L WITH DELIMITER %L', quote_ident(table_name), dir, delimiter);
END $$;

-- Export TSV

CREATE OR REPLACE PROCEDURE export_tsv_personal_data(delimiter varchar) language plpgsql AS $$
begin
    CALL export_tsv('personal_Data.tsv', 'personal_data', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_tsv_cards(delimiter varchar) language plpgsql as $$
begin
    CALL export_tsv('cards.tsv', 'cards', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_tsv_groups_sku(delimiter varchar) language plpgsql as $$
begin
    CALL export_tsv('groups_SKU.tsv', 'groups_sku', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_tsv_sku(delimiter varchar) language plpgsql as $$
begin
    CALL export_tsv('sku.tsv', 'sku', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_tsv_stores(delimiter varchar) language plpgsql as $$
begin
    CALL export_tsv('stores.tsv', 'stores', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_tsv_transaction(delimiter varchar) language plpgsql as $$
begin
    CALL export_tsv('transactions.tsv', 'transactions', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_tsv_checks(delimiter varchar) language plpgsql as $$
begin
    CALL export_tsv('checks.tsv', 'checks', delimiter);
end $$;

-- export CSV

CREATE OR REPLACE PROCEDURE export_csv_personal_data(delimiter varchar) language plpgsql AS $$
begin
    CALL export_csv('Personal_Data.csv', 'personal_data', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_csv_cards(delimiter varchar) language plpgsql as $$
begin
    CALL export_csv('Cards.csv', 'cards', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_csv_groups_sku(delimiter varchar) language plpgsql as $$
begin
    CALL export_csv('Groups_SKU.csv', 'groups_sku', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_csv_sku(delimiter varchar) language plpgsql as $$
begin
    CALL export_csv('SKU.csv', 'sku', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_csv_stores(delimiter varchar) language plpgsql as $$
begin
    CALL export_csv('Stores.csv', 'stores', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_csv_transaction(delimiter varchar) language plpgsql as $$
begin
    CALL export_csv('Transactions.csv', 'transactions', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE export_csv_checks(delimiter varchar) language plpgsql as $$
begin
    CALL export_csv('Checks.csv', 'checks', delimiter);
end $$;

-- 

CALL export_tsv_personal_data(E'\t');
CALL export_csv_personal_data(',');