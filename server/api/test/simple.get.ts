export default defineEventHandler(async (event) => {
  return {
    success: true,
    message: 'Test endpoint is working',
    timestamp: new Date().toISOString()
  }
})