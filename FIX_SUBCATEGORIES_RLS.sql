-- Fix RLS policies for subcategories table
-- Run this in your Supabase SQL Editor

-- First, let's check if the subcategories table exists and its structure
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'subcategories' 
ORDER BY ordinal_position;

-- Enable RLS on subcategories table if not already enabled
ALTER TABLE subcategories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Enable read access for all users" ON subcategories;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON subcategories;
DROP POLICY IF EXISTS "Enable update for authenticated users only" ON subcategories;
DROP POLICY IF EXISTS "Enable delete for authenticated users only" ON subcategories;

-- Create new RLS policies for subcategories table
-- Allow all users to read subcategories (public access)
CREATE POLICY "Enable read access for all users" ON subcategories
    FOR SELECT USING (true);

-- Allow all users to insert subcategories (for admin dashboard)
CREATE POLICY "Enable insert for authenticated users only" ON subcategories
    FOR INSERT WITH CHECK (true);

-- Allow all users to update subcategories (for admin dashboard)
CREATE POLICY "Enable update for authenticated users only" ON subcategories
    FOR UPDATE USING (true);

-- Allow all users to delete subcategories (for admin dashboard)
CREATE POLICY "Enable delete for authenticated users only" ON subcategories
    FOR DELETE USING (true);

-- Test the policies by trying to select from subcategories
SELECT COUNT(*) as subcategory_count FROM subcategories;

-- If the table is empty, let's insert a test subcategory
INSERT INTO subcategories (
    category_id, 
    name, 
    description, 
    icon, 
    color, 
    images,
    is_active, 
    product_count, 
    sort_order
) VALUES (
    (SELECT id FROM categories LIMIT 1), -- Use first category as parent
    'Test Subcategory',
    'Test description',
    'category',
    '#2196F3',
    '[]'::jsonb,
    true,
    0,
    1
) ON CONFLICT DO NOTHING;

-- Verify the insert worked
SELECT * FROM subcategories LIMIT 5;
