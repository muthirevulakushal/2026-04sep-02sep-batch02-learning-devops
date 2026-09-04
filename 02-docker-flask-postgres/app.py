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
