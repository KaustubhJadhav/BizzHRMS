# Firebase Cloud Messaging (FCM) Setup Guide for HRMS Flutter App

This guide will help you set up Firebase Cloud Messaging to receive push notifications for clock in/out events.

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. Android Studio (for Android setup)
4. Your PHP backend ready to send notifications

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: **"HRMS App"** (or your preferred name)
4. Disable Google Analytics (optional) or enable it if you want
5. Click **"Create project"**
6. Wait for project creation to complete

---

## Step 2: Add Android App to Firebase

1. In Firebase Console, click the **Android icon** (or **"Add app"** → **Android**)
2. Enter Android package name: `com.example.hrms_flutter_app`
   - This matches your `applicationId` in `android/app/build.gradle.kts`
3. Enter App nickname (optional): **"HRMS Android"**
4. Enter Debug signing certificate SHA-1 (optional for now, required for production)
5. Click **"Register app"**

---

## Step 3: Download google-services.json

1. After registering the Android app, click **"Download google-services.json"**
2. **IMPORTANT**: Place this file in:
   ```
   android/app/google-services.json
   ```
3. Make sure the file is named exactly `google-services.json` (lowercase)

---

## Step 4: Verify Flutter Dependencies

The following packages have already been added to `pubspec.yaml`:
- `firebase_core: ^3.6.0`
- `firebase_messaging: ^15.1.3`
- `flutter_local_notifications: ^18.0.1`

Run the following command to install dependencies:
```bash
flutter pub get
```

---

## Step 5: Verify Android Configuration

The following files have already been configured:

### ✅ `android/app/build.gradle.kts`
- Google Services plugin added

### ✅ `android/settings.gradle.kts`
- Google Services plugin dependency added

### ✅ `android/app/src/main/AndroidManifest.xml`
- Internet permission
- Notification permissions
- FCM metadata

---

## Step 6: Test Firebase Setup

1. Run the app:
   ```bash
   flutter run
   ```

2. Check the terminal output. You should see:
   ```
   === FIREBASE INITIALIZED ===
   === FCM PERMISSION STATUS ===
   Authorization Status: AuthorizationStatus.authorized
   === FCM TOKEN OBTAINED ===
   Token: [your-fcm-token]
   ```

3. When you log in, you should see:
   ```
   === SAVING FCM TOKEN TO BACKEND ===
   === FCM TOKEN SAVED SUCCESSFULLY ===
   ```

---

## Step 7: PHP Backend Integration

### Database Schema

Add a table to store FCM tokens:

```sql
CREATE TABLE `user_fcm_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `fcm_token` text NOT NULL,
  `device_type` varchar(20) DEFAULT 'android',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_token` (`user_id`, `fcm_token`(255)),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### API Endpoint: Save FCM Token

**Endpoint**: `POST /api1/user/save_fcm_token`

**Headers**:
```
Authorization: Bearer {user_token}
Content-Type: application/x-www-form-urlencoded
```

**Parameters**:
- `user_id` (required): User ID
- `fcm_token` (required): FCM token from the app

**Response**:
```json
{
  "status": 200,
  "message": "FCM token saved successfully"
}
```

**PHP Implementation Example**:

```php
<?php
// api1/user/save_fcm_token.php

header('Content-Type: application/json');
require_once '../config/database.php';
require_once '../middleware/auth.php';

// Verify authentication
$auth = verifyAuth();
if (!$auth['authenticated']) {
    http_response_code(401);
    echo json_encode(['status' => 401, 'message' => 'Unauthorized']);
    exit;
}

$user_id = $auth['user_id'];
$fcm_token = $_POST['fcm_token'] ?? '';

if (empty($fcm_token)) {
    http_response_code(400);
    echo json_encode(['status' => 400, 'message' => 'FCM token is required']);
    exit;
}

try {
    // Check if token already exists
    $stmt = $pdo->prepare("SELECT id FROM user_fcm_tokens WHERE user_id = ? AND fcm_token = ?");
    $stmt->execute([$user_id, $fcm_token]);
    $existing = $stmt->fetch();
    
    if ($existing) {
        // Update timestamp
        $stmt = $pdo->prepare("UPDATE user_fcm_tokens SET updated_at = NOW() WHERE id = ?");
        $stmt->execute([$existing['id']]);
    } else {
        // Insert new token
        $stmt = $pdo->prepare("INSERT INTO user_fcm_tokens (user_id, fcm_token, device_type) VALUES (?, ?, 'android')");
        $stmt->execute([$user_id, $fcm_token]);
    }
    
    echo json_encode([
        'status' => 200,
        'message' => 'FCM token saved successfully'
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 500,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}
?>
```

---

## Step 8: Send Notifications from PHP Backend

### Install Firebase Admin SDK for PHP

```bash
composer require kreait/firebase-php
```

### PHP Code to Send Notification on Clock In/Out

```php
<?php
// functions/send_notification.php

require_once __DIR__ . '/../vendor/autoload.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

function sendClockNotification($user_id, $clock_type, $clock_time) {
    // Initialize Firebase
    $factory = (new Factory)->withServiceAccount(__DIR__ . '/path/to/firebase-service-account.json');
    $messaging = $factory->createMessaging();
    
    // Get FCM tokens for the user
    global $pdo;
    $stmt = $pdo->prepare("SELECT fcm_token FROM user_fcm_tokens WHERE user_id = ?");
    $stmt->execute([$user_id]);
    $tokens = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    if (empty($tokens)) {
        return ['success' => false, 'message' => 'No FCM tokens found for user'];
    }
    
    // Prepare notification
    $title = $clock_type === 'clock_in' ? 'Clock In Successful' : 'Clock Out Successful';
    $body = $clock_type === 'clock_in' 
        ? "You have successfully clocked in at $clock_time" 
        : "You have successfully clocked out at $clock_time";
    
    $notification = Notification::create($title, $body);
    
    // Send to all devices
    $results = [];
    foreach ($tokens as $token) {
        try {
            $message = CloudMessage::withTarget('token', $token)
                ->withNotification($notification)
                ->withData([
                    'type' => 'clocking',
                    'clock_type' => $clock_type,
                    'clock_time' => $clock_time,
                    'user_id' => $user_id
                ]);
            
            $messaging->send($message);
            $results[] = ['token' => substr($token, 0, 20) . '...', 'status' => 'success'];
        } catch (Exception $e) {
            $results[] = ['token' => substr($token, 0, 20) . '...', 'status' => 'error', 'message' => $e->getMessage()];
        }
    }
    
    return ['success' => true, 'results' => $results];
}

// Example usage in your clock in/out endpoint:
// After successful clock in/out:
// sendClockNotification($user_id, 'clock_in', date('H:i:s'));
?>
```

### Alternative: Using cURL (Simpler, no SDK needed)

```php
<?php
// functions/send_notification_curl.php

function sendClockNotificationCurl($user_id, $clock_type, $clock_time) {
    // Your Firebase Server Key (from Firebase Console → Project Settings → Cloud Messaging)
    $server_key = 'YOUR_FIREBASE_SERVER_KEY';
    
    // Get FCM tokens
    global $pdo;
    $stmt = $pdo->prepare("SELECT fcm_token FROM user_fcm_tokens WHERE user_id = ?");
    $stmt->execute([$user_id]);
    $tokens = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    if (empty($tokens)) {
        return ['success' => false, 'message' => 'No FCM tokens found'];
    }
    
    $title = $clock_type === 'clock_in' ? 'Clock In Successful' : 'Clock Out Successful';
    $body = $clock_type === 'clock_in' 
        ? "You have successfully clocked in at $clock_time" 
        : "You have successfully clocked out at $clock_time";
    
    $results = [];
    foreach ($tokens as $token) {
        $data = [
            'to' => $token,
            'notification' => [
                'title' => $title,
                'body' => $body,
                'sound' => 'default',
            ],
            'data' => [
                'type' => 'clocking',
                'clock_type' => $clock_type,
                'clock_time' => $clock_time,
                'user_id' => $user_id
            ],
            'priority' => 'high'
        ];
        
        $ch = curl_init('https://fcm.googleapis.com/fcm/send');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: key=' . $server_key,
            'Content-Type: application/json'
        ]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        
        $response = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        $results[] = [
            'token' => substr($token, 0, 20) . '...',
            'status' => $http_code === 200 ? 'success' : 'error',
            'response' => json_decode($response, true)
        ];
    }
    
    return ['success' => true, 'results' => $results];
}
?>
```

### Integration in Clock In/Out Endpoint

Update your existing clock in/out endpoint (`api1/attendance/set_clocking.php`):

```php
<?php
// After successful clock in/out API response

// ... your existing clock in/out logic ...

if ($clock_successful) {
    // Send notification
    require_once __DIR__ . '/../functions/send_notification_curl.php';
    $clock_type = $_POST['clock_state']; // 'clock_in' or 'clock_out'
    $clock_time = date('H:i:s');
    sendClockNotificationCurl($user_id, $clock_type, $clock_time);
    
    // Return response
    echo json_encode([
        'status' => 200,
        'message' => false,
        'data' => [
            'clock_state' => $clock_type === 'clock_in' ? 'in' : 'out',
            'time_id' => $time_id // if clock_in
        ]
    ]);
}
?>
```

---

## Step 9: Get Firebase Server Key

1. Go to Firebase Console → Your Project
2. Click the **gear icon** → **Project settings**
3. Go to **Cloud Messaging** tab
4. Copy the **Server key** (for cURL method) or download **Service account JSON** (for SDK method)

---

## Testing

1. **Test FCM Token Registration**:
   - Log in to the app
   - Check terminal for FCM token
   - Verify token is saved in database

2. **Test Notification Sending**:
   - Clock in/out from the app
   - Check if notification appears on device
   - Check PHP logs for notification sending status

3. **Test Background Notifications**:
   - Close the app completely
   - Send a test notification from PHP
   - Notification should appear even when app is closed

---

## Troubleshooting

### Issue: "Firebase not initialized" error
- **Solution**: Make sure `google-services.json` is in `android/app/` directory

### Issue: No FCM token received
- **Solution**: Check internet connection and Firebase project configuration

### Issue: Notifications not appearing
- **Solution**: 
  - Check notification permissions are granted
  - Verify FCM token is saved in database
  - Check Firebase Server Key is correct
  - Verify notification payload format

### Issue: Background notifications not working
- **Solution**: Make sure `firebaseMessagingBackgroundHandler` is properly set up in `main.dart`

---

## Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [PHP Firebase Admin SDK](https://github.com/kreait/firebase-php)

---

## Support

If you encounter any issues, check:
1. Terminal logs for FCM initialization
2. Firebase Console → Cloud Messaging → Reports
3. PHP error logs
4. Android logcat for notification delivery

---

**Note**: For production, make sure to:
- Use production Firebase project
- Add proper error handling
- Implement token refresh logic
- Add notification click handling to navigate to specific screens
- Test on multiple devices

