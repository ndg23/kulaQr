-- Migration: Add staff_id to orders table
-- This script adds the staff_id column to link orders with staff members

-- Add staff_id column to orders table
ALTER TABLE orders ADD COLUMN IF NOT EXISTS staff_id UUID REFERENCES staff(id) ON DELETE SET NULL;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_orders_staff_id ON orders(staff_id);

-- Update RLS policies to allow staff assignment
-- This policy allows managers to assign orders to staff members
CREATE POLICY "Allow staff assignment by managers" ON orders
    FOR UPDATE USING (
        auth.uid() IN (
            SELECT user_id FROM establishments WHERE id = orders.establishment_id
        ) OR is_admin_user()
    );

-- Add comment to document the change
COMMENT ON COLUMN orders.staff_id IS 'ID of the staff member who processed this order';