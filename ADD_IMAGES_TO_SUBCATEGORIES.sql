-- Add images column to subcategories table
-- This script adds image support to your existing subcategories table

-- Add the images column (JSONB array of image URLs)
ALTER TABLE public.subcategories 
ADD COLUMN IF NOT EXISTS images JSONB DEFAULT '[]'::jsonb;

-- Update existing subcategories to have empty images array if they don't have one
UPDATE public.subcategories 
SET images = '[]'::jsonb 
WHERE images IS NULL;

-- Make the images column NOT NULL with default empty array
ALTER TABLE public.subcategories 
ALTER COLUMN images SET NOT NULL,
ALTER COLUMN images SET DEFAULT '[]'::jsonb;

-- Add a comment to document the column
COMMENT ON COLUMN public.subcategories.images IS 'Array of image URLs for the subcategory';

-- Verify the column was added
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'subcategories' 
AND column_name = 'images';

-- Test the updated structure
SELECT id, name, images FROM public.subcategories LIMIT 3;

