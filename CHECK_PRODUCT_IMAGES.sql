-- Check if product images are being saved in the database
-- Run this SQL in your Supabase SQL Editor

-- Check the structure of the products table
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'products' 
AND column_name = 'images';

-- Check if any products have images
SELECT 
  id,
  name,
  images,
  created_at,
  updated_at
FROM products 
ORDER BY updated_at DESC 
LIMIT 10;

-- Check the most recent product with images
SELECT 
  id,
  name,
  images,
  array_length(images, 1) as image_count,
  created_at,
  updated_at
FROM products 
WHERE images IS NOT NULL 
  AND array_length(images, 1) > 0
ORDER BY updated_at DESC 
LIMIT 5;

