-- ============================================
-- CLEAN UZBEK-ONLY GROCERY STORE DATABASE SCHEMA
-- ============================================
-- This schema is designed for Uzbek-only content
-- All product names, descriptions, and units are in Uzbek language

-- ============================================
-- 1. CATEGORIES TABLE (Uzbek-only)
-- ============================================
-- Categories for organizing products
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Info (Uzbek only)
    name VARCHAR(200) NOT NULL, -- Uzbek name like "Мевалар ва сабзавотлар"
    description TEXT, -- Uzbek description
    
    -- Visual
    icon VARCHAR(50) DEFAULT 'category',
    color VARCHAR(20) DEFAULT '#2196F3',
    image_url TEXT,
    banner_image_url TEXT,
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    product_count INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_category_sort_order UNIQUE (sort_order)
);

-- ============================================
-- 2. SUBCATEGORIES TABLE (Uzbek-only)
-- ============================================
-- Subcategories for better organization
CREATE TABLE subcategories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    
    -- Basic Info (Uzbek only)
    name VARCHAR(200) NOT NULL, -- Uzbek name like "Янги мевалар"
    description TEXT, -- Uzbek description
    
    -- Visual
    icon VARCHAR(50) DEFAULT 'subcategory',
    color VARCHAR(20) DEFAULT '#FF9800',
    image_url TEXT,
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    product_count INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_subcategory_sort_order UNIQUE (category_id, sort_order)
);

-- ============================================
-- 3. PRODUCTS TABLE (Uzbek-only)
-- ============================================
-- Products with all details in Uzbek language
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    subcategory_id UUID REFERENCES subcategories(id) ON DELETE SET NULL,
    
    -- Basic Info (Uzbek only)
    name VARCHAR(200) NOT NULL, -- Uzbek name like "Кук пиез"
    brand VARCHAR(100),
    description TEXT, -- Uzbek description
    
    -- Pricing
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2), -- For sale items (like strikethrough price)
    unit VARCHAR(50) NOT NULL, -- Uzbek unit like "1 кг", "1 дона"
    
    -- Stock & Inventory
    stock_count INTEGER NOT NULL DEFAULT 0,
    min_stock_level INTEGER NOT NULL DEFAULT 5,
    max_stock_level INTEGER,
    
    -- Product Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_featured BOOLEAN NOT NULL DEFAULT false,
    is_on_sale BOOLEAN NOT NULL DEFAULT false,
    is_out_of_stock BOOLEAN NOT NULL DEFAULT false,
    
    -- Ratings & Reviews
    rating DECIMAL(3,2) NOT NULL DEFAULT 0.0,
    review_count INTEGER NOT NULL DEFAULT 0,
    
    -- Nutrition Information (JSON)
    nutrition JSONB DEFAULT '{}',
    
    -- Product Details (JSON)
    ingredients JSONB DEFAULT '[]',
    storage_instructions JSONB DEFAULT '{}',
    product_details JSONB DEFAULT '{}',
    
    -- SEO & Marketing
    tags JSONB DEFAULT '[]',
    meta_title VARCHAR(200),
    meta_description TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- ============================================
-- 4. PRODUCT_IMAGES TABLE
-- ============================================
-- Separate table for product images (multiple images per product)
CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    alt_text VARCHAR(200),
    sort_order INTEGER NOT NULL DEFAULT 1,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- ============================================
-- 5. CUSTOMERS TABLE
-- ============================================
-- Customer information
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Personal Info
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) NOT NULL,
    
    -- Address Info
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Uzbekistan',
    
    -- Customer Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    
    -- Preferences
    preferred_language VARCHAR(10) DEFAULT 'uz',
    notification_preferences JSONB DEFAULT '{}',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- ============================================
-- 6. ORDERS TABLE
-- ============================================
-- Order information
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id),
    
    -- Order Info
    order_number VARCHAR(50) UNIQUE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, confirmed, preparing, ready, delivered, cancelled
    
    -- Pricing
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    
    -- Delivery Info
    delivery_address TEXT NOT NULL,
    delivery_phone VARCHAR(20),
    delivery_instructions TEXT,
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    
    -- Payment Info
    payment_method VARCHAR(50), -- cash, card, mobile
    payment_status VARCHAR(50) DEFAULT 'pending', -- pending, paid, failed, refunded
    payment_reference VARCHAR(100),
    
    -- Order Details
    notes TEXT,
    promo_code VARCHAR(50),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- ============================================
-- 7. ORDER_ITEMS TABLE
-- ============================================
-- Individual items in each order
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    
    -- Item Details
    product_name VARCHAR(200) NOT NULL, -- Snapshot of product name at time of order
    product_unit VARCHAR(50) NOT NULL, -- Snapshot of unit at time of order
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL, -- Snapshot of price at time of order
    total_price DECIMAL(10,2) NOT NULL,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- ============================================
-- 8. INVENTORY_LOGS TABLE
-- ============================================
-- Track inventory changes
CREATE TABLE inventory_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    
    -- Change Details
    change_type VARCHAR(50) NOT NULL, -- stock_in, stock_out, adjustment, sale, return
    quantity_change INTEGER NOT NULL, -- Positive for additions, negative for subtractions
    quantity_before INTEGER NOT NULL,
    quantity_after INTEGER NOT NULL,
    
    -- Reference Info
    order_id UUID REFERENCES orders(id),
    reference_number VARCHAR(100),
    notes TEXT,
    
    -- User Info
    changed_by VARCHAR(100), -- Admin user who made the change
    reason VARCHAR(200),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Categories indexes
CREATE INDEX idx_categories_active ON categories(is_active);
CREATE INDEX idx_categories_sort_order ON categories(sort_order);

-- Subcategories indexes
CREATE INDEX idx_subcategories_category_id ON subcategories(category_id);
CREATE INDEX idx_subcategories_active ON subcategories(is_active);

-- Products indexes
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_subcategory_id ON products(subcategory_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_products_on_sale ON products(is_on_sale);
CREATE INDEX idx_products_stock ON products(stock_count);
CREATE INDEX idx_products_created_at ON products(created_at);

-- Product images indexes
CREATE INDEX idx_product_images_product_id ON product_images(product_id);
CREATE INDEX idx_product_images_primary ON product_images(is_primary);

-- Customers indexes
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_active ON customers(is_active);

-- Orders indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_order_number ON orders(order_number);

-- Order items indexes
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Inventory logs indexes
CREATE INDEX idx_inventory_logs_product_id ON inventory_logs(product_id);
CREATE INDEX idx_inventory_logs_created_at ON inventory_logs(created_at);
CREATE INDEX idx_inventory_logs_change_type ON inventory_logs(change_type);

-- ============================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to all tables
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subcategories_updated_at BEFORE UPDATE ON subcategories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- SAMPLE DATA (Uzbek-only)
-- ============================================

-- Insert sample categories
INSERT INTO categories (name, description, icon, color, sort_order) VALUES
('Мевалар ва сабзавотлар', 'Тоза мевалар ва сабзавотлар', 'apple', '#4CAF50', 1),
('Гўшт ва балиқ', 'Саховатли гўшт ва балиқ маҳсулотлари', 'restaurant', '#F44336', 2),
('Сут ва сут маҳсулотлари', 'Табиий сут ва сут маҳсулотлари', 'local_drink', '#2196F3', 3),
('Нон ва бекон', 'Таза нон ва бекон маҳсулотлари', 'bakery_dining', '#FF9800', 4),
('Ичимликлар', 'Табиий ичимликлар ва сувлар', 'local_bar', '#9C27B0', 5);

-- Insert sample products
INSERT INTO products (category_id, name, brand, description, price, unit, stock_count, rating, review_count, is_featured) 
SELECT 
    c.id,
    'Кук пиез',
    'Махаллий',
    'Таза ва ширин кук пиез',
    15000.00,
    '1 кг',
    50,
    4.5,
    12,
    true
FROM categories c WHERE c.name = 'Мевалар ва сабзавотлар';

INSERT INTO products (category_id, name, brand, description, price, unit, stock_count, rating, review_count, is_featured) 
SELECT 
    c.id,
    'Киви',
    'Импорт',
    'Таза ва витаминли киви',
    25000.00,
    '1 кг',
    30,
    4.8,
    8,
    true
FROM categories c WHERE c.name = 'Мевалар ва сабзавотлар';

INSERT INTO products (category_id, name, brand, description, price, unit, stock_count, rating, review_count, is_on_sale) 
SELECT 
    c.id,
    'Мол гўшти',
    'Махаллий',
    'Тоза ва саховатли мол гўшти',
    45000.00,
    '1 кг',
    25,
    4.7,
    15,
    true
FROM categories c WHERE c.name = 'Гўшт ва балиқ';

INSERT INTO products (category_id, name, brand, description, price, unit, stock_count, rating, review_count, is_active) 
SELECT 
    c.id,
    'Тоза сут',
    'Махаллий',
    'Табиий ва тоза сут',
    8000.00,
    '1 литр',
    100,
    4.6,
    25,
    false
FROM categories c WHERE c.name = 'Сут ва сут маҳсулотлари';

-- ============================================
-- STORAGE BUCKETS SETUP
-- ============================================
-- Note: These need to be created in Supabase Storage section
-- Bucket names: 'product-images', 'category-images'
-- Make them public for web access

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_logs ENABLE ROW LEVEL SECURITY;

-- Allow public read access to categories and products (for customer app)
CREATE POLICY "Allow public read access to categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Allow public read access to subcategories" ON subcategories FOR SELECT USING (true);
CREATE POLICY "Allow public read access to products" ON products FOR SELECT USING (true);
CREATE POLICY "Allow public read access to product_images" ON product_images FOR SELECT USING (true);

-- Allow authenticated users to manage all data (for admin dashboard)
CREATE POLICY "Allow authenticated users to manage categories" ON categories FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage subcategories" ON subcategories FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage products" ON products FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage product_images" ON product_images FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage customers" ON customers FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage orders" ON orders FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage order_items" ON order_items FOR ALL USING (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated users to manage inventory_logs" ON inventory_logs FOR ALL USING (auth.role() = 'authenticated');

-- ============================================
-- VIEWS FOR EASY QUERYING
-- ============================================

-- Products with category names
CREATE VIEW products_with_categories AS
SELECT 
    p.*,
    c.name as category_name,
    c.color as category_color
FROM products p
LEFT JOIN categories c ON p.category_id = c.id;

-- Orders with customer info
CREATE VIEW orders_with_customers AS
SELECT 
    o.*,
    c.first_name,
    c.last_name,
    c.email,
    c.phone
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id;

-- ============================================
-- COMPLETION MESSAGE
-- ============================================
-- Schema created successfully! 
-- All tables are now Uzbek-only with no duplicate English fields.
-- Ready for the admin dashboard to connect and work properly.
