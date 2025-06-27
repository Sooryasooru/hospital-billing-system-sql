postgres=# CREATE DATABASE hospital_billing_db;
\c hospital_billing_db;
CREATE DATABASE
You are now connected to database "hospital_billing_db" as user "postgres".
hospital_billing_db=# CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender CHAR(1) CHECK (gender IN ('M', 'F')),
    age INT CHECK (age > 0),
    contact VARCHAR(50)
);

CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100),
    contact VARCHAR(50)
);

CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    doctor_id INT REFERENCES doctors(doctor_id),
    appointment_date DATE NOT NULL,
    notes TEXT
);

CREATE TABLE treatments (
    treatment_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    cost NUMERIC(10, 2) CHECK (cost >= 0)
);

CREATE TABLE bills (
    bill_id SERIAL PRIMARY KEY,
    appointment_id INT REFERENCES appointments(appointment_id),
    bill_date DATE NOT NULL
);

CREATE TABLE bill_items (
    item_id SERIAL PRIMARY KEY,
    bill_id INT REFERENCES bills(bill_id),
    treatment_id INT REFERENCES treatments(treatment_id),
    quantity INT CHECK (quantity > 0),
    cost NUMERIC(10, 2) -- computed manually on insert
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
);  log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP 'Card', 'Insurance'))
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
hospital_billing_db=# INSERT INTO patients (name, gender, age, contact) VALUES
('John Doe', 'M', 35, 'john@example.com'),
('Jane Smith', 'F', 29, 'jane@example.com');

INSERT INTO doctors (name, specialty, contact) VALUES
('Dr. House', 'Diagnostics', 'house@hospital.com'),
('Dr. Grey', 'Surgery', 'grey@hospital.com');

INSERT INTO treatments (name, cost) VALUES
('MRI Scan', 3000.00),
('Blood Test', 500.00),
('Consultation', 1000.00);

INSERT INTO appointments (patient_id, doctor_id, appointment_date, notes) VALUES
(1, 1, '2025-06-15', 'Headache and dizziness'),
(2, 2, '2025-06-18', 'Annual checkup');

INSERT INTO bills (appointment_id, bill_date) VALUES
(1, '2025-06-15'),
(2, '2025-06-18');

INSERT INTO bill_items (bill_id, treatment_id, quantity, cost) VALUES
(1, 1, 1, 3000.00),
(1, 3, 1, 1000.00),
(2, 2, 2, 1000.00); -- 2 x 500

INSERT INTO payments (bill_id, payment_date, amount_paid, method) VALUES
(1, '2025-06-16', 4000.00, 'Card'),
(2, '2025-06-19', 1000.00, 'Cash');
INSERT 0 2
INSERT 0 2
INSERT 0 3
INSERT 0 2
INSERT 0 2
INSERT 0 3
INSERT 0 2
hospital_billing_db=# CREATE VIEW patient_billing_summary AS
SELECT 
    p.name AS patient_name,
    b.bill_id,
    b.bill_date,
    SUM(bi.cost) AS total_amount,
    COALESCE(SUM(pm.amount_paid), 0) AS amount_paid,
    SUM(bi.cost) - COALESCE(SUM(pm.amount_paid), 0) AS balance_due
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
JOIN bills b ON a.appointment_id = b.appointment_id
JOIN bill_items bi ON b.bill_id = bi.bill_id
LEFT JOIN payments pm ON b.bill_id = pm.bill_id
GROUP BY p.name, b.bill_id, b.bill_date;
CREATE VIEW
hospital_billing_db=# CREATE OR REPLACE FUNCTION get_total_bill(bid INT)
RETURNS NUMERIC AS $$
DECLARE
    total NUMERIC;
BEGIN
    SELECT SUM(cost) INTO total
    FROM bill_items
    WHERE bill_id = bid;

    RETURN total;
END;
$$ LANGUAGE plpgsql;
CREATE FUNCTION
hospital_billing_db=# CREATE OR REPLACE PROCEDURE insert_payment(
    p_bill_id INT,
    p_amount NUMERIC,
    p_method VARCHAR,
    p_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM bills WHERE bill_id = p_bill_id) THEN
        RAISE EXCEPTION 'Bill ID % does not exist', p_bill_id;
    END IF;

    INSERT INTO payments (bill_id, amount_paid, method, payment_date)
    VALUES (p_bill_id, p_amount, p_method, p_date);
END;
$$;
CREATE PROCEDURE
hospital_billing_db=# CREATE OR REPLACE FUNCTION log_payment()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO payment_logs (bill_id, log_message)
    VALUES (
        NEW.bill_id,
        'Payment of ' || NEW.amount_paid || ' made via ' || NEW.method
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER payment_logger
AFTER INSERT ON payments
FOR EACH ROW
EXECUTE FUNCTION log_payment();
CREATE FUNCTION
CREATE TRIGGER
hospital_billing_db=# INSERT INTO payments (bill_id, payment_date, amount_paid, method)
VALUES (1, CURRENT_DATE, 500, 'Cash');

SELECT * FROM payment_logs ORDER BY log_time DESC;
INSERT 0 1
 log_id | bill_id |           log_message           |          log_time          
--------+---------+---------------------------------+----------------------------
      1 |       1 | Payment of 500.00 made via Cash | 2025-06-27 13:03:23.268564
(1 row)

hospital_billing_db=# SELECT get_total_bill(1);
 get_total_bill 
----------------
        4000.00
(1 row)

hospital_billing_db=# CALL insert_payment(2, 200, 'Insurance', CURRENT_DATE);
CALL
hospital_billing_db=# mkdir hospital-billing-system-sql
cd hospital-billing-system-sql
hospital_billing_db-# nano hospital_billing_system.sql
hospital_billing_db-# nano README.md
hospital_billing_db-# # Hospital Billing System (PostgreSQL)

This is a complete hospital billing management system built using PostgreSQL.
