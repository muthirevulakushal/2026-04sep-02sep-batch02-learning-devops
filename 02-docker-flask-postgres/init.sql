CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders
(customer_name, product_name, quantity)
VALUES
('John Doe', 'Laptop', 1),
('Alice Smith', 'Keyboard', 2),
('Bob Johnson', 'Mouse', 3),
('David Miller', 'Monitor', 1),
('Sophia Brown', 'Headphones', 2);