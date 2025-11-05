-- ==========================================
-- QR SUPPORT REQUESTS SCHEMA
-- ==========================================
-- Table for managing QR code support requests from managers
-- This file can be executed independently after the main schema

-- Ensure the update_updated_at function exists (create if not exists)
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Ensure the is_admin_user function exists (create if not exists)
CREATE OR REPLACE FUNCTION is_admin_user(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Quick check to avoid unnecessary queries
    IF user_uuid IS NULL THEN
        RETURN FALSE;
    END IF;

    RETURN EXISTS (
        SELECT 1 FROM users
        WHERE id = user_uuid AND role = 'admin'
    );
END;
$$;

-- Check if required tables exist before creating qr_support_requests
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'establishments') THEN
        RAISE EXCEPTION 'Table establishments does not exist. Please run schema.sql first.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'auth' AND table_name = 'users') THEN
        RAISE EXCEPTION 'Auth users table does not exist. Please ensure Supabase auth is set up.';
    END IF;
END $$;

-- Create qr_support_requests table
CREATE TABLE qr_support_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Request details
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    requested_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    request_type TEXT NOT NULL CHECK (request_type IN ('new_qr', 'qr_replacement', 'qr_update', 'qr_deactivation', 'bulk_qr_generation', 'qr_customization', 'technical_issue')),
    table_number INTEGER,
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),

    -- Status tracking
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled', 'rejected')),
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,

    -- Resolution details
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    resolution_notes TEXT,

    -- Additional metadata
    attachments JSONB DEFAULT '[]', -- Array of file URLs/paths
    internal_notes TEXT,
    estimated_completion TIMESTAMP WITH TIME ZONE
);

-- Create indexes for performance
CREATE INDEX idx_qr_support_requests_establishment_id ON qr_support_requests(establishment_id);
CREATE INDEX idx_qr_support_requests_requested_by ON qr_support_requests(requested_by);
CREATE INDEX idx_qr_support_requests_status ON qr_support_requests(status);
CREATE INDEX idx_qr_support_requests_priority ON qr_support_requests(priority);
CREATE INDEX idx_qr_support_requests_created_at ON qr_support_requests(created_at);
CREATE INDEX idx_qr_support_requests_assigned_to ON qr_support_requests(assigned_to);

-- Create updated_at trigger
CREATE TRIGGER qr_support_requests_updated_at
    BEFORE UPDATE ON qr_support_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Create function to update resolved_at automatically
CREATE OR REPLACE FUNCTION update_qr_support_request_resolution()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IN ('completed', 'cancelled', 'rejected') AND OLD.status NOT IN ('completed', 'cancelled', 'rejected') THEN
        NEW.resolved_at = CURRENT_TIMESTAMP;
        NEW.resolved_by = auth.uid();
    ELSIF NEW.status NOT IN ('completed', 'cancelled', 'rejected') AND OLD.status IN ('completed', 'cancelled', 'rejected') THEN
        NEW.resolved_at = NULL;
        NEW.resolved_by = NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic resolution timestamp
CREATE TRIGGER qr_support_request_resolution_trigger
    BEFORE UPDATE ON qr_support_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_qr_support_request_resolution();

-- Enable RLS
ALTER TABLE qr_support_requests ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Managers can view their own establishment's requests
CREATE POLICY "Managers can view their establishment requests" ON qr_support_requests
    FOR SELECT USING (
        establishment_id IN (
            SELECT id FROM establishments
            WHERE user_id = auth.uid() OR owner_id = auth.uid() OR created_by = auth.uid()
        ) OR requested_by = auth.uid()
    );

-- Managers can create requests for their establishments
CREATE POLICY "Managers can create support requests" ON qr_support_requests
    FOR INSERT WITH CHECK (
        establishment_id IN (
            SELECT id FROM establishments
            WHERE user_id = auth.uid() OR owner_id = auth.uid() OR created_by = auth.uid()
        ) AND requested_by = auth.uid()
    );

-- Managers can update their own requests (limited fields)
CREATE POLICY "Managers can update their own requests" ON qr_support_requests
    FOR UPDATE
    USING (requested_by = auth.uid() AND status = 'pending')
    WITH CHECK (requested_by = auth.uid() AND status IN ('pending', 'cancelled'));

-- Admins can manage all requests
CREATE POLICY "Admins can manage all QR support requests" ON qr_support_requests
    FOR ALL USING (is_admin_user());

-- Create view for support dashboard
CREATE OR REPLACE VIEW qr_support_dashboard AS
SELECT
    qsr.*,
    e.name as establishment_name,
    e.slug as establishment_slug,
    rb.full_name as requested_by_name,
    ab.full_name as assigned_to_name,
    rb2.full_name as resolved_by_name,
    CASE
        WHEN qsr.status = 'pending' AND qsr.priority = 'urgent' THEN 1
        WHEN qsr.status = 'pending' AND qsr.priority = 'high' THEN 2
        WHEN qsr.status = 'in_progress' THEN 3
        WHEN qsr.status = 'pending' AND qsr.priority = 'medium' THEN 4
        WHEN qsr.status = 'pending' AND qsr.priority = 'low' THEN 5
        ELSE 6
    END as priority_order
FROM qr_support_requests qsr
LEFT JOIN establishments e ON e.id = qsr.establishment_id
LEFT JOIN users rb ON rb.id = qsr.requested_by
LEFT JOIN users ab ON ab.id = qsr.assigned_to
LEFT JOIN users rb2 ON rb2.id = qsr.resolved_by
ORDER BY priority_order ASC, qsr.created_at DESC;

-- Create function to get support requests with user details
CREATE OR REPLACE FUNCTION get_qr_support_requests_with_users(
    establishment_filter UUID DEFAULT NULL,
    status_filter TEXT DEFAULT NULL,
    limit_count INTEGER DEFAULT 50,
    offset_count INTEGER DEFAULT 0
)
RETURNS TABLE (
    id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    establishment_id UUID,
    requested_by UUID,
    request_type TEXT,
    table_number INTEGER,
    title TEXT,
    description TEXT,
    priority TEXT,
    status TEXT,
    assigned_to UUID,
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID,
    resolution_notes TEXT,
    attachments JSONB,
    internal_notes TEXT,
    estimated_completion TIMESTAMP WITH TIME ZONE,
    establishment_name TEXT,
    establishment_slug TEXT,
    requested_by_name TEXT,
    assigned_to_name TEXT,
    resolved_by_name TEXT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    RETURN QUERY
    SELECT
        qsr.id,
        qsr.created_at,
        qsr.updated_at,
        qsr.establishment_id,
        qsr.requested_by,
        qsr.request_type,
        qsr.table_number,
        qsr.title,
        qsr.description,
        qsr.priority,
        qsr.status,
        qsr.assigned_to,
        qsr.resolved_at,
        qsr.resolved_by,
        qsr.resolution_notes,
        qsr.attachments,
        qsr.internal_notes,
        qsr.estimated_completion,
        e.name as establishment_name,
        e.slug as establishment_slug,
        rb.full_name as requested_by_name,
        ab.full_name as assigned_to_name,
        rb2.full_name as resolved_by_name
    FROM qr_support_requests qsr
    LEFT JOIN establishments e ON e.id = qsr.establishment_id
    LEFT JOIN users rb ON rb.id = qsr.requested_by
    LEFT JOIN users ab ON ab.id = qsr.assigned_to
    LEFT JOIN users rb2 ON rb2.id = qsr.resolved_by
    WHERE (establishment_filter IS NULL OR qsr.establishment_id = establishment_filter)
    AND (status_filter IS NULL OR qsr.status = status_filter)
    AND (
        -- Admins can see all
        (SELECT role FROM users WHERE id = auth.uid()) = 'admin'
        OR
        -- Managers can see their establishment's requests
        qsr.establishment_id IN (
            SELECT id FROM establishments
            WHERE user_id = auth.uid() OR owner_id = auth.uid() OR created_by = auth.uid()
        )
        OR
        -- Users can see their own requests
        qsr.requested_by = auth.uid()
    )
    ORDER BY qsr.created_at DESC
    LIMIT limit_count
    OFFSET offset_count;
END;
$$;
CREATE OR REPLACE FUNCTION get_qr_support_stats(establishment_uuid UUID DEFAULT NULL)
RETURNS TABLE (
    total_requests BIGINT,
    pending_requests BIGINT,
    in_progress_requests BIGINT,
    completed_requests BIGINT,
    avg_resolution_time INTERVAL,
    urgent_requests BIGINT
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) as total_requests,
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_requests,
        COUNT(CASE WHEN status = 'in_progress' THEN 1 END) as in_progress_requests,
        COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_requests,
        AVG(
            CASE
                WHEN status IN ('completed', 'cancelled') AND resolved_at IS NOT NULL
                THEN resolved_at - created_at
            END
        ) as avg_resolution_time,
        COUNT(
            CASE
                WHEN priority = 'urgent' AND status NOT IN ('completed', 'cancelled', 'rejected')
                THEN 1
            END
        ) as urgent_requests
    FROM qr_support_requests
    WHERE (establishment_uuid IS NULL OR establishment_id = establishment_uuid);
END;
$$;

-- Insert some sample data for testing (optional)
-- This will be removed in production
INSERT INTO qr_support_requests (
    establishment_id,
    requested_by,
    request_type,
    table_number,
    title,
    description,
    priority,
    status
) VALUES (
    (SELECT id FROM establishments LIMIT 1),
    (SELECT id FROM users WHERE role = 'owner' LIMIT 1),
    'new_qr',
    5,
    'Nouveau QR code pour table 5',
    'La table 5 a besoin d''un nouveau QR code car l''ancien est endommagé.',
    'medium',
    'pending'
) ON CONFLICT DO NOTHING;

-- Completion message
DO $$
BEGIN
    RAISE NOTICE '🎯 QR SUPPORT REQUESTS SCHEMA CREATED SUCCESSFULLY!';
    RAISE NOTICE '📋 New table: qr_support_requests';
    RAISE NOTICE '👀 New view: qr_support_dashboard';
    RAISE NOTICE '📊 New function: get_qr_support_stats()';
    RAISE NOTICE '🔒 Row Level Security enabled';
    RAISE NOTICE '✅ Ready for QR support management!';
END $$;