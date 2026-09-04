# Docker + Flask + PostgreSQL Orders Management System
## Project Overview
This project demonstrates how to build a simple web application using:
 * Docker
 * Dockerfile
 * Docker Compose
 * Python Flask
 * PostgreSQL
 * Environment Variables (.env)
 * HTML Templates (Jinja2)
The application:
 1. Starts a Flask web application container.
 2. Starts a PostgreSQL database container.
 3. Creates an Orders table automatically.
 4. Inserts sample order records.
 5. Displays order data in a browser.


## Architecture
```text
Browser
   │
   ▼
Flask Container
   │
   ▼
PostgreSQL Container
```

## Project Structure
```text
docker-flask-postgres/
│
├── app.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── .env
├── init.sql
│
└── templates/
    ├── index.html
    └── results.html
```



# File 1: .env
```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secret
POSTGRES_DB=ordersdb

DB_HOST=db
DB_PORT=5432
```

## Purpose
Stores configuration separately from code.

# File 2: init.sql
```sql
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
```

## Purpose
Creates Orders table and inserts sample data automatically during database initialization.

# File 3: requirements.txt

```text
Flask==3.0.0
psycopg2-binary==2.9.9
python-dotenv==1.0.1
```

## Purpose
Installs required Python libraries.


# File 4: app.py
```python
from flask import Flask, render_template
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        database=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD")
    )

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/orders")
def orders():

    conn = get_connection()
    cur = conn.cursor()

    cur.execute("""
        SELECT
            id,
            customer_name,
            product_name,
            quantity,
            order_date
        FROM orders
        ORDER BY id
    """)

    orders_data = cur.fetchall()

    cur.close()
    conn.close()

    return render_template(
        "results.html",
        orders=orders_data
    )

if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )
```

## Purpose
* Connects to PostgreSQL
* Fetches order records
* Renders HTML templates


# File 5: templates/index.html
```html
<!DOCTYPE html>
<html>
<head>
    <title>Orders Management System</title>

    <style>
        body{
            font-family:Arial;
            text-align:center;
            margin-top:100px;
        }

        button{
            padding:15px;
            font-size:18px;
            cursor:pointer;
        }
    </style>
</head>

<body>

<h1>Docker + Flask + PostgreSQL</h1>

<h2>Orders Management System</h2>

<p>Click below to view all orders.</p>

<a href="/orders">
    <button>View Orders</button>
</a>

</body>
</html>
```

## Purpose
Home page.

# File 6: templates/results.html
```html
<!DOCTYPE html>
<html>
<head>
    <title>Orders</title>

    <style>

        body{
            font-family:Arial;
            margin:40px;
        }

        table{
            width:100%;
            border-collapse:collapse;
        }

        th{
            background:#0077cc;
            color:white;
        }

        td,th{
            border:1px solid #ddd;
            padding:10px;
        }

        tr:nth-child(even){
            background:#f2f2f2;
        }

    </style>

</head>

<body>

<h1>Orders List</h1>

<table>

<tr>
    <th>ID</th>
    <th>Customer</th>
    <th>Product</th>
    <th>Quantity</th>
    <th>Order Date</th>
</tr>

{% for order in orders %}
<tr>
    <td>{{ order[0] }}</td>
    <td>{{ order[1] }}</td>
    <td>{{ order[2] }}</td>
    <td>{{ order[3] }}</td>
    <td>{{ order[4] }}</td>
</tr>
{% endfor %}

</table>

<br>

<a href="/">
    <button>Back Home</button>
</a>

</body>
</html>
```

## Purpose
Displays orders retrieved from PostgreSQL.

# File 7: Dockerfile
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

## Purpose
Builds Flask application image.

# File 8: docker-compose.yml
```yaml
services:

  web:
    build: .

    container_name: flask-app

    ports:
      - "5000:5000"

    env_file:
      - .env

    depends_on:
      - db

    networks:
      - backend

  db:
    image: postgres:15

    container_name: postgres-db

    env_file:
      - .env

    volumes:
      - db-data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql

    networks:
      - backend

volumes:
  db-data:

networks:
  backend:
```

## Purpose
Creates and manages:
 * Flask container
 * PostgreSQL container
 * Docker network
 * Persistent volume

# Build and Run
## Build
```bash
docker compose build
docker-compose up -d --build
```

## Start
```bash
docker compose up -d
```

## Verify
```bash
docker ps
```

Expected:
```text
flask-app
postgres-db
```
# Open Application
Open:
```text
http://localhost:5000
```

Workflow:

```text
Home Page
   │
   ▼
View Orders
   │
   ▼
Flask
   │
   ▼
PostgreSQL
   │
   ▼
Results Page
```

# Verify Database
Enter PostgreSQL container:

```bash
docker exec -it postgres-db bash
```

Connect:

```bash
psql -U postgres -d ordersdb
```

Show tables:

```sql
\dt
```

Query data:

```sql
SELECT * FROM orders;
```


# Useful Commands
Show containers:

```bash
docker ps
```

Show logs:
```bash
docker compose logs
```

Follow logs:
```bash
docker compose logs -f
```

Stop containers:
```bash
docker compose stop
```

Remove containers:
```bash
docker compose down
```

Remove containers and data:
```bash
docker compose down -v
```

Rebuild:
```bash
docker compose up --build
```

# Key Docker Concepts
## Image
Blueprint used to create containers.
Example:

```bash
docker pull postgres:15
```

## Container
Running instance of an image.

## Dockerfile
Defines how an image is built.

## Docker Compose
Defines how multiple containers work together.

## Volumes
Persist data outside containers.

## Networks
Enable communication between containers.

Example:

```python
host="db"
```

The service name `db` resolves automatically through Docker networking.
