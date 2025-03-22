-- AgriConnect Database Queries

-- 1. Queries to get Featured Farmers (top rated farmers with badges)
-- Query for farmers with Green Badge (rating >= 4.6)
SELECT * FROM users
WHERE role = 'farmer' AND badge_type = 'green'
ORDER BY rating DESC, total_ratings DESC
LIMIT 5;

-- Query for farmers with Orange Badge (rating >= 4.0 and < 4.6)
SELECT * FROM users
WHERE role = 'farmer' AND badge_type = 'orange'
ORDER BY rating DESC, total_ratings DESC
LIMIT 5;

-- 2. Queries to get Featured Products (top rated products)
SELECT p.*, u.name as farmer_name, u.badge_type as farmer_badge
FROM products p
JOIN users u ON p.farmer_id = u.id
WHERE p.is_available = TRUE
ORDER BY p.rating DESC, p.total_ratings DESC
LIMIT 10;

-- 3. Query to get a Consumer's Orders
SELECT o.*, 
       u.name as farmer_name,
       u.badge_type as farmer_badge
FROM orders o
JOIN users u ON o.farmer_id = u.id
WHERE o.consumer_id = :consumer_id
ORDER BY o.order_date DESC;

-- 4. Query to get a Farmer's Orders
SELECT o.*, 
       u.name as consumer_name
FROM orders o
JOIN users u ON o.consumer_id = u.id
WHERE o.farmer_id = :farmer_id
ORDER BY o.order_date DESC;

-- 5. Query to get Product Details with Farmer Information
SELECT p.*, 
       u.name as farmer_name,
       u.rating as farmer_rating,
       u.badge_type as farmer_badge
FROM products p
JOIN users u ON p.farmer_id = u.id
WHERE p.id = :product_id;

-- 6. Query to get a Farmer's Products
SELECT * FROM products
WHERE farmer_id = :farmer_id
ORDER BY created_at DESC;

-- 7. Query to search Products
SELECT p.*, 
       u.name as farmer_name,
       u.badge_type as farmer_badge
FROM products p
JOIN users u ON p.farmer_id = u.id
WHERE p.is_available = TRUE 
  AND (p.name ILIKE '%' || :search_term || '%' OR 
       p.description ILIKE '%' || :search_term || '%')
ORDER BY 
  CASE WHEN p.name ILIKE :search_term || '%' THEN 1
       WHEN p.name ILIKE '%' || :search_term || '%' THEN 2
       ELSE 3
  END,
  p.rating DESC NULLS LAST;

-- 8. Query to get available NGOs for donation
SELECT * FROM ngos
ORDER BY name;

-- 9. Query to get User's Donations
SELECT d.*, n.name as ngo_name
FROM donations d
JOIN ngos n ON d.ngo_id = n.id
WHERE d.consumer_id = :consumer_id
ORDER BY d.donation_date DESC;

-- 10. Query to get Product Ratings
SELECT r.*, u.name as consumer_name, u.profile_image as consumer_image
FROM ratings r
JOIN users u ON r.user_id = u.id
WHERE r.target_id = :product_id AND r.type = 'product'
ORDER BY r.created_at DESC;

-- 11. Query to get Farmer Ratings
SELECT r.*, u.name as consumer_name, u.profile_image as consumer_image
FROM ratings r
JOIN users u ON r.user_id = u.id
WHERE r.target_id = :farmer_id AND r.type = 'farmer'
ORDER BY r.created_at DESC;

-- 12. Query to get a Farmer's Dashboard Statistics
SELECT 
  (SELECT COUNT(*) FROM products WHERE farmer_id = :farmer_id) as total_products,
  (SELECT COUNT(*) FROM products WHERE farmer_id = :farmer_id AND is_available = TRUE) as available_products,
  (SELECT COUNT(*) FROM order_items oi JOIN orders o ON oi.order_id = o.id WHERE oi.farmer_id = :farmer_id) as total_sales,
  (SELECT COUNT(*) FROM order_items oi JOIN orders o ON oi.order_id = o.id 
   WHERE oi.farmer_id = :farmer_id AND o.status = 'pending') as pending_orders,
  (SELECT COUNT(*) FROM order_items oi JOIN orders o ON oi.order_id = o.id 
   WHERE oi.farmer_id = :farmer_id AND o.status = 'delivered') as delivered_orders;

-- 13. Query to get a Consumer's Dashboard Statistics
SELECT 
  (SELECT COUNT(*) FROM orders WHERE consumer_id = :consumer_id) as total_orders,
  (SELECT COUNT(*) FROM orders WHERE consumer_id = :consumer_id AND status = 'pending') as pending_orders,
  (SELECT COUNT(*) FROM orders WHERE consumer_id = :consumer_id AND status = 'delivered') as delivered_orders,
  (SELECT COUNT(*) FROM donations WHERE consumer_id = :consumer_id) as total_donations;

-- 14. Query to get Products by Category
SELECT p.*, 
       u.name as farmer_name,
       u.badge_type as farmer_badge
FROM products p
JOIN users u ON p.farmer_id = u.id
WHERE p.category = :category AND p.is_available = TRUE
ORDER BY p.rating DESC NULLS LAST, p.created_at DESC;

-- 15. Query to get Recently Added Products
SELECT p.*, 
       u.name as farmer_name,
       u.badge_type as farmer_badge
FROM products p
JOIN users u ON p.farmer_id = u.id
WHERE p.is_available = TRUE
ORDER BY p.created_at DESC
LIMIT 10;

-- 16. Query to verify a Product with QR code
SELECT p.*, 
       u.name as farmer_name,
       u.rating as farmer_rating,
       u.badge_type as farmer_badge,
       u.phone_number as farmer_phone,
       u.address as farmer_address
FROM products p
JOIN users u ON p.farmer_id = u.id
WHERE p.id = :product_id;