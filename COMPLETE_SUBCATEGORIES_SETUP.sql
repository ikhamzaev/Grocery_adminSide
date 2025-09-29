-- Complete Subcategories Setup Script
-- This script sets up the subcategories table with images support and proper RLS policies

-- Step 1: Add images column to subcategories table (if it doesn't exist)
ALTER TABLE public.subcategories 
ADD COLUMN IF NOT EXISTS images JSONB DEFAULT '[]'::jsonb;

-- Step 2: Update existing subcategories to have empty images array if they don't have one
UPDATE public.subcategories 
SET images = '[]'::jsonb 
WHERE images IS NULL;

-- Step 3: Make the images column NOT NULL with default empty array
ALTER TABLE public.subcategories 
ALTER COLUMN images SET NOT NULL,
ALTER COLUMN images SET DEFAULT '[]'::jsonb;

-- Step 4: Add a comment to document the column
COMMENT ON COLUMN public.subcategories.images IS 'Array of image URLs for the subcategory';

-- Step 5: Enable RLS for the subcategories table
ALTER TABLE public.subcategories ENABLE ROW LEVEL SECURITY;

-- Step 6: Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Allow authenticated read access to subcategories" ON public.subcategories;
DROP POLICY IF EXISTS "Allow authenticated insert access to subcategories" ON public.subcategories;
DROP POLICY IF EXISTS "Allow authenticated update access to subcategories" ON public.subcategories;
DROP POLICY IF EXISTS "Allow authenticated delete access to subcategories" ON public.subcategories;

-- Step 7: Create RLS policies for authenticated users
CREATE POLICY "Allow authenticated read access to subcategories"
ON public.subcategories FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow authenticated insert access to subcategories"
ON public.subcategories FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow authenticated update access to subcategories"
ON public.subcategories FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow authenticated delete access to subcategories"
ON public.subcategories FOR DELETE
TO authenticated
USING (true);

-- Step 8: Test the setup
SELECT 'Setup completed successfully!' as status;

-- Step 9: Show current table structure
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'subcategories' 
ORDER BY ordinal_position;

-- Step 10: Show current policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'subcategories';

-- Step 11: Test insert (only if no subcategories exist)
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
) 
SELECT 
    c.id,
    'Test Subcategory',
    'This is a test subcategory for demonstration purposes.',
    'category',
    '#2196F3',
    '[]'::jsonb,
    true,
    0,
    1
FROM categories c
WHERE NOT EXISTS (SELECT 1 FROM subcategories LIMIT 1)
LIMIT 1;

-- Step 12: Verify the setup
SELECT COUNT(*) as total_subcategories FROM public.subcategories;
SELECT * FROM public.subcategories LIMIT 3;

