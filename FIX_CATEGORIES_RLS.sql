-- Check current RLS policies for categories table
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'categories';

-- Disable RLS on categories table (temporary fix)
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;

-- Alternative: Create proper RLS policies for anonymous users
-- Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow anonymous insert on categories" ON categories;
DROP POLICY IF EXISTS "Allow anonymous select on categories" ON categories;
DROP POLICY IF EXISTS "Allow anonymous update on categories" ON categories;
DROP POLICY IF EXISTS "Allow anonymous delete on categories" ON categories;

-- Create new policies for anonymous users
CREATE POLICY "Allow anonymous insert on categories" ON categories
FOR INSERT TO anon
WITH CHECK (true);

CREATE POLICY "Allow anonymous select on categories" ON categories
FOR SELECT TO anon
USING (true);

CREATE POLICY "Allow anonymous update on categories" ON categories
FOR UPDATE TO anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Allow anonymous delete on categories" ON categories
FOR DELETE TO anon
USING (true);

-- Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies 
WHERE tablename = 'categories';

