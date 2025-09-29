# How to Test Subcategory Functionality

## The Issue
You don't see the subcategory dropdown when adding products because there are no subcategories created yet.

## Solution Steps

### Step 1: Create Subcategories First
1. Open the admin dashboard
2. Go to Categories
3. **Long press** on any category (e.g., "Мевалар ва сабзавотлар")
4. Select "Manage Subcategories"
5. Add some subcategories like:
   - Помидор (Tomatoes)
   - Кук пиез (Green Peas)  
   - Саримсок (Garlic)

### Step 2: Add Products with Subcategories
1. Go to Products
2. Click "Add Product"
3. Select a category (e.g., "Мевалар ва сабзавотлар")
4. **Now you'll see the subcategory dropdown appear!**
5. Select a subcategory (e.g., "Помидор")
6. Fill in product details and save

## What You'll See

### Before Creating Subcategories:
- Category dropdown: ✅ Visible
- Subcategory dropdown: ❌ Hidden (because no subcategories exist)

### After Creating Subcategories:
- Category dropdown: ✅ Visible  
- Subcategory dropdown: ✅ Visible (with your created subcategories)

## Example Flow:
1. **Category**: "Мевалар ва сабзавотлар" (Fruits & Vegetables)
2. **Subcategory**: "Помидор" (Tomatoes) ← This appears after you create it
3. **Product**: "Черри помидор" (Cherry Tomatoes)

## The Logic:
- Subcategory dropdown only shows when subcategories exist for the selected category
- This prevents empty dropdowns and keeps the UI clean
- You can still add products to just categories (without subcategories)

## Test This:
1. Create subcategories first
2. Then add products - you'll see the subcategory option!

