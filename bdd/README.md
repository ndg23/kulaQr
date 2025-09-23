# 🗄️ Kula QR Database

This directory contains the essential database files for the Kula QR application.

## 📁 Files Structure

### Core Files
- **`schema.sql`** - Complete database schema with tables, indexes, functions, triggers, and RLS policies
- **`seeds.sql`** - Initial seed data (establishment types and utility functions)
- **`README.md`** - This documentation file

## 🚀 Setup Instructions

### 1. Complete Setup (Recommended)
Execute in your Supabase SQL Editor in this order:

```sql
-- 1. Create complete database structure
\i schema.sql

-- 2. Insert initial data
\i seeds.sql
```

### 2. Alternative: Manual Steps
1. Copy the contents of `schema.sql` into Supabase SQL Editor and run
2. Copy the contents of `seeds.sql` into Supabase SQL Editor and run

## 🏗️ Database Structure

### Core Tables
- **`users`** - User accounts and profiles
- **`establishment_types`** - Types of restaurants/establishments
- **`establishments`** - Restaurant/business information
- **`staff`** - Staff members with PIN authentication
- **`categories`** - Menu categories
- **`products`** - Menu items/products
- **`restaurant_tables`** - Physical tables in restaurants
- **`orders`** - Customer orders
- **`order_items`** - Individual items in orders
- **`qr_codes`** - QR code management
- **`qr_scans`** - QR code scan tracking
- **`staff_activity_logs`** - Staff activity monitoring

### Key Features
- ✅ **Row Level Security (RLS)** enabled on all tables
- ✅ **Automatic timestamps** with triggers
- ✅ **Slug generation** for establishments
- ✅ **Product counting** in categories
- ✅ **Table status management** based on orders
- ✅ **Admin user support** with override permissions
- ✅ **Anonymous order creation** for customers
- ✅ **Performance indexes** on all key fields

### Views
- **`dashboard_stats`** - Daily order statistics
- **`popular_establishments`** - Top performing restaurants
- **`table_statistics`** - Table usage analytics

## 🔒 Security

The database implements comprehensive Row Level Security:

- **Users** can only access their own data
- **Establishment owners** can manage their restaurants
- **Staff members** can access their establishment's data
- **Admins** have full access to everything
- **Anonymous users** can create orders and scan QR codes

## 🛠️ Utility Functions

- **`is_admin_user()`** - Check if user has admin privileges
- **`generate_sample_orders()`** - Generate test orders for development

## 📊 Performance

All tables include appropriate indexes for:
- Foreign key relationships
- Frequently queried fields
- Date-based queries
- Status-based filtering

## 🔄 Maintenance

The database is designed to be self-maintaining with:
- Automatic timestamp updates
- Cascading deletes for data integrity
- Product count synchronization
- Table status automation

## 🧪 Development

For development and testing:
```sql
-- Generate sample orders for an establishment
SELECT generate_sample_orders('establishment-uuid-here', 50);
```

## ⚠️ Important Notes

1. **Always backup** your database before making changes
2. **Test in development** environment first
3. **RLS policies** are enforced - ensure proper user authentication
4. **Foreign keys** maintain data integrity - respect the relationships
5. **Indexes** are optimized for the application's query patterns

## 🆘 Troubleshooting

If you encounter issues:
1. Check Supabase logs for specific errors
2. Verify user authentication is working
3. Ensure RLS policies match your use case
4. Check foreign key constraints

## 📈 Monitoring

Key metrics to monitor:
- Order creation rate
- QR scan frequency
- User registration trends
- Table utilization
- Product popularity

---

*This database structure supports the complete Kula QR restaurant management system with QR code menus, order management, and staff coordination.*
