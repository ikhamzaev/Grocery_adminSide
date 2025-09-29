-- Add images column to categories table
ALTER TABLE categories 
ADD COLUMN IF NOT EXISTS images JSONB DEFAULT '[]';

-- Update existing categories to have empty images array
UPDATE categories 
SET images = '[]' 
WHERE images IS NULL;

-- Create index for images column for better performance
CREATE INDEX IF NOT EXISTS idx_categories_images ON categories USING GIN (images);

-- Verify the column was added
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'categories' 
AND column_name = 'images';

