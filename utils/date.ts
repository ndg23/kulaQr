/**
 * Comprehensive date, time and currency formatting utilities
 * Following international standards used by major tech companies
 */

// Format currency with proper symbol and localization
export const formatCurrency = (
    amount: number, 
    currency: string = 'XOF', 
    locale: string = 'fr-FR'
  ): string => {
    if (amount === null || amount === undefined) return '';
    
    return new Intl.NumberFormat(locale, {
      style: 'currency',
      currency: currency,
      currencyDisplay: 'symbol'
    }).format(amount);
  };
  
  // Format date only (day, month, year)
//   export const formatDate = (
//     date: string | Date | null | undefined,
//     locale: string = 'fr-FR',
//     options?: Intl.DateTimeFormatOptions
//   ): string => {
//     if (!date) return '';
    
//     const defaultOptions: Intl.DateTimeFormatOptions = {
//       day: '2-digit',
//       month: 'long',
//       year: 'numeric'
//     };
  
//     return new Intl.DateTimeFormat(locale, options || defaultOptions).format(new Date(date));
//   };
  
  // Format both date and time
  export const formatDateTime = (
    date: string | Date | null | undefined,
    locale: string = 'fr-FR',
    options?: Intl.DateTimeFormatOptions
  ): string => {
    if (!date) return '';
    
    const defaultOptions: Intl.DateTimeFormatOptions = {
      day: '2-digit',
      month: 'long',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    };
    
    return new Intl.DateTimeFormat(locale, options || defaultOptions).format(new Date(date));
  };
  
  // Format time only from a time string
  export const formatTime = (
    time: string | null | undefined,
    locale: string = 'fr-FR',
    options?: Intl.DateTimeFormatOptions
  ): string => {
    if (!time) return '';
    
    const defaultOptions: Intl.DateTimeFormatOptions = {
      hour: '2-digit',
      minute: '2-digit'
    };
    
    // Handle both time-only strings and full datetime strings
    const dateToFormat = time.includes('T') || time.includes(' ') 
      ? new Date(time)
      : new Date(`1970-01-01T${time}`);
    
    return new Intl.DateTimeFormat(locale, options || defaultOptions).format(dateToFormat);
  };
  
  // Format relative time (X time ago)
  export const formatDate = (
    date: string | Date | null | undefined,
    locale: string = 'fr-FR'
  ): string => {
    if (!date) return '';
    
    const then = new Date(date);
    
    // Check for invalid date
    if (isNaN(then.getTime())) return '';
    
    return then.toLocaleDateString(locale, {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };
  
  export const getRelativeTime = (
    date: string | Date | null | undefined,
    locale: string = 'fr-FR'
  ): string => {
    if (!date) return '';
    
    const now = new Date();
    const then = new Date(date);
    const diff = now.getTime() - then.getTime();
    
    // Check for invalid date
    if (isNaN(then.getTime())) return '';
    
    // Use the modern Intl.RelativeTimeFormat if available
    if (typeof Intl.RelativeTimeFormat !== 'undefined') {
      const rtf = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' });
      
      const seconds = Math.floor(diff / 1000);
      const minutes = Math.floor(seconds / 60);
      const hours = Math.floor(minutes / 60);
      const days = Math.floor(hours / 24);
      const months = Math.floor(days / 30);
      const years = Math.floor(days / 365);
      
      // Return absolute date for older dates
      if (months > 3) {
        return formatDate(date, locale);
      } else if (years > 0) {
        return rtf.format(-years, 'year');
      } else if (months > 0) {
        return rtf.format(-months, 'month');
      } else if (days > 0) {
        return rtf.format(-days, 'day');
      } else if (hours > 0) {
        return rtf.format(-hours, 'hour');
      } else if (minutes > 0) {
        return rtf.format(-minutes, 'minute');
      } else {
        return rtf.format(-seconds, 'second');
      }
    }
    
    // Fallback implementation for older browsers
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);
    const months = Math.floor(days / 30);
  
    if (months > 11) {
      return formatDate(date, locale);
    } else if (days > 30) {
      return formatDate(date, locale);
    } else if (days > 0) {
      return `il y a ${days} jour${days > 1 ? 's' : ''}`;
    } else if (hours > 0) {
      return `il y a ${hours} heure${hours > 1 ? 's' : ''}`;
    } else if (minutes > 0) {
      return `il y a ${minutes} minute${minutes > 1 ? 's' : ''}`;
    } else {
      return 'à l\'instant';
    }
  };
  
  // Format for ISO standard (common in APIs)
  export const formatISODate = (date: string | Date | null | undefined): string => {
    if (!date) return '';
    const dateObj = new Date(date);
    return isNaN(dateObj.getTime()) ? '' : dateObj.toISOString();
  };
  
  // Format short date (e.g., 01/04/2023)
  export const formatShortDate = (
    date: string | Date | null | undefined,
    locale: string = 'fr-FR'
  ): string => {
    if (!date) return '';
    
    return new Intl.DateTimeFormat(locale, {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    }).format(new Date(date));
  };
  
  // Get date parts separately (useful for custom UIs)
  export const getDateParts = (date: string | Date | null | undefined): Record<string, number> | null => {
    if (!date) return null;
    
    const dateObj = new Date(date);
    if (isNaN(dateObj.getTime())) return null;
    
    return {
      year: dateObj.getFullYear(),
      month: dateObj.getMonth() + 1, // 1-12 instead of 0-11
      day: dateObj.getDate(),
      hours: dateObj.getHours(),
      minutes: dateObj.getMinutes(),
      seconds: dateObj.getSeconds()
    };
  };