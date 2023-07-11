DROP PROCEDURE IF EXISTS import_tsv;
DROP PROCEDURE IF EXISTS import_csv;

DROP PROCEDURE IF EXISTS import_tsv_personal_data;
DROP PROCEDURE IF EXISTS import_tsv_cards;
DROP PROCEDURE IF EXISTS import_tsv_groups_sku;
DROP PROCEDURE IF EXISTS import_tsv_sku;
DROP PROCEDURE IF EXISTS import_tsv_stores;
DROP PROCEDURE IF EXISTS import_tsv_transaction;
DROP PROCEDURE IF EXISTS import_tsv_checks;

DROP PROCEDURE IF EXISTS import_csv_personal_data;
DROP PROCEDURE IF EXISTS import_csv_cards;
DROP PROCEDURE IF EXISTS import_csv_groups_sku;
DROP PROCEDURE IF EXISTS import_csv_sku;
DROP PROCEDURE IF EXISTS import_csv_stores;
DROP PROCEDURE IF EXISTS import_csv_transaction;
DROP PROCEDURE IF EXISTS import_csv_checks;

-- import TSV

CREATE OR REPLACE PROCEDURE import_tsv(file_name varchar,
                                    table_name varchar,
                                    delimiter varchar)
language plpgsql
as $$
declare
    dir varchar := (SELECT setting AS directory
                    FROM pg_settings
                    WHERE name = 'data_directory') || '/' || file_name;
begin
    EXECUTE format('COPY %s FROM %L WITH DELIMITER %L', quote_ident(table_name), dir, delimiter);
end $$;

-- Import CSV

CREATE OR REPLACE PROCEDURE import_csv(file_name varchar,
                                    table_name varchar,
                                    delimiter varchar)
language plpgsql
as $$
declare
    dir varchar := (SELECT setting AS directory
                    FROM pg_settings
                    WHERE name = 'data_directory') || '/' || file_name;
begin
    EXECUTE format('COPY %s FROM %L WITH CSV DELIMITER %L HEADER', quote_ident(table_name), dir, delimiter);
end $$;

-- Import TSV

CREATE OR REPLACE PROCEDURE import_tsv_personal_data(delimiter varchar) language plpgsql AS $$
begin
    CALL import_tsv('Personal_Data_Mini.tsv', 'personal_data', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_tsv_cards(delimiter varchar) language plpgsql as $$
begin
    CALL import_tsv('Cards_Mini.tsv', 'cards', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_tsv_groups_sku(delimiter varchar) language plpgsql as $$
begin
    CALL import_tsv('Groups_SKU_Mini.tsv', 'groups_sku', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_tsv_sku(delimiter varchar) language plpgsql as $$
begin
    CALL import_tsv('SKU_Mini.tsv', 'sku', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_tsv_stores(delimiter varchar) language plpgsql as $$
begin
    CALL import_tsv('Stores_Mini.tsv', 'stores', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_tsv_transaction(delimiter varchar) language plpgsql as $$
begin
    CALL import_tsv('Transactions_Mini.tsv', 'transactions', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_tsv_checks(delimiter varchar) language plpgsql as $$
begin
    CALL import_tsv('Checks_Mini.tsv', 'checks', delimiter);
end $$;

-- import CSV

CREATE OR REPLACE PROCEDURE import_csv_personal_data(delimiter varchar) language plpgsql AS $$
begin
    CALL import_csv('Personal_Data.csv', 'personal_data', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_csv_cards(delimiter varchar) language plpgsql as $$
begin
    CALL import_csv('Cards.csv', 'cards', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_csv_groups_sku(delimiter varchar) language plpgsql as $$
begin
    CALL import_csv('Groups_SKU.csv', 'groups_sku', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_csv_sku(delimiter varchar) language plpgsql as $$
begin
    CALL import_csv('SKU.csv', 'sku', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_csv_stores(delimiter varchar) language plpgsql as $$
begin
    CALL import_csv('Stores.csv', 'stores', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_csv_transaction(delimiter varchar) language plpgsql as $$
begin
    CALL import_csv('Transactions.csv', 'transactions', delimiter);
end $$;

CREATE OR REPLACE PROCEDURE import_csv_checks(delimiter varchar) language plpgsql as $$
begin
    CALL import_csv('Checks.csv', 'checks', delimiter);
end $$;
