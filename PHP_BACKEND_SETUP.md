# PHP Backend Setup for FCM Token Storage

## Step 1: Create Database Table

Run this SQL query in your database:

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

---

## Step 2: Create PHP Endpoint

Create a new file: `api1/user/save_fcm_token.php`

**Important**: Place this file in the same directory structure as your other endpoints (like `user/get_info.php`, `user/change_password.php`, etc.)

```php
<?php
// api1/user/save_fcm_token.php

header('Content-Type: application/json');

// Include your database and auth files (adjust paths as needed)
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';

// Verify authentication
$auth = verifyAuth();
if (!$auth['authenticated']) {
    http_response_code(401);
    echo json_encode([
        'status' => 401,
        'message' => 'Unauthorized'
    ]);
    exit;
}

// Get user_id from auth or POST (depending on your auth implementation)
$user_id = $auth['user_id'] ?? $_POST['user_id'] ?? '';
$fcm_token = $_POST['fcm_token'] ?? '';

// Validate inputs
if (empty($user_id)) {
    http_response_code(400);
    echo json_encode([
        'status' => 400,
        'message' => 'User ID is required'
    ]);
    exit;
}

if (empty($fcm_token)) {
    http_response_code(400);
    echo json_encode([
        'status' => 400,
        'message' => 'FCM token is required'
    ]);
    exit;
}

try {
    // Check if token already exists for this user
    $stmt = $pdo->prepare("SELECT id FROM user_fcm_tokens WHERE user_id = ? AND fcm_token = ?");
    $stmt->execute([$user_id, $fcm_token]);
    $existing = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if ($existing) {
        // Update timestamp if token already exists
        $stmt = $pdo->prepare("UPDATE user_fcm_tokens SET updated_at = NOW() WHERE id = ?");
        $stmt->execute([$existing['id']]);
        
        echo json_encode([
            'status' => 200,
            'message' => 'FCM token updated successfully'
        ]);
    } else {
        // Insert new token
        $stmt = $pdo->prepare("INSERT INTO user_fcm_tokens (user_id, fcm_token, device_type) VALUES (?, ?, 'android')");
        $stmt->execute([$user_id, $fcm_token]);
        
        echo json_encode([
            'status' => 200,
            'message' => 'FCM token saved successfully'
        ]);
    }
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

## Step 3: Adjust File Paths

**Important**: You need to adjust the `require_once` paths in the PHP file to match your project structure:

1. Check where your `database.php` file is located
2. Check where your `auth.php` or authentication middleware is located
3. Update the paths accordingly

For example, if your structure is:
```
api1/
  user/
    save_fcm_token.php
    get_info.php
  config/
    database.php
  middleware/
    auth.php
```

Then the paths should be:
```php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../middleware/auth.php';
```

If your structure is different, adjust `__DIR__` paths accordingly.

---

## Step 4: Test the Endpoint

After creating the file, test it using Postman or curl:

**Request:**
```
POST https://arena.creativecrows.co.in/api1/user/save_fcm_token
Headers:
  Authorization: Bearer {your_token}
  Content-Type: application/x-www-form-urlencoded
Body:
  user_id=186
  fcm_token=test_token_123
```

**Expected Response:**
```json
{
  "status": 200,
  "message": "FCM token saved successfully"
}
```

---

## Step 5: Verify It Works

1. Run your Flutter app
2. Log in
3. Check the terminal - you should see:
   ```
   === FCM TOKEN SAVED SUCCESSFULLY ===
   ```
4. Check your database - the token should be in `user_fcm_tokens` table

---

## Troubleshooting

### 404 Error
- Make sure the file is in the correct location: `api1/user/save_fcm_token.php`
- Check your web server routing configuration

### 401 Unauthorized
- Verify your `verifyAuth()` function is working correctly
- Check that the Bearer token is being sent correctly

### 500 Database Error
- Check database connection
- Verify table exists
- Check PDO error messages

### Path Issues
- Use `__DIR__` for relative paths (recommended)
- Or use absolute paths if needed
- Check file permissions

---

## Next Steps

Once the FCM token saving works, you can proceed to:
1. Set up notification sending (Step 8 in FIREBASE_SETUP_GUIDE.md)
2. Integrate notifications with clock in/out endpoints

