# Easy Localization Setup

Aplikasi ini menggunakan `easy_localization` untuk internationalization (i18n) dengan **type-safe generated keys**.

## 📁 Structure

```
lib/app/core/localization/
└── locale_keys.g.dart          # Generated - DO NOT EDIT MANUALLY

assets/translations/
├── en.json                     # English translations
└── id.json                     # Indonesian translations
```

## 🚀 Usage

### Menggunakan LocaleKeys (Type-safe)

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:snappie_app/app/core/localization/locale_keys.g.dart';

// Type-safe dengan autocomplete
Text(tr(LocaleKeys.register_title))

// Dengan parameters
Text(tr(LocaleKeys.greeting_message, args: ['John']))
```

### ❌ JANGAN Gunakan String Literals

```dart
// ❌ BAD - No type safety, prone to typos
Text('register.title'.tr())

// ✅ GOOD - Type-safe, autocomplete works
Text(tr(LocaleKeys.register_title))
```

## 🔄 Menambahkan Translation Keys Baru

### 1. Edit Translation Files

**assets/translations/id.json:**
```json
{
  "register": {
    "title": "Daftar",
    "new_key": "Nilai Baru"
  }
}
```

**assets/translations/en.json:**
```json
{
  "register": {
    "title": "Register",
    "new_key": "New Value"
  }
}
```

### 2. Generate locale_keys.g.dart

**Option A - PowerShell Script:**
```powershell
.\scripts\generate_locale_keys.ps1
```

**Option B - Manual Command:**
```powershell
dart run easy_localization:generate -S assets/translations -O lib/app/core/localization -o locale_keys.g.dart -f keys
```

### 3. Gunakan di Kode

```dart
Text(tr(LocaleKeys.register_new_key))
```

## 🌍 Switch Language

```dart
// Switch to English
context.setLocale(Locale('en'));

// Switch to Indonesian
context.setLocale(Locale('id'));

// Get current locale
print(context.locale); // Locale('id') atau Locale('en')
```

## 📝 Translation Structure Best Practices

### Nested Keys

```json
{
  "auth": {
    "login": {
      "title": "Login",
      "button": "Sign In"
    },
    "register": {
      "title": "Register"
    }
  }
}
```

Usage:
```dart
tr(LocaleKeys.auth_login_title)
tr(LocaleKeys.auth_login_button)
```

### With Parameters

**Translation file:**
```json
{
  "greeting": "Hello {name}, you have {count} messages"
}
```

**Usage:**
```dart
tr(LocaleKeys.greeting, args: ['John', '5'])
// Output: "Hello John, you have 5 messages"
```

### Plural Forms

**Translation file:**
```json
{
  "messages": {
    "zero": "No messages",
    "one": "{} message",
    "other": "{} messages"
  }
}
```

**Usage:**
```dart
LocaleKeys.messages.plural(5)
```

## 🔍 Tips

1. **Always regenerate** locale_keys.g.dart after editing translation files
2. **Use nested structure** untuk organization yang lebih baik
3. **Keep keys consistent** across all language files
4. **Use descriptive names** untuk keys (bukan generic seperti `text1`, `text2`)
5. **Group by feature/module** untuk maintainability

## ⚠️ Common Issues

### Keys tidak ter-generate

**Problem:** Key ada di JSON tapi tidak muncul di locale_keys.g.dart

**Solution:**
```powershell
# Delete generated file dan regenerate
Remove-Item lib/app/core/localization/locale_keys.g.dart
.\scripts\generate_locale_keys.ps1
```

### Translation tidak update

**Problem:** Sudah update JSON tapi text tidak berubah

**Solution:**
1. Hot restart (bukan hot reload)
2. Clear app data dan rebuild

### Missing translation

**Problem:** `Missing translation for key: xxx`

**Solution:**
1. Check JSON syntax
2. Regenerate locale_keys.g.dart
3. Ensure key exists di semua language files

## 📚 References

- [easy_localization docs](https://pub.dev/packages/easy_localization)
- [Flutter Internationalization](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
