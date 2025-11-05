-- Migration: Add session_id column to qr_scans table
-- This migration adds the session_id column for better QR tracking

ALTER TABLE qr_scans
ADD COLUMN IF NOT EXISTS session_id TEXT;

-- Add index for session_id
CREATE INDEX IF NOT EXISTS idx_qr_scans_session_id ON qr_scans(session_id);

-- Add comment
COMMENT ON COLUMN qr_scans.session_id IS 'Unique session identifier for tracking user sessions';