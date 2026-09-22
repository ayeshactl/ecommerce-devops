import { useEffect, useState } from "react";
import "./App.css";

const categories = [
  { icon: "💻", name: "Electronics" },
  { icon: "👟", name: "Fashion" },
  { icon: "⌚", name: "Accessories" },
  { icon: "🏠", name: "Home" },
  { icon: "🎮", name: "Gaming" },
  { icon: "🎧", name: "Audio" },
];


function App() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const response = await fetch("/api/products");
        if (!response.ok) {
          throw new Error("Failed to fetch products");
        }

        const data = await response.json();
        setProducts(data);
      } catch (err) {
        console.error(err);
        setError("Unable to load products.");
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);
  return (
    <div className="app">

      {/* NAVBAR */}
      <header className="navbar">
        <a className="brand" href="#home">
          <span className="brand-icon">S</span>
          <span>ShopSphere</span>
        </a>

        <nav className="nav-links">
          <a href="#home">Home</a>
          <a href="#categories">Categories</a>
          <a href="#products">Products</a>
          <a href="#about">About</a>
        </nav>

        <div className="nav-actions">
          <button className="icon-button" aria-label="Search">
            🔍
          </button>

          <button className="cart-button">
            🛒 <span>Cart</span>
            <strong>0</strong>
          </button>
        </div>
      </header>

      <main>

        {/* HERO */}
        <section className="hero" id="home">
          <div className="hero-content">
            <div className="hero-label">
              ✨ New collection is here
            </div>

            <h1>
              Shop smarter.
              <span> Live better.</span>
            </h1>

            <p>
              Discover products you'll love at prices you'll love even more.
              Quality, convenience and a seamless shopping experience — all in
              one place.
            </p>

            <div className="hero-buttons">
              <a href="#products" className="primary-button">
                Shop Collection <span>→</span>
              </a>

              <a href="#categories" className="secondary-button">
                Explore Categories
              </a>
            </div>

            <div className="hero-stats">
              <div>
                <strong>10K+</strong>
                <span>Happy Customers</span>
              </div>

              <div>
                <strong>500+</strong>
                <span>Quality Products</span>
              </div>

              <div>
                <strong>4.9★</strong>
                <span>Customer Rating</span>
              </div>
            </div>
          </div>

          <div className="hero-showcase">
            <div className="glow"></div>

            <div className="floating-card card-one">
              <span>🚚</span>
              <div>
                <strong>Free Delivery</strong>
                <small>On orders over ₹999</small>
              </div>
            </div>

            <div className="main-product">
              <span className="discount">25% OFF</span>
              <div className="main-product-icon">🎧</div>
              <p>Premium Audio</p>
              <h3>Wireless Headphones</h3>
              <strong>₹2,499</strong>
            </div>

            <div className="floating-card card-two">
              <span>⭐</span>
              <div>
                <strong>4.9 Rating</strong>
                <small>2,000+ reviews</small>
              </div>
            </div>
          </div>
        </section>

        {/* BENEFITS */}
        <section className="benefits">
          <div className="benefit">
            <div className="benefit-icon">🚚</div>
            <div>
              <strong>Free Shipping</strong>
              <span>Orders above ₹999</span>
            </div>
          </div>

          <div className="benefit">
            <div className="benefit-icon">↩️</div>
            <div>
              <strong>Easy Returns</strong>
              <span>7-day return policy</span>
            </div>
          </div>

          <div className="benefit">
            <div className="benefit-icon">🔒</div>
            <div>
              <strong>Secure Payment</strong>
              <span>100% protected</span>
            </div>
          </div>

          <div className="benefit">
            <div className="benefit-icon">💬</div>
            <div>
              <strong>24/7 Support</strong>
              <span>We're here to help</span>
            </div>
          </div>
        </section>

        {/* CATEGORIES */}
        <section className="section categories-section" id="categories">
          <div className="section-title">
            <div>
              <span className="eyebrow">SHOP BY CATEGORY</span>
              <h2>Find what you're looking for</h2>
            </div>

            <a href="#products">View all →</a>
          </div>

          <div className="categories-grid">
            {categories.map((category) => (
              <div className="category-card" key={category.name}>
                <div>{category.icon}</div>
                <span>{category.name}</span>
              </div>
            ))}
          </div>
        </section>

        {/* PRODUCTS */}
        <section className="section products-section" id="products">
          <div className="section-title">
            <div>
              <span className="eyebrow">HANDPICKED FOR YOU</span>
              <h2>Featured Products</h2>
            </div>

            <a href="#products">View all products →</a>
          </div>
          <div className="product-grid">
            {loading && <p>Loading products...</p>}

            {error && <p>{error}</p>}

            {!loading && !error && products.map((product) => (
              <article className="product-card" key={product.id}>
                <div className="product-visual">
                  <span className="product-badge">{product.badge}</span>
                  <button className="wishlist">♡</button>
                  <div className="product-emoji">{product.icon}</div>
                </div>

                <div className="product-content">
                  <div className="product-meta">
                    <span>{product.category}</span>
                    <span>⭐ {product.rating}</span>
                  </div>

                  <h3>{product.name}</h3>

                  <div className="price-row">
                    <div>
                      <strong>₹{product.price.toLocaleString("en-IN")}</strong>
                      <del>₹{product.oldPrice.toLocaleString("en-IN")}</del>
                    </div>

                    <button className="add-cart" aria-label="Add to cart">
                      +
                    </button>
                  </div>
                </div>
              </article>
            ))}
          </div>
        </section>

        {/* PROMOTION */}
        <section className="promo-section">
          <div className="promo-content">
            <span>LIMITED TIME OFFER</span>

            <h2>
              Upgrade your everyday.
              <br />
              Save up to <strong>40%.</strong>
            </h2>

            <p>
              Discover selected products at special prices while the offer
              lasts.
            </p>

            <a href="#products">
              Explore Deals →
            </a>
          </div>

          <div className="promo-visual">
            <span>🛍️</span>
          </div>
        </section>

        {/* ABOUT */}
        <section className="about-section" id="about">
          <div className="about-heading">
            <span className="eyebrow">WHY SHOPSPHERE?</span>
            <h2>A better way to shop online.</h2>
            <p>
              ShopSphere combines quality products, simple shopping and
              dependable service into one modern experience.
            </p>
          </div>

          <div className="about-grid">
            <div>
              <span>✓</span>
              <h3>Quality First</h3>
              <p>Carefully selected products designed for everyday use.</p>
            </div>

            <div>
              <span>✓</span>
              <h3>Simple Shopping</h3>
              <p>A clean experience from discovering products to checkout.</p>
            </div>

            <div>
              <span>✓</span>
              <h3>Built to Scale</h3>
              <p>
                Powered by a modern containerized architecture built for
                reliability.
              </p>
            </div>
          </div>
        </section>

      </main>

      {/* FOOTER */}
      <footer className="footer">
        <div className="footer-main">
          <div className="footer-brand">
            <a className="brand footer-logo" href="#home">
              <span className="brand-icon">S</span>
              <span>ShopSphere</span>
            </a>

            <p>
              Making online shopping simpler, faster and more enjoyable.
            </p>
          </div>

          <div className="footer-column">
            <h4>Shop</h4>
            <a href="#products">Products</a>
            <a href="#categories">Categories</a>
            <a href="#products">New Arrivals</a>
          </div>

          <div className="footer-column">
            <h4>Company</h4>
            <a href="#about">About Us</a>
            <a href="#about">Contact</a>
            <a href="#about">Careers</a>
          </div>

          <div className="footer-column">
            <h4>Support</h4>
            <a href="#about">Help Center</a>
            <a href="#about">Returns</a>
            <a href="#about">Shipping</a>
          </div>
        </div>

        <div className="footer-bottom">
          <span>© 2026 ShopSphere. All rights reserved.</span>
          <span>Production E-Commerce Platform</span>
        </div>
      </footer>

    </div>
  );
}

export default App;