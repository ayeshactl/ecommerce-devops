CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    old_price NUMERIC(10,2),
    rating NUMERIC(2,1),
    icon VARCHAR(20),
    badge VARCHAR(50)
);

INSERT INTO products
(name, category, price, old_price, rating, icon, badge)
VALUES
('Premium Wireless Headphones', 'Audio', 2499, 3299, 4.8, '🎧', 'Best Seller'),
('Smart Fitness Watch', 'Wearables', 3999, 4999, 4.7, '⌚', '20% OFF'),
('Everyday Running Shoes', 'Fashion', 2999, 3799, 4.6, '👟', 'Trending'),
('Urban Laptop Backpack', 'Accessories', 1499, 1999, 4.9, '🎒', 'Popular');
