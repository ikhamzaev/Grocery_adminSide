-- ============================================
-- PROFESSIONAL GROCERY DELIVERY APP DATABASE
-- ============================================
-- Based on the professional grocery app structure
-- Clean, organized, and scalable design

-- Drop existing tables if they exist (for clean rebuild)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS product_images CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS subcategories CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS inventory_logs CASCADE;

-- ============================================
-- 1. CATEGORIES TABLE
-- ============================================
-- Main categories like "Bread products", "Vegetables", "Fruits", "Dairy"
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    name_uz VARCHAR(100), -- Uzbek name (like "Нон махсулотлари")
    description TEXT,
    description_uz TEXT, -- Uzbek description
    icon VARCHAR(50) NOT NULL DEFAULT 'category',
    color VARCHAR(7) NOT NULL DEFAULT '#2196F3', -- Hex color
    image_url TEXT,
    banner_image_url TEXT, -- For category banners
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 1,
    product_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_category_sort_order UNIQUE (sort_order)
);

-- ============================================
-- 2. SUBCATEGORIES TABLE
-- ============================================
-- Sub-categories like "Greens/Herbs", "Cucumber and tomato"
CREATE TABLE subcategories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    name_uz VARCHAR(100), -- Uzbek name (like "Кукатлар")
    description TEXT,
    description_uz TEXT, -- Uzbek description
    icon VARCHAR(50) NOT NULL DEFAULT 'category',
    color VARCHAR(7) NOT NULL DEFAULT '#2196F3',
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 1,
    product_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_subcategory_sort_order UNIQUE (category_id, sort_order)
);

-- ============================================
-- 3. PRODUCTS TABLE
-- ============================================
-- Products with all the details from the professional app
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    subcategory_id UUID REFERENCES subcategories(id) ON DELETE SET NULL,
    
    -- Basic Info
    name VARCHAR(200) NOT NULL,
    name_uz VARCHAR(200), -- Uzbek name (like "Кук пиез")
    brand VARCHAR(100),
    description TEXT,
    description_uz TEXT, -- Uzbek description
    
    -- Pricing
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2), -- For sale items (like strikethrough price)
    unit VARCHAR(50) NOT NULL, -- "per lb", "each", "1 dona", etc.
    unit_uz VARCHAR(50), -- Uzbek unit
    
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
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    profile_image_url TEXT,
    
    -- Account Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    email_verified BOOLEAN NOT NULL DEFAULT false,
    phone_verified BOOLEAN NOT NULL DEFAULT false,
    
    -- Addresses (JSON array)
    addresses JSONB DEFAULT '[]',
    default_address_id UUID,
    
    -- Statistics
    total_orders INTEGER NOT NULL DEFAULT 0,
    total_spent DECIMAL(12,2) NOT NULL DEFAULT 0.0,
    average_order_value DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    last_order_date TIMESTAMP WITH TIME ZONE,
    
    -- Preferences
    preferred_categories JSONB DEFAULT '[]',
    preferred_delivery_times JSONB DEFAULT '[]',
    language_preference VARCHAR(5) DEFAULT 'en',
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE
);

-- ============================================
-- 6. ORDERS TABLE
-- ============================================
-- Order information
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(20) NOT NULL UNIQUE, -- Human-readable order number
    
    -- Customer Info
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    customer_name VARCHAR(200) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    
    -- Order Details
    subtotal DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Order Status
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, confirmed, preparing, out_for_delivery, delivered, cancelled
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending', -- pending, paid, failed, refunded
    payment_method VARCHAR(50) NOT NULL, -- card, cash, digital_wallet
    
    -- Delivery Info
    delivery_address JSONB NOT NULL,
    delivery_instructions TEXT,
    delivery_time_slot VARCHAR(50), -- "9:00-12:00", "12:00-15:00", etc.
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    
    -- Admin Notes
    admin_notes TEXT,
    
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
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    
    -- Product Info (snapshot at time of order)
    product_name VARCHAR(200) NOT NULL,
    product_image_url TEXT,
    unit VARCHAR(50) NOT NULL,
    price_per_unit DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
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
    change_type VARCHAR(20) NOT NULL, -- 'stock_in', 'stock_out', 'adjustment', 'sale', 'return'
    quantity_change INTEGER NOT NULL, -- Positive for stock in, negative for stock out
    previous_stock INTEGER NOT NULL,
    new_stock INTEGER NOT NULL,
    
    -- Reason
    reason VARCHAR(100),
    reference_id UUID, -- Order ID, adjustment ID, etc.
    reference_type VARCHAR(20), -- 'order', 'adjustment', 'manual'
    
    -- Admin Info
    admin_user_id UUID, -- If we add admin users later
    admin_notes TEXT,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Categories
CREATE INDEX idx_categories_sort_order ON categories(sort_order);
CREATE INDEX idx_categories_active ON categories(is_active);

-- Subcategories
CREATE INDEX idx_subcategories_category_id ON subcategories(category_id);
CREATE INDEX idx_subcategories_sort_order ON subcategories(category_id, sort_order);

-- Products
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_subcategory_id ON products(subcategory_id);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_products_featured ON products(is_featured);
CREATE INDEX idx_products_stock ON products(stock_count);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_created_at ON products(created_at);

-- Product Images
CREATE INDEX idx_product_images_product_id ON product_images(product_id);
CREATE INDEX idx_product_images_primary ON product_images(product_id, is_primary);

-- Orders
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_order_number ON orders(order_number);

-- Order Items
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Customers
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_customers_created_at ON customers(created_at);

-- Inventory Logs
CREATE INDEX idx_inventory_logs_product_id ON inventory_logs(product_id);
CREATE INDEX idx_inventory_logs_created_at ON inventory_logs(created_at);

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to all tables
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subcategories_updated_at BEFORE UPDATE ON subcategories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update product counts
CREATE OR REPLACE FUNCTION update_category_product_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE categories SET product_count = product_count + 1 WHERE id = NEW.category_id;
        IF NEW.subcategory_id IS NOT NULL THEN
            UPDATE subcategories SET product_count = product_count + 1 WHERE id = NEW.subcategory_id;
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE categories SET product_count = product_count - 1 WHERE id = OLD.category_id;
        IF OLD.subcategory_id IS NOT NULL THEN
            UPDATE subcategories SET product_count = product_count - 1 WHERE id = OLD.subcategory_id;
        END IF;
        RETURN OLD;
    ELSIF TG_OP = 'UPDATE' THEN
        -- Handle category changes
        IF OLD.category_id != NEW.category_id THEN
            UPDATE categories SET product_count = product_count - 1 WHERE id = OLD.category_id;
            UPDATE categories SET product_count = product_count + 1 WHERE id = NEW.category_id;
        END IF;
        -- Handle subcategory changes
        IF OLD.subcategory_id != NEW.subcategory_id THEN
            IF OLD.subcategory_id IS NOT NULL THEN
                UPDATE subcategories SET product_count = product_count - 1 WHERE id = OLD.subcategory_id;
            END IF;
            IF NEW.subcategory_id IS NOT NULL THEN
                UPDATE subcategories SET product_count = product_count + 1 WHERE id = NEW.subcategory_id;
            END IF;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ language 'plpgsql';

-- Apply product count triggers
CREATE TRIGGER update_category_product_count_trigger
    AFTER INSERT OR UPDATE OR DELETE ON products
    FOR EACH ROW EXECUTE FUNCTION update_category_product_count();

-- Function to update out_of_stock status
CREATE OR REPLACE FUNCTION update_out_of_stock_status()
RETURNS TRIGGER AS $$
BEGIN
    NEW.is_out_of_stock = (NEW.stock_count <= 0);
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply out of stock trigger
CREATE TRIGGER update_out_of_stock_trigger
    BEFORE INSERT OR UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_out_of_stock_status();

-- Function to generate order numbers
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_number = 'ORD-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(NEXTVAL('order_sequence')::TEXT, 4, '0');
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create sequence for order numbers
CREATE SEQUENCE IF NOT EXISTS order_sequence START 1;

-- Apply order number trigger
CREATE TRIGGER generate_order_number_trigger
    BEFORE INSERT ON orders
    FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
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

-- Create policies (allow all for admin dashboard - customize as needed)
CREATE POLICY "Allow all operations on categories" ON categories FOR ALL USING (true);
CREATE POLICY "Allow all operations on subcategories" ON subcategories FOR ALL USING (true);
CREATE POLICY "Allow all operations on products" ON products FOR ALL USING (true);
CREATE POLICY "Allow all operations on product_images" ON product_images FOR ALL USING (true);
CREATE POLICY "Allow all operations on customers" ON customers FOR ALL USING (true);
CREATE POLICY "Allow all operations on orders" ON orders FOR ALL USING (true);
CREATE POLICY "Allow all operations on order_items" ON order_items FOR ALL USING (true);
CREATE POLICY "Allow all operations on inventory_logs" ON inventory_logs FOR ALL USING (true);

-- ============================================
-- SAMPLE DATA (OPTIONAL)
-- ============================================

-- Insert sample categories
INSERT INTO categories (name, name_uz, description, icon, color, sort_order) VALUES
('Нон махсулотлари', 'Нон махсулотлари', 'Таза нон ва пештин махсулотлар', 'cake', '#FF9800', 1),
('Сабзавотлар', 'Сабзавотлар', 'Таза сабзавот ва кўкатлар', 'eco', '#4CAF50', 2),
('Мевалар', 'Мевалар', 'Таза мева ва жамлар', 'local_drink', '#2196F3', 3),
('Сут махсулотлари', 'Сут махсулотлари', 'Сут, пейнир, йогурт ва сут махсулотлари', 'kitchen', '#FF5722', 4),
('Болалар учун товарлар', 'Болалар учун товарлар', 'Болалар овқати, подгузник ва болалар парвариши', 'child_care', '#9C27B0', 5),
('Майонез ва Кетчуп', 'Майонез ва Кетчуп', 'Соус, майонез ва зираворлар', 'restaurant', '#795548', 6);

-- Insert sample subcategories
INSERT INTO subcategories (category_id, name, name_uz, description, icon, color, sort_order) VALUES
((SELECT id FROM categories WHERE name = 'Сабзавотлар'), 'Кукатлар', 'Кукатлар', 'Таза кўкат ва баргли сабзавотлар', 'eco', '#4CAF50', 1),
((SELECT id FROM categories WHERE name = 'Сабзавотлар'), 'Бодринг ва помидор', 'Бодринг ва помидор', 'Таза бодринг ва помидорлар', 'restaurant', '#FF5722', 2),
((SELECT id FROM categories WHERE name = 'Сабзавотлар'), 'Кундалик керак буладиган сабзавотлар', 'Кундалик керак буладиган сабзавотлар', 'Кундалик овқатланиш учун зарур сабзавотлар', 'kitchen', '#FF9800', 3);

-- Insert sample products (like the ones in your reference app)
INSERT INTO products (category_id, subcategory_id, name, name_uz, brand, description, description_uz, price, original_price, unit, unit_uz, stock_count, is_featured) VALUES
-- Green Onion (Кук пиез) - like in your reference app
((SELECT id FROM categories WHERE name = 'Сабзавотлар'), 
 (SELECT id FROM subcategories WHERE name = 'Кукатлар'),
 'Green Onion', 'Кук пиез', 'Таза Хавз', 'Fresh green onions for cooking', 'Овқатланиш учун таза кук пиез', 
 4000.00, 5000.00, 'bunch', '1 dona', 25, 
 true),

-- Dill (Ukrob) - like in your reference app  
((SELECT id FROM categories WHERE name = 'Сабзавотлар'), 
 (SELECT id FROM subcategories WHERE name = 'Кукатлар'),
 'Dill', 'Ukrob', 'Таза Хавз', 'Fresh dill for seasoning', 'Зираворлаш учун таза укроб', 
 3000.00, null, 'bunch', '1 dona', 15, 
 true),

-- Garlic (Саримсок) - like in your reference app
((SELECT id FROM categories WHERE name = 'Сабзавотлар'), 
 (SELECT id FROM subcategories WHERE name = 'Кукатлар'),
 'Garlic', 'Саримсок', 'Таза Хавз', 'Fresh garlic bulbs', 'Таза саримсок', 
 2500.00, null, 'head', '1 dona', 30, 
 false),

-- Parsley (Петрушка) - like in your reference app
((SELECT id FROM categories WHERE name = 'Сабзавотлар'), 
 (SELECT id FROM subcategories WHERE name = 'Кукатлар'),
 'Parsley', 'Петрушка', 'Таза Хавз', 'Fresh parsley leaves', 'Таза петрушка барглари', 
 3000.00, null, 'bunch', '1 dona', 20, 
 false),

-- Bread Products
((SELECT id FROM categories WHERE name = 'Нон махсулотлари'), 
 null,
 'White Bread', 'Оқ нон', 'Таза Нон', 'Fresh white bread', 'Таза оқ нон', 
 4500.00, null, 'loaf', '1 dona', 12, 
 true),

-- Dairy Products
((SELECT id FROM categories WHERE name = 'Сут махсулотлари'), 
 null,
 'Fresh Milk', 'Таза сут', 'Махсулот', 'Fresh whole milk', 'Таза сут', 
 8000.00, null, 'liter', '1 литр', 8, 
 true);

-- Insert product images separately
INSERT INTO product_images (product_id, image_url, alt_text, is_primary) VALUES
-- Green Onion images
((SELECT id FROM products WHERE name_uz = 'Кук пиез'), 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=compress&cs=tinysrgb&w=400', 'Кук пиез', true),

-- Dill images  
((SELECT id FROM products WHERE name_uz = 'Ukrob'), 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=compress&cs=tinysrgb&w=400', 'Укроб', true),

-- Garlic images
((SELECT id FROM products WHERE name_uz = 'Саримсок'), 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?auto=compress&cs=tinysrgb&w=400', 'Саримсок', true),

-- Parsley images
((SELECT id FROM products WHERE name_uz = 'Петрушка'), 'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=compress&cs=tinysrgb&w=400', 'Петрушка', true),

-- Bread images
((SELECT id FROM products WHERE name_uz = 'Оқ нон'), 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=compress&cs=tinysrgb&w=400', 'Оқ нон', true),

-- Milk images
((SELECT id FROM products WHERE name_uz = 'Таза сут'), 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=compress&cs=tinysrgb&w=400', 'Таза сут', true);

COMMIT;
