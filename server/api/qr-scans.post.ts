import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  // Forward to the main endpoint handler for backward compatibility
  const response = await $fetch('/api/qr-scan', {
    method: 'POST',
    body: await readBody(event)
  });
  
  return response;
}) 