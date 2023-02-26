--DROP TABLE customer;
--DROP TABLE addresses;
--DROP TABLE cards;
--DROP TABLE product;
DROP TABLE purchase;
DROP TABLE reviews;

CREATE TABLE customer(
    email VARCHAR(64) NOT NULL ,
    password VARCHAR(64) NOT NULL ,
    credit_card VARCHAR(64) NOT NULL REFERENCES cards(credit_card) ON DELETE CASCADE,
    address VARCHAR(64) NOT NULL REFERENCES addresses(address) ON DELETE CASCADE,
    PRIMARY KEY(email)
);

CREATE TABLE addresses(
    address VARCHAR(64) NOT NULL UNIQUE,
    street VARCHAR(64) NOT NULL,
    city VARCHAR(64) NOT NULL,
    state VARCHAR(2) NOT NULL,
    zip DEC(5, 0) NOT NULL
);

CREATE TABLE cards(
    credit_card VARCHAR(64) NOT NULL UNIQUE,
    number DEC(16, 0) NOT NULL,
    ex_date DATE NOT NULL
);

CREATE TABLE product(
    name VARCHAR(64) NOT NULL,
    ASIN VARCHAR(10) NOT NULL,
    description VARCHAR(800),
    price DEC(10, 2) NOT NULL,
    avg_rate INT NOT NULL,
    instock_num INT NOT NULL ,
    PRIMARY KEY(name, ASIN),
    check (instock_num >= 0),
    check(avg_rate >= 0 and avg_rate <=5),
    check(price > 0.00)
);

CREATE TABLE reviews(
    name VARCHAR(64) NOT NULL,
    ASIN VARCHAR(10) NOT NULL,
    email VARCHAR(64) NOT NULL,
    text VARCHAR(800),
    rating INT NOT NULL,
    FOREIGN KEY(name, ASIN) REFERENCES product
                    ON DELETE CASCADE,
    FOREIGN KEY(email) REFERENCES customer
                    ON DELETE CASCADE,
    check(rating >= 0 and rating <= 5)
);

CREATE TABLE purchase(
    email VARCHAR(64) NOT NULL,
    name VARCHAR(64) NOT NULL,
    ASIN VARCHAR(10) NOT NULL,
    credit_card VARCHAR(64) NOT NULL REFERENCES cards(credit_card) ON DELETE CASCADE,
    address VARCHAR(64) NOT NULL REFERENCES addresses(address) ON DELETE CASCADE,
    amount DEC(10, 2) NOT NULL,
    date_sent DATE,
    date_received DATE,
    FOREIGN KEY(name, ASIN) REFERENCES product
                    ON DELETE CASCADE,
    FOREIGN KEY(email) REFERENCES customer
                    ON DELETE CASCADE,
    check(amount > 0.00)
);

INSERT INTO customer(email, password, address, credit_card)
VALUES ('zor2100@gmail.com', 'Poke2142', '1215 Village Ln', 'VISA'),
       ('mer1173@gmail.com', 'Cycle1973', '3149 Jersey Ave N' , 'Discover');

INSERT INTO addresses(address, street, city, state, zip)
VALUES ('1215 Village Ln', 'Village Ln', 'Duluth', 'MN', 55812),
       ('3149 Jersey Ave N', 'Jersey Ave N', 'Crystal', 'MN', 55427);

INSERT INTO cards(credit_card, number, ex_date)
VALUES ('VISA', 8767747978481046, '2025-02-24'),
       ('Discover', 2994151413837384, '2024-04-15');

INSERT INTO product(name, ASIN, description, price, avg_rate, instock_num)
VALUES ('Aero Gaming Chair', 'Y9336WN1X8', 'A gaming chair.', 69.99, 4, 20),
       ('Stock Lava Lamp', 'G5563HJT80', 'A lava lamp.', 29.99, 4, 10),
       ('Xbox Elite Series 2', 'H7804FTC4N', 'A gaming controller.', 99.99, 5, 30),
       ('Stock LEDs', 'KL789ER2S4', 'Some LED lights.', 19.99, 4, 100),
       ('Element TV', 'F6HJ98KWT1', 'A TV.', 599.99, 3, 2),
       ('Stock Towels', 'G5782NM7Z4', 'Some bath towels.', 9.99, 5, 500);

INSERT INTO purchase(email, name, ASIN, credit_card, address, amount, date_sent, date_received)
VALUES ('zor2100@gmail.com', 'Aero Gaming Chair', 'Y9336WN1X8', 'VISA', '1215 Village Ln', 70.00, '2020-06-26', '2020-06-30'),
       ('mer1173@gmail.com', 'Stock Towels', 'G5782NM7Z4', 'Discover', '3149 Jersey Ave N', 10.00, '2019-07-04', '2019-07-06');

INSERT INTO reviews(name, ASIN, email, text, rating)
VALUES ('Aero Gaming Chair', 'Y9336WN1X8', 'zor2100@gmail.com', 'Cool chair', 4),
       ('Stock Towels', 'G5782NM7Z4', 'mer1173@gmail.com', 'Nice towels', 4);

SELECT pro.name
FROM purchase pur JOIN product pro ON pro.name = pur.name
WHERE email = 'zor2100@gmail.com';

SELECT *
FROM (
     SELECT *, row_number() OVER (PARTITION BY email ORDER BY avg_rate DESC) AS top_picks
     FROM (
          SELECT email, product.ASIN, avg_rate
          FROM product, purchase
          EXCEPT

          SELECT email, ASIN, avg_rate
          FROM purchase NATURAL JOIN product
              ) AS a_query
         ) AS b_query
WHERE top_picks <= 5;

CREATE INDEX pro_index
ON product(name, ASIN, description, price, avg_rate, instock_num);
/*I created an index on product to retrieve data from the product table more quickly
  when using search queries.*/


