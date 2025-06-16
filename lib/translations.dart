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
      'address': 'Address',
      'sofa': 'Sofa',
      'air_conditioner': 'Air Conditioner',
      'edit': 'Edit',
      'delete': 'Delete',
      'close': 'Close',
      'appointment': 'Appointment',
      'edit_customer': 'Edit Customer',
      'save': 'Save',
      'month': 'Month',
      'week': 'Week',
      'send_reminders': 'Send Reminders',
      'reminder_message': 'This is a reminder for your appointment on',
      'services_included': 'Services included',
      'sent_to': 'Sent to',
      'date': 'Date',
      'services': 'Services',
      'Select_Appointment_Date&Time': 'Select Appointment Date & Time',
      'remark': 'Remark',
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
      'address': 'כתובת',
      'sofa': 'ספה',
      'air_conditioner': 'מזגן',
      'edit': 'ערוך',
      'delete': 'מחק',
      'close': 'סגור',
      'appointment': 'פגישה',
      'edit_customer': 'ערוך לקוח',
      'save': 'שמור',
      'month': 'חודש',
      'week': 'שבוע',
      'send_reminders': 'שלח תזכורות',
      'reminder_message': 'זוהי תזכורת לתור שלך בתאריך',
      'services_included': 'השירותים הכלולים',
      'sent_to': 'נשלח אל',
      'date': 'תאריך',
      'services': 'שירותים',
      'Select_Appointment_Date&Time': 'בחר תאריך ושעת פגישה',
      'remark': 'הערות',
    },
  };

  static void setLanguage(String lang) {
    currentLanguage = lang;
  }

  static String text(String key) {
    return _localizedValues[currentLanguage]?[key] ?? key;
  }
}