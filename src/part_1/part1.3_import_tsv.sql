-- Import TSV mini-data
SET datestyle = dmy;
set datestyle to german;

CALL import_tsv_personal_data(E'\t');
CALL import_tsv_cards(E'\t');
CALL import_tsv_groups_sku(E'\t');
CALL import_tsv_sku(E'\t');
CALL import_tsv_stores(E'\t');
CALL import_tsv_transaction(E'\t');
CALL import_tsv_checks(E'\t');