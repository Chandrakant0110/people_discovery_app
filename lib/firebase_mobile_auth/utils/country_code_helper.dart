/// Helper class for country code operations
class CountryCodeHelper {
  /// Common country codes with their dial codes and names
  static const Map<String, Map<String, String>> countries = {
    'US': {'code': '+1', 'name': 'United States', 'flag': '🇺🇸'},
    'IN': {'code': '+91', 'name': 'India', 'flag': '🇮🇳'},
    'GB': {'code': '+44', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    'CA': {'code': '+1', 'name': 'Canada', 'flag': '🇨🇦'},
    'AU': {'code': '+61', 'name': 'Australia', 'flag': '🇦🇺'},
    'DE': {'code': '+49', 'name': 'Germany', 'flag': '🇩🇪'},
    'FR': {'code': '+33', 'name': 'France', 'flag': '🇫🇷'},
    'IT': {'code': '+39', 'name': 'Italy', 'flag': '🇮🇹'},
    'ES': {'code': '+34', 'name': 'Spain', 'flag': '🇪🇸'},
    'BR': {'code': '+55', 'name': 'Brazil', 'flag': '🇧🇷'},
    'MX': {'code': '+52', 'name': 'Mexico', 'flag': '🇲🇽'},
    'JP': {'code': '+81', 'name': 'Japan', 'flag': '🇯🇵'},
    'CN': {'code': '+86', 'name': 'China', 'flag': '🇨🇳'},
    'KR': {'code': '+82', 'name': 'South Korea', 'flag': '🇰🇷'},
    'RU': {'code': '+7', 'name': 'Russia', 'flag': '🇷🇺'},
    'ID': {'code': '+62', 'name': 'Indonesia', 'flag': '🇮🇩'},
    'TR': {'code': '+90', 'name': 'Turkey', 'flag': '🇹🇷'},
    'SA': {'code': '+966', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    'AE': {'code': '+971', 'name': 'UAE', 'flag': '🇦🇪'},
    'SG': {'code': '+65', 'name': 'Singapore', 'flag': '🇸🇬'},
    'MY': {'code': '+60', 'name': 'Malaysia', 'flag': '🇲🇾'},
    'TH': {'code': '+66', 'name': 'Thailand', 'flag': '🇹🇭'},
    'PH': {'code': '+63', 'name': 'Philippines', 'flag': '🇵🇭'},
    'VN': {'code': '+84', 'name': 'Vietnam', 'flag': '🇻🇳'},
    'PK': {'code': '+92', 'name': 'Pakistan', 'flag': '🇵🇰'},
    'BD': {'code': '+880', 'name': 'Bangladesh', 'flag': '🇧🇩'},
    'EG': {'code': '+20', 'name': 'Egypt', 'flag': '🇪🇬'},
    'ZA': {'code': '+27', 'name': 'South Africa', 'flag': '🇿🇦'},
    'NG': {'code': '+234', 'name': 'Nigeria', 'flag': '🇳🇬'},
    'KE': {'code': '+254', 'name': 'Kenya', 'flag': '🇰🇪'},
    'AR': {'code': '+54', 'name': 'Argentina', 'flag': '🇦🇷'},
    'CL': {'code': '+56', 'name': 'Chile', 'flag': '🇨🇱'},
    'CO': {'code': '+57', 'name': 'Colombia', 'flag': '🇨🇴'},
    'PE': {'code': '+51', 'name': 'Peru', 'flag': '🇵🇪'},
    'NL': {'code': '+31', 'name': 'Netherlands', 'flag': '🇳🇱'},
    'BE': {'code': '+32', 'name': 'Belgium', 'flag': '🇧🇪'},
    'CH': {'code': '+41', 'name': 'Switzerland', 'flag': '🇨🇭'},
    'AT': {'code': '+43', 'name': 'Austria', 'flag': '🇦🇹'},
    'SE': {'code': '+46', 'name': 'Sweden', 'flag': '🇸🇪'},
    'NO': {'code': '+47', 'name': 'Norway', 'flag': '🇳🇴'},
    'DK': {'code': '+45', 'name': 'Denmark', 'flag': '🇩🇰'},
    'FI': {'code': '+358', 'name': 'Finland', 'flag': '🇫🇮'},
    'PL': {'code': '+48', 'name': 'Poland', 'flag': '🇵🇱'},
    'GR': {'code': '+30', 'name': 'Greece', 'flag': '🇬🇷'},
    'PT': {'code': '+351', 'name': 'Portugal', 'flag': '🇵🇹'},
    'IE': {'code': '+353', 'name': 'Ireland', 'flag': '🇮🇪'},
    'NZ': {'code': '+64', 'name': 'New Zealand', 'flag': '🇳🇿'},
  };

  /// Get dial code for a country
  static String? getDialCode(String countryCode) {
    return countries[countryCode.toUpperCase()]?['code'];
  }

  /// Get country name
  static String? getCountryName(String countryCode) {
    return countries[countryCode.toUpperCase()]?['name'];
  }

  /// Get all country codes
  static List<String> getAllCountryCodes() {
    return countries.keys.toList()..sort();
  }

  /// Get country info
  static Map<String, String>? getCountryInfo(String countryCode) {
    return countries[countryCode.toUpperCase()];
  }

  /// Check if country code exists
  static bool hasCountryCode(String countryCode) {
    return countries.containsKey(countryCode.toUpperCase());
  }

  /// Get default country code (US)
  static String getDefaultCountryCode() {
    return 'US';
  }

  /// Format country code with dial code
  static String formatCountryCode(String countryCode) {
    final info = getCountryInfo(countryCode);
    if (info != null) {
      return '${info['flag']} ${info['name']} ${info['code']}';
    }
    return countryCode;
  }
}

