-- Add images column to products table
-- Run this SQL in your Supabase SQL Editor

-- Add images column to products table
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS images JSONB DEFAULT '[]';

-- Update existing products to have empty images array
UPDATE products 
SET images = '[]' 
WHERE images IS NULL;

-- Create index for images column for better performance
CREATE INDEX IF NOT EXISTS idx_products_images ON products USING GIN (images);

