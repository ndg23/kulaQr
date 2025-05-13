export default defineEventHandler(async (event) => {
  // Set the content type to image/gif
  setResponseHeader(event, 'Content-Type', 'image/gif')
  setResponseHeader(event, 'Cache-Control', 'no-store, no-cache, must-revalidate')
  
  // This is a 1x1 transparent GIF
  const pixel = Buffer.from('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7', 'base64')
  
  return pixel
}) 