class Translations {
  static String currentLanguage = 'en';

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'language': 'Language',
      'home': 'Home',
      'map': 'Map',
      'schedule': 'Schedule',
      'name': 'Name',
      'add_customer': 'Add Customer',
      'phone': 'Phone Number',
      'email': 'Email',
      'address': 'Address',
      'sofa': 'Sofa',
      'air_conditioner': 'Air Conditioner',
      'car': 'Car',
      'edit': 'Edit',
      'delete': 'Delete',
      'close': 'Close',
      'appointment': 'Appointment',
      'edit_customer': 'Edit Customer',
      'save': 'Save',
      'month': 'Month',
      'week': 'Week',
      // Add more keys as needed
    },
    'he': {
      'settings': 'הגדרות',
      'language': 'שפה',
      'home': 'בית',
      'map': 'מפה',
      'schedule': 'לו"ז',
      'name': 'שם',
      'add_customer': 'הוסף לקוח',
      'phone': 'מספר טלפון',
      'email': 'דוא"ל',
      'address': 'כתובת',
      'sofa': 'ספה',
      'air_conditioner': 'מזגן',
      'car': 'רכב',
      'edit': 'ערוך',
      'delete': 'מחק',
      'close': 'סגור',
      'appointment': 'פגישה',
      'edit_customer': 'ערוך לקוח',
      'save': 'שמור',
      'month': 'חודש',
      'week': 'שבוע',
      // Add more keys as needed
    },
  };

  static void setLanguage(String lang) {
    currentLanguage = lang;
  }

  static String text(String key) {
    return _localizedValues[currentLanguage]?[key] ?? key;
  }
}