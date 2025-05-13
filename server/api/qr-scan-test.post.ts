import { serverSupabaseClient } from '#supabase/server'

export default defineEventHandler(async (event) => {
  try {
    const body = await readBody(event);
    console.log("QR Scan Test received:", body);
    
    // Verify that we have a valid establishment_id
    if (!body.establishment_id) {
      return { 
        success: false, 
        error: "Missing establishment_id",
        data: body
      };
    }
    
    // Try to get the establishment to verify it exists
    const supabase = await serverSupabaseClient(event);
    const { data: establishment, error: estError } = await supabase
      .from('establishments')
      .select('id')
      .eq('id', body.establishment_id)
      .single();
      
    if (estError) {
      return {
        success: false,
        error: "Establishment check failed",
        details: estError
      };
    }
    
    if (!establishment) {
      return {
        success: false,
        error: "Establishment not found",
        id: body.establishment_id
      };
    }
    
    // Try to insert directly into qr_scans with the CORRECT schema
    const { data, error } = await supabase
      .from('qr_scans')
      .insert({
        establishment_id: body.establishment_id,
        user_agent: event.headers.get('user-agent') || 'test',
        created_at: new Date().toISOString(),
        // These fields match your actual schema in schema1.sql
        ip_address: event.headers.get('x-forwarded-for') || '127.0.0.1',
        referrer: event.headers.get('referer') || 'direct'
      })
      .select();
      
    if (error) {
      return {
        success: false,
        error: "Database insertion failed",
        details: error
      };
    }
    
    return { 
      success: true, 
      message: "Scan recorded successfully",
      data: data
    };
  } catch (error) {
    console.error("QR Scan Test error:", error);
    return { 
      success: false, 
      error: "Exception during processing",
      details: error.message
    };
  }
}); 