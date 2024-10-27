class CurrencyUtils {
  static String getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'RUB':
        return '₽';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      case 'CHF':
        return 'Fr';
      case 'HKD':
        return 'HK\$';
      case 'SGD':
        return 'S\$';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'DKK':
        return 'kr';
      case 'BRL':
        return 'R\$';
      case 'ZAR':
        return 'R';
      case 'MXN':
        return '\$';
      case 'ARS':
        return '\$';
      case 'CLP':
        return '\$';
      case 'COP':
        return '\$';
      case 'PEN':
        return 'S/';
      case 'UYU':
        return '\$U';
      case 'SAR':
        return '﷼';
      case 'AED':
        return 'د.إ';
      case 'ILS':
        return '₪';
      case 'TRY':
        return '₺';
      case 'KRW':
        return '₩';
      case 'PLN':
        return 'zł';
      case 'CZK':
        return 'Kč';
      case 'HUF':
        return 'Ft';
      case 'THB':
        return '฿';
      case 'IDR':
        return 'Rp';
      case 'MYR':
        return 'RM';
      case 'PHP':
        return '₱';
      case 'VND':
        return '₫';
      case 'NGN':
        return '₦';
      case 'EGP':
        return 'E£';
      case 'BDT':
        return '৳';
      case 'PKR':
        return '₨';
      case 'KES':
        return 'KSh';
      case 'GHS':
        return 'GH₵';
      case 'UAH':
        return '₴';
      case 'RON':
        return 'lei';
      case 'BHD':
        return '.د.ب';
      case 'KWD':
        return 'د.ك';
      case 'QAR':
        return 'ر.ق';
      case 'MAD':
        return 'د.م.';
      case 'DZD':
        return 'د.ج';
      case 'TND':
        return 'د.ت';
      default:
        return currencyCode;
    }
  }

  static List<String> getAllCurrencyCodes() {
    return [
      'USD',
      'EUR',
      'GBP',
      'JPY',
      'CNY',
      'INR',
      'RUB',
      'AUD',
      'CAD',
      'CHF',
      'HKD',
      'SGD',
      'SEK',
      'NOK',
      'DKK',
      'BRL',
      'ZAR',
      'MXN',
      'ARS',
      'CLP',
      'COP',
      'PEN',
      'UYU',
      'SAR',
      'AED',
      'ILS',
      'TRY',
      'KRW',
      'PLN',
      'CZK',
      'HUF',
      'THB',
      'IDR',
      'MYR',
      'PHP',
      'VND',
      'NGN',
      'EGP',
      'BDT',
      'PKR',
      'KES',
      'GHS',
      'UAH',
      'RON',
      'BHD',
      'KWD',
      'QAR',
      'MAD',
      'DZD',
      'TND'
    ];
  }
}
