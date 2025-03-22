-- AgriConnect Database Creation Script

-- Drop existing tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS donations;
DROP TABLE IF EXISTS ngos;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

-- Drop existing views
DROP VIEW IF EXISTS featured_farmers;
DROP VIEW IF EXISTS featured_products;

-- Drop existing functions and triggers
DROP FUNCTION IF EXISTS update_farmer_badge CASCADE;
DROP FUNCTION IF EXISTS update_target_rating CASCADE;
DROP FUNCTION IF EXISTS update_product_stock CASCADE;
DROP FUNCTION IF EXISTS generate_certificate_id CASCADE;
DROP PROCEDURE IF EXISTS create_order CASCADE;
DROP PROCEDURE IF EXISTS update_order_status CASCADE;

-- Create tables
-- 1. Users Table (for both Farmers and Consumers)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    phone_number VARCHAR(50),
    profile_image TEXT,
    role VARCHAR(20) NOT NULL, -- 'farmer' or 'consumer'
    address TEXT,
    rating DECIMAL(3, 2),
    total_ratings INTEGER DEFAULT 0,
    badge_type VARCHAR(20), -- 'orange', 'green', or NULL
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Products Table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    image_urls TEXT[], -- Array of image URLs
    harvest_date TIMESTAMP WITH TIME ZONE NOT NULL,
    best_before_date TIMESTAMP WITH TIME ZONE NOT NULL,
    rating DECIMAL(3, 2),
    total_ratings INTEGER DEFAULT 0,
    is_organic BOOLEAN DEFAULT TRUE,
    is_available BOOLEAN DEFAULT TRUE,
    category VARCHAR(50) NOT NULL, -- e.g., 'Vegetables', 'Fruits', etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Orders Table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
    delivery_address TEXT NOT NULL,
    contact_number VARCHAR(50) NOT NULL,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Order Items Table (for items in each order)
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    farmer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    price_per_unit DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Ratings Table (for both Farmers and Products)
CREATE TABLE ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- Consumer who gave the rating
    target_id UUID NOT NULL, -- Either farmer_id or product_id
    type VARCHAR(20) NOT NULL, -- 'farmer' or 'product'
    rating DECIMAL(3, 2) NOT NULL,
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. NGO Table (for donations)
CREATE TABLE ngos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    logo_url TEXT,
    website_url TEXT,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Donations Table
CREATE TABLE donations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    consumer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ngo_id UUID NOT NULL REFERENCES ngos(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    certificate_id VARCHAR(100) UNIQUE,
    donation_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX idx_products_farmer_id ON products(farmer_id);
CREATE INDEX idx_orders_consumer_id ON orders(consumer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_items_farmer_id ON order_items(farmer_id);
CREATE INDEX idx_ratings_user_id ON ratings(user_id);
CREATE INDEX idx_ratings_target_id ON ratings(target_id);
CREATE INDEX idx_donations_consumer_id ON donations(consumer_id);
CREATE INDEX idx_donations_ngo_id ON donations(ngo_id);

-- Create functions and triggers for database automation
-- 1. Function to update farmer badge based on rating
CREATE OR REPLACE FUNCTION update_farmer_badge()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the badge type based on the rating
    IF NEW.rating >= 4.6 THEN
        NEW.badge_type = 'green';  -- Green badge for ratings 4.6 and above
    ELSIF NEW.rating >= 4.0 THEN
        NEW.badge_type = 'orange'; -- Orange badge for ratings 4.0 to 4.5
    ELSE
        NEW.badge_type = NULL;     -- No badge for ratings below 4.0
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update the badge when a farmer's rating changes
CREATE OR REPLACE TRIGGER update_farmer_badge_trigger
BEFORE UPDATE OF rating ON users
FOR EACH ROW
WHEN (NEW.role = 'farmer')
EXECUTE FUNCTION update_farmer_badge();

-- 2. Function to update product/farmer rating when a new rating is added
CREATE OR REPLACE FUNCTION update_target_rating()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating DECIMAL(3,2);
    total_count INTEGER;
    target_table TEXT;
BEGIN
    -- Determine which table to update based on rating type
    IF NEW.type = 'farmer' THEN
        target_table := 'users';
    ELSE
        target_table := 'products';
    END IF;
    
    -- Calculate the new average rating and total count
    EXECUTE format('
        SELECT 
            ROUND(AVG(rating)::numeric, 2), 
            COUNT(*)
        FROM ratings 
        WHERE target_id = %L AND type = %L
    ', NEW.target_id, NEW.type) INTO avg_rating, total_count;
    
    -- Update the target with the new rating information
    EXECUTE format('
        UPDATE %I 
        SET rating = %L, total_ratings = %L, updated_at = NOW()
        WHERE id = %L
    ', target_table, avg_rating, total_count, NEW.target_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update target ratings when a new rating is added
CREATE OR REPLACE TRIGGER update_rating_trigger
AFTER INSERT OR UPDATE ON ratings
FOR EACH ROW
EXECUTE FUNCTION update_target_rating();

-- 3. Function to update product stock when an order is placed
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Reduce the product stock quantity
    UPDATE products
    SET 
        stock_quantity = stock_quantity - NEW.quantity,
        is_available = CASE WHEN (stock_quantity - NEW.quantity) > 0 THEN TRUE ELSE FALSE END,
        updated_at = NOW()
    WHERE id = NEW.product_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update product stock when a new order item is added
CREATE OR REPLACE TRIGGER update_product_stock_trigger
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();

-- 4. Function to generate a unique certificate ID for donations
CREATE OR REPLACE FUNCTION generate_certificate_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Generate a unique certificate ID for the donation
    NEW.certificate_id = 'DON-' || to_char(NEW.donation_date, 'YYYYMMDD') || '-' || substr(md5(random()::text), 1, 6);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically generate certificate ID for new donations
CREATE OR REPLACE TRIGGER generate_certificate_id_trigger
BEFORE INSERT ON donations
FOR EACH ROW
EXECUTE FUNCTION generate_certificate_id();

-- Create stored procedures for complex operations
-- 1. Procedure to handle the entire order creation process
CREATE OR REPLACE PROCEDURE create_order(
    p_consumer_id UUID,
    p_delivery_address TEXT,
    p_contact_number VARCHAR(50),
    p_items JSONB -- Array of {product_id, quantity} objects
)
LANGUAGE plpgsql
AS $$
DECLARE
    order_id UUID;
    item_record JSONB;
    product_record RECORD;
    total_amount DECIMAL(10, 2) := 0;
BEGIN
    -- Start transaction
    BEGIN
        -- Create the order
        INSERT INTO orders (
            consumer_id,
            total_amount, -- Will update this later
            delivery_address,
            contact_number,
            status
        ) VALUES (
            p_consumer_id,
            0, -- Placeholder value, will update after calculating the total
            p_delivery_address,
            p_contact_number,
            'pending'
        ) RETURNING id INTO order_id;
        
        -- Process each item in the order
        FOR item_record IN SELECT * FROM jsonb_array_elements(p_items)
        LOOP
            -- Get product info
            SELECT id, farmer_id, price, stock_quantity 
            INTO product_record
            FROM products
            WHERE id = (item_record->>'product_id')::UUID;
            
            -- Check if product exists and has enough stock
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Product with ID % not found', (item_record->>'product_id');
            END IF;
            
            IF product_record.stock_quantity < (item_record->>'quantity')::INTEGER THEN
                RAISE EXCEPTION 'Not enough stock for product %', (item_record->>'product_id');
            END IF;
            
            -- Add item to order
            INSERT INTO order_items (
                order_id,
                product_id,
                farmer_id,
                quantity,
                price_per_unit,
                subtotal
            ) VALUES (
                order_id,
                product_record.id,
                product_record.farmer_id,
                (item_record->>'quantity')::INTEGER,
                product_record.price,
                product_record.price * (item_record->>'quantity')::INTEGER
            );
            
            -- Update total amount
            total_amount := total_amount + (product_record.price * (item_record->>'quantity')::INTEGER);
        END LOOP;
        
        -- Update the order with the calculated total amount
        UPDATE orders
        SET total_amount = total_amount
        WHERE id = order_id;
        
        -- Commit the transaction
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Roll back the transaction in case of any error
            ROLLBACK;
            RAISE;
    END;
END;
$$;

-- 2. Procedure to update order status
CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id UUID,
    p_status VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check if status is valid
    IF p_status NOT IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled') THEN
        RAISE EXCEPTION 'Invalid order status: %', p_status;
    END IF;
    
    -- Update the order status
    UPDATE orders
    SET 
        status = p_status,
        updated_at = NOW()
    WHERE id = p_order_id;
    
    -- If order is cancelled, restore product quantities
    IF p_status = 'cancelled' THEN
        -- Restore product stock quantities
        UPDATE products p
        SET 
            stock_quantity = p.stock_quantity + oi.quantity,
            is_available = TRUE,
            updated_at = NOW()
        FROM order_items oi
        WHERE oi.order_id = p_order_id AND oi.product_id = p.id;
    END IF;
END;
$$;

-- Create views for frequently accessed data
-- 1. View for featured farmers (top rated farmers)
CREATE OR REPLACE VIEW featured_farmers AS
SELECT * FROM users
WHERE role = 'farmer' AND rating IS NOT NULL
ORDER BY rating DESC, total_ratings DESC
LIMIT 10;

-- 2. View for featured products (top rated products)
CREATE OR REPLACE VIEW featured_products AS
SELECT * FROM products
WHERE is_available = TRUE AND rating IS NOT NULL
ORDER BY rating DESC, total_ratings DESC
LIMIT 10;

-- Insert sample data for NGOs
INSERT INTO ngos (name, description, website_url, contact_email, contact_phone) VALUES
('Food For All', 'An organization dedicated to eliminating hunger by providing nutritious meals to those in need. We collect fresh produce from organic farmers and distribute it to underprivileged communities.', 'https://foodforall.org', 'contact@foodforall.org', '+91-9876543210'),

('Green Earth Initiative', 'We work towards sustainable farming practices and food security. Your donations help train marginalized farmers in organic farming techniques and provide them with resources.', 'https://greenearthinitiative.org', 'info@greenearthinitiative.org', '+91-8765432109'),

('Rural Development Trust', 'Focusing on rural development through agriculture, education, and healthcare. We support small-scale farmers with tools, seeds, and knowledge to improve their productivity and livelihoods.', 'https://ruraldevelopmenttrust.org', 'support@ruraldevelopmenttrust.org', '+91-7654321098');

-- Add table comment descriptions for documentation
COMMENT ON TABLE users IS 'Stores both farmer and consumer user details';
COMMENT ON TABLE products IS 'Stores organic product information listed by farmers';
COMMENT ON TABLE orders IS 'Stores order information placed by consumers';
COMMENT ON TABLE order_items IS 'Stores individual items within an order';
COMMENT ON TABLE ratings IS 'Stores ratings given by consumers to farmers or products';
COMMENT ON TABLE ngos IS 'Stores NGO information for donation purposes';
COMMENT ON TABLE donations IS 'Stores donation transactions made by consumers to NGOs';

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'AgriConnect database successfully created with all tables, functions, triggers, and sample data.';
END $$;