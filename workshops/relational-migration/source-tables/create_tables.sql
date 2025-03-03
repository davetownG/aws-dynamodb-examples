-- DROP DATABASE IF EXISTS app_db;
CREATE DATABASE IF NOT EXISTS app_db;

USE app_db;

DROP TABLE IF EXISTS Ledger;
DROP TABLE IF EXISTS OrderLines;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Reps;


CREATE TABLE Customers (
  cust_id varchar(20) NOT NULL,
  name varchar(20) NOT NULL,
  email varchar(50) NOT NULL,
  phone varchar(30) NULL,
  region varchar(30) NOT NULL,
  state varchar(30) NULL,
  credit_rating int NOT NULL,
  last_updated datetime NOT NULL,
  
  CONSTRAINT idx_cust_pk PRIMARY KEY (cust_id),

  INDEX idx_email (email),
  INDEX idx_region (region)

);
SELECT 'created table Customers' as '';

CREATE TABLE Products (
  prod_id varchar(20) NOT NULL,
  name varchar(20) NOT NULL,
  category varchar(20) NOT NULL,
  list_price int NOT NULL,
  last_updated datetime NOT NULL,
  
  CONSTRAINT idx_prod_pk PRIMARY KEY (prod_id),

  INDEX idx_category (category, last_updated)
);
SELECT 'created table Products' as '';

CREATE TABLE Reps (
    rep_id VARCHAR(20) NOT NULL,
    rep_name VARCHAR(20) NOT NULL,
	last_updated DATETIME NOT NULL,
    CONSTRAINT idx_rep_pk PRIMARY KEY (rep_id)
);
SELECT 'created table Reps' as '';


CREATE TABLE Orders (
  ord_id varchar(20) NOT NULL,
  cust_id varchar(20) NOT NULL,
  rep_id varchar(20) NULL,
  ord_date datetime NOT NULL,
  ship_date datetime NOT NULL,
  last_updated datetime NOT NULL,

  INDEX idx_rep (rep_id),

  CONSTRAINT idx_ord_pk PRIMARY KEY (ord_id),

  CONSTRAINT cust_FK FOREIGN KEY (cust_id) REFERENCES Customers(cust_id),
  CONSTRAINT rep_FK FOREIGN KEY (rep_id) REFERENCES Reps(rep_id)

);
SELECT 'created table Orders' as '';

CREATE TABLE OrderLines (
    ord_id VARCHAR(20) NOT NULL,
    ord_line_id VARCHAR(20) NOT NULL,
    prod_id VARCHAR(20) NOT NULL,
    qty INT NOT NULL,
    item_price INT NOT NULL,
    last_updated DATETIME NOT NULL,
    
    CONSTRAINT idx_ord_line_pk PRIMARY KEY (ord_id , ord_line_id),

    INDEX idx_prod_price (prod_id, item_price),

    CONSTRAINT ord_FK FOREIGN KEY (ord_id) REFERENCES Orders (ord_id),
    CONSTRAINT prod_FK FOREIGN KEY (prod_id) REFERENCES Products (prod_id)
);
SELECT 'created table OrderLines' as '';


SELECT 'Created database app_db and tables' as '';
