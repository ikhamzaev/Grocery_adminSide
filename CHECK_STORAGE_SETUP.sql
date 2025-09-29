-- Check and Setup Supabase Storage for Image Uploads
-- Run this SQL in your Supabase SQL Editor

-- 1. Check if storage buckets exist
SELECT name, public FROM storage.buckets WHERE name IN ('product-images', 'category-images');

-- 2. Create storage buckets if they don't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('product-images', 'product-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']),
  ('category-images', 'category-images', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- 3. Create storage policies to allow anonymous uploads
-- Drop existing policies first
DROP POLICY IF EXISTS "Allow anonymous uploads to product-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow anonymous uploads to category-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow anonymous downloads from product-images" ON storage.objects;
DROP POLICY IF EXISTS "Allow anonymous downloads from category-images" ON storage.objects;

-- Create new policies for product-images bucket
CREATE POLICY "Allow anonymous uploads to product-images" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Allow anonymous downloads from product-images" ON storage.objects
  FOR SELECT USING (bucket_id = 'product-images');

CREATE POLICY "Allow anonymous updates to product-images" ON storage.objects
  FOR UPDATE USING (bucket_id = 'product-images');

CREATE POLICY "Allow anonymous deletes from product-images" ON storage.objects
  FOR DELETE USING (bucket_id = 'product-images');

-- Create new policies for category-images bucket
CREATE POLICY "Allow anonymous uploads to category-images" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'category-images');

CREATE POLICY "Allow anonymous downloads from category-images" ON storage.objects
  FOR SELECT USING (bucket_id = 'category-images');

CREATE POLICY "Allow anonymous updates to category-images" ON storage.objects
  FOR UPDATE USING (bucket_id = 'category-images');

CREATE POLICY "Allow anonymous deletes from category-images" ON storage.objects
  FOR DELETE USING (bucket_id = 'category-images');

-- 4. Verify the setup
SELECT 
  b.name as bucket_name,
  b.public,
  b.file_size_limit,
  b.allowed_mime_types,
  COUNT(p.id) as policy_count
FROM storage.buckets b
LEFT JOIN pg_policies p ON p.tablename = 'objects' AND p.policyname LIKE '%' || b.name || '%'
WHERE b.name IN ('product-images', 'category-images')
GROUP BY b.name, b.public, b.file_size_limit, b.allowed_mime_types
ORDER BY b.name;

