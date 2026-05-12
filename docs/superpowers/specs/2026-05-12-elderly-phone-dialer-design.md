# Elderly Phone Dialer — Design Spec

**Date:** 2026-05-12  
**Platform:** Android (Flutter)  
**Target:** API 21+ (Android 5.0+)

## Overview

A Flutter Android app that helps elderly users make phone calls. Contacts are pre-configured by family members. The user sees a grid of photo avatars, long-presses one to dial. No reading required.

## Core Features

### 1. Main Screen (Elderly Mode)

- 3-column grid of circular photo avatars (~88dp diameter)
- Each contact has a distinct background color for visual differentiation
- No text displayed — purely visual recognition
- Long-press (~1 second) on an avatar triggers the call
- During long-press: other avatars dim, selected avatar enlarges with animation, then call initiates
- Small, subtle "+" button in bottom-right corner (semi-transparent, gray, dashed border)

### 2. Call Behavior

- System phone call is initiated via `url_launcher` + Platform Channel
- Speakerphone is automatically enabled after call connects (via `AudioManager.setSpeakerphoneOn(true)`)
- Requires `CALL_PHONE` and `MODIFY_AUDIO_SETTINGS` permissions

### 3. Management Mode

- Activated by tapping the small "+" button 5 times consecutively
- **Contact list screen:** shows all contacts with photo, name, phone number, edit (✏️), and delete (🗑) buttons. "+" button to add new contacts. "完成" (Done) button to return to main screen.
- **Add/Edit contact screen:** tap photo area to pick from gallery, text fields for name and phone number, save button
- No PIN or password required

### 4. First Launch

- Empty contact list triggers automatic entry into management mode
- Family member adds contacts immediately after install

## Data Model

```dart
class Contact {
  String id;          // UUID
  String name;        // Display name (for management only, hidden on main screen)
  String phoneNumber; // Phone number
  String photoPath;   // Local file path to saved photo
  int colorIndex;     // Background color index from a fixed palette
}
```

## Data Storage

- JSON file stored in app's local documents directory (`path_provider`)
- Photos copied into app directory, not referenced from gallery
- Max 30 contacts

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── models/
│   └── contact.dart
├── services/
│   ├── contact_service.dart   # CRUD + JSON persistence
│   ├── phone_service.dart     # Dial + speakerphone via Platform Channel
│   └── photo_service.dart     # Gallery picker + local file copy
├── screens/
│   ├── home_screen.dart       # 3-column grid, long-press to call
│   └── manage_screen.dart     # Contact list + add/edit
└── widgets/
    ├── contact_avatar.dart    # Photo circle with long-press gesture
    └── photo_picker.dart      # Gallery image selector
```

## Dependencies (pubspec.yaml)

| Package | Purpose |
|---------|---------|
| `image_picker` | Select photo from gallery |
| `url_launcher` | Trigger system phone dialer |
| `path_provider` | Get local storage directory |
| `uuid` | Generate unique contact IDs |
| `permission_handler` | Runtime permission requests |

## Android Permissions

```xml
<uses-permission android:name="android.permission.CALL_PHONE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

## Color Palette (Contact Backgrounds)

10 pre-defined gradient colors, cycled through as contacts are added. Each contact gets a unique color to aid visual identification.

## Error Handling

| Scenario | Behavior |
|----------|----------|
| No contacts on first launch | Auto-enter management mode |
| CALL_PHONE permission denied | Dialog explaining need, link to settings |
| Photo load failure | Show background color + simple person icon placeholder |
| Dial failure (no signal, etc.) | System handles natively |
| Storage full on photo save | Toast message prompting cleanup |

## Testing

- **Widget tests:** avatar rendering, long-press gesture detection, grid layout at various screen sizes, management list CRUD UI
- **Integration tests:** long-press → dial flow, add/edit/delete contact flow, photo picker flow
- **Manual testing:** speakerphone auto-enable on real devices, compatibility across Android 5.0–14
