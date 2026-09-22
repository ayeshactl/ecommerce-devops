import json
import redis

import os

import psycopg2
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="ShopSphere E-Commerce API")

app.add_middleware( 
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)




def get_db_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME", "ecommerce_db"),
        user=os.getenv("DB_USER", "ecommerce_user"),
        password=os.getenv("DB_PASSWORD", "ecommerce_pass"),
        port=os.getenv("DB_PORT", "5432"),
    )


def get_redis_connection():
    return redis.Redis(
        host=os.getenv("REDIS_HOST", "localhost"),
        port=int(os.getenv("REDIS_PORT", "6379")),
        decode_responses=True,
    )

@app.get("/")
def root():
    return {"message": "ShopSphere backend is running"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/db-health")
def database_health():
    try:
        connection = get_db_connection()
        cursor = connection.cursor()

        cursor.execute("SELECT 1;")
        result = cursor.fetchone()

        cursor.close()
        connection.close()

        return {
            "status": "healthy",
            "database": "connected",
            "result": result[0],
        }

    except Exception as error:
        return {
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(error),
        }

@app.get("/products")
def get_products():
    redis_client = get_redis_connection()

    # 1. Check Redis first
    cached_products = redis_client.get("products")

    if cached_products:
        return json.loads(cached_products)

    # 2. Cache miss → query PostgreSQL
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("""
        SELECT id, name, category, price, old_price, rating, icon, badge
        FROM products
        ORDER BY id;
    """)

    rows = cursor.fetchall()

    products = []

    for row in rows:
        products.append({
            "id": row[0],
            "name": row[1],
            "category": row[2],
            "price": float(row[3]),
            "oldPrice": float(row[4]) if row[4] is not None else None,
            "rating": float(row[5]) if row[5] is not None else None,
            "icon": row[6],
            "badge": row[7],
        })

    cursor.close()
    connection.close()

    # 3. Save products in Redis for 60 seconds
    redis_client.setex(
        "products",
        60,
        json.dumps(products)
    )

    return products