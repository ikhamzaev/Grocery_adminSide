-- Check the exact schema of the categories table
SELECT column_name, data_type, column_default, is_nullable, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'categories'
ORDER BY ordinal_position;

-- Check if there are any constraints
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'categories';

-- Check if there are any indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'categories';

-- Try a simple insert to test
INSERT INTO categories (name, description, icon, color, images, is_active, product_count, sort_order, created_at, updated_at)
VALUES ('Test Category', 'Test Description', 'test', '#FF0000', '[]', true, 0, 999, NOW(), NOW())
RETURNING *;