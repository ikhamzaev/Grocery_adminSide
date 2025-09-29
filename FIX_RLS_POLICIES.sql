-- Fix Row-Level Security Policies for Admin Dashboard
-- Run this SQL in your Supabase SQL Editor

-- First, let's check current RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('products', 'categories', 'subcategories', 'orders', 'customers', 'inventory_logs');

-- Disable RLS temporarily to allow admin operations
-- This allows anonymous users (admin dashboard) to perform CRUD operations

-- Products table
ALTER TABLE products DISABLE ROW LEVEL SECURITY;

-- Categories table  
ALTER TABLE categories DISABLE ROW LEVEL SECURITY;

-- Subcategories table
ALTER TABLE subcategories DISABLE ROW LEVEL SECURITY;

-- Orders table
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;

-- Customers table
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;

-- Inventory logs table
ALTER TABLE inventory_logs DISABLE ROW LEVEL SECURITY;

-- Alternative: If you want to keep RLS enabled but allow anonymous access,
-- you can use these policies instead of disabling RLS:

/*
-- Enable RLS but allow anonymous access
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_logs ENABLE ROW LEVEL SECURITY;

-- Create policies that allow anonymous users to perform all operations
CREATE POLICY "Allow anonymous access to products" ON products FOR ALL USING (true);
CREATE POLICY "Allow anonymous access to categories" ON categories FOR ALL USING (true);
CREATE POLICY "Allow anonymous access to subcategories" ON subcategories FOR ALL USING (true);
CREATE POLICY "Allow anonymous access to orders" ON orders FOR ALL USING (true);
CREATE POLICY "Allow anonymous access to customers" ON customers FOR ALL USING (true);
CREATE POLICY "Allow anonymous access to inventory_logs" ON inventory_logs FOR ALL USING (true);
*/

-- Verify RLS is disabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('products', 'categories', 'subcategories', 'orders', 'customers', 'inventory_logs');

