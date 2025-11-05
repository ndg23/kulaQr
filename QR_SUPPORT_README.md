# QR Support Request System

## Overview

The QR Support Request System allows restaurant managers to submit support requests specifically for QR code-related issues and needs. This system provides a structured way to handle QR code generation, updates, replacements, and technical issues.

## Features

### For Managers
- **Create Support Requests**: Submit requests for various QR code needs
- **Track Request Status**: Monitor the progress of submitted requests
- **Filter and Search**: Easily find specific requests using filters
- **Real-time Updates**: Get notifications when request status changes

### Request Types
- **New QR Code**: Request generation of new QR codes for tables
- **QR Replacement**: Request replacement of damaged or lost QR codes
- **QR Update**: Request updates to existing QR code designs or information
- **QR Deactivation**: Request deactivation of QR codes for specific tables
- **Bulk QR Generation**: Request generation of multiple QR codes at once
- **QR Customization**: Request custom designs or branding for QR codes
- **Technical Issue**: Report technical problems with QR code functionality

### Priority Levels
- **Low**: Non-urgent requests
- **Medium**: Standard priority requests
- **High**: Important requests requiring prompt attention
- **Urgent**: Critical issues requiring immediate attention

## Database Schema

### qr_support_requests Table

```sql
CREATE TABLE qr_support_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Request details
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    requested_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    request_type TEXT NOT NULL,
    table_number INTEGER,
    title TEXT NOT NULL,
    description TEXT,
    priority TEXT DEFAULT 'medium',

    -- Status tracking
    status TEXT DEFAULT 'pending',
    assigned_to UUID REFERENCES auth.users(id) ON DELETE SET NULL,

    -- Resolution details
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    resolution_notes TEXT,

    -- Additional metadata
    attachments JSONB DEFAULT '[]',
    internal_notes TEXT,
    estimated_completion TIMESTAMP WITH TIME ZONE
);
```

## API Usage

### Composables

#### useQrSupport()

```typescript
import { useQrSupport } from '~/composables/useQrSupport'

const {
  loading,
  requests,
  pendingRequests,
  inProgressRequests,
  completedRequests,
  urgentRequests,
  fetchRequests,
  createRequest,
  updateRequest,
  cancelRequest,
  getStats
} = useQrSupport()
```

#### Available Methods

- `fetchRequests(establishmentId?)`: Fetch all requests for an establishment
- `createRequest(requestData)`: Create a new support request
- `updateRequest(id, updates)`: Update an existing request
- `cancelRequest(id)`: Cancel a pending request
- `getStats(establishmentId?)`: Get statistics about requests

### Example Usage

```vue
<template>
  <div>
    <button @click="createNewRequest">Create Support Request</button>

    <div v-for="request in requests" :key="request.id">
      <h3>{{ request.title }}</h3>
      <p>Status: {{ request.status }}</p>
      <p>Priority: {{ request.priority }}</p>
    </div>
  </div>
</template>

<script setup>
import { useQrSupport } from '~/composables/useQrSupport'

const { requests, createRequest, fetchRequests } = useQrSupport()

const createNewRequest = async () => {
  await createRequest({
    establishment_id: 'establishment-uuid',
    requested_by: 'user-uuid',
    request_type: 'new_qr',
    title: 'New QR Code for Table 5',
    description: 'Need a new QR code for table 5',
    priority: 'medium'
  })
}

onMounted(() => {
  fetchRequests()
})
</script>
```

## Views

### qr_support_dashboard

A database view that provides a comprehensive overview of all support requests with related establishment and user information.

```sql
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
```

## Functions

### get_qr_support_stats(establishment_uuid)

Returns statistics about QR support requests for a specific establishment or all establishments.

```sql
CREATE OR REPLACE FUNCTION get_qr_support_stats(establishment_uuid UUID DEFAULT NULL)
RETURNS TABLE (
    total_requests BIGINT,
    pending_requests BIGINT,
    in_progress_requests BIGINT,
    completed_requests BIGINT,
    avg_resolution_time INTERVAL,
    urgent_requests BIGINT
)
```

## Security

### Row Level Security (RLS)

The system implements comprehensive RLS policies:

- **Managers** can view and manage requests for their own establishments
- **Admins** have full access to all requests
- Users can only see requests they created or that belong to establishments they manage

### Policies

```sql
-- Managers can view their establishment requests
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
```

## Workflow

1. **Manager submits request** through the web interface
2. **System validates** the request and stores it in the database
3. **Admin/support team** reviews and assigns requests
4. **Status updates** are tracked and notifications sent
5. **Request resolution** with notes and timestamps
6. **Manager receives** confirmation of completion

## File Structure

```
bdd/
├── qr_support_requests.sql          # Database schema and functions

composables/
├── useQrSupport.ts                  # Vue composable for QR support

pages/manager/[slug]/
├── qr-support.vue                   # Main support request page

types/
├── database.ts                      # TypeScript definitions
```

## Future Enhancements

- Email notifications for status updates
- File attachment support for request details
- Integration with external support ticketing systems
- Automated QR code generation based on approved requests
- Analytics dashboard for support metrics
- SLA tracking and reporting