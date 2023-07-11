DROP TABLE IF EXISTS personal_data CASCADE;
DROP TABLE IF EXISTS cards CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS checks CASCADE;
DROP TABLE IF EXISTS sku CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS groups_sku CASCADE;

CREATE TABLE IF NOT EXISTS personal_data (
	Customer_ID SERIAL PRIMARY KEY NOT NULL,
	Customer_Name varchar NOT NULL
        CHECK ( Customer_Name ~ '^[А-Я]+[а-я\s-]'),
	Customer_Surname varchar NOT NULL
        CHECK ( Customer_Surname ~ '^[А-ЯЁ]+[а-яё\s-]'),
	Customer_Primary_Email varchar NOT NULL,
	Customer_Primary_Phone numeric NOT NULL
);

CREATE TABLE IF NOT EXISTS cards (
	Customer_Card_ID SERIAL PRIMARY KEY NOT NULL,
	Customer_ID SERIAL REFERENCES personal_data(Customer_ID) NOT NULL
);

CREATE TABLE IF NOT EXISTS groups_sku (
	Group_ID SERIAL PRIMARY KEY NOT NULL,
	Group_Name varchar NOT NULL
);

CREATE TABLE IF NOT EXISTS sku (
	SKU_ID SERIAL PRIMARY KEY NOT NULL,
	SKU_Name varchar NOT NULL,
	Group_ID SERIAL REFERENCES groups_sku(Group_ID) NOT NULL
);

CREATE TABLE IF NOT EXISTS stores (
	Transaction_Store_ID SERIAL NOT NULL,
	SKU_ID SERIAL REFERENCES sku(SKU_ID),
	SKU_Purchase_Price numeric NOT NULL,
	SKU_Retail_Price numeric NOT NULL
);

CREATE TABLE IF NOT EXISTS transactions (
	Transaction_ID SERIAL primary key NOT NULL,
	Customer_Card_ID SERIAL REFERENCES cards(Customer_Card_ID),
	Transaction_Summ numeric NOT NULL,
	Transaction_DateTime timestamp NOT NULL,
	Transaction_Store_ID SERIAL NOT NULL
);

CREATE TABLE IF NOT EXISTS checks(
	Transaction_ID SERIAL REFERENCES transactions(Transaction_ID) NOT NULL,
	SKU_ID SERIAL REFERENCES sku(SKU_ID) NOT NULL,
	SKU_Amount numeric NOT NULL,
	SKU_Summ numeric NOT NULL,
	SKU_Summ_Paid numeric NOT NULL,
	SKU_Discount numeric NOT NULL
);
