# Backend API Reference

This document describes the required REST API endpoints for the SavantCare Journal iOS App.

## Base URL

```
Development: http://localhost:3000/api/v1
Production: https://ehr.otip.savantcare.com/v1/api/p20/public/index.php/api/aaip
```

## Authentication

The app uses email/password authentication. Upon successful login, the user session is stored locally using UserDefaults.

---

## Authentication Endpoints

### 1. User Login

Authenticates a user with email and password.

**Endpoint:** `POST /auth/login`

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "emailAddress": "samuel@savantcare.com",
  "password": "$2y$10$4aOXDZ0LJXx7iCmpzjkIH$2y$10$aOXDZ0LJXx7iCmpzjkIH"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
      "publicUniqueId": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
      "facebookID": null,
      "emailAddress": "samuel@savantcare.com",
      "wikiUid": "samuel@savantcare.com"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // Optional: JWT token
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Email and password are required"
}
```

**Error Response (500 Internal Server Error):**
```json
{
  "success": false,
  "message": "Internal server error"
}
```
---

### 2. Send OTP

Sends a One-Time Password to the user's phone number.

**Endpoint:** `POST /auth/send-otp`

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "otpSource": "1234567890" // or "user@example.com"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "OTP sent successfully"
}
```

---

### 3. Verify OTP

Verifies the OTP sent to the user's phone number and logs them in.

**Endpoint:** `POST /auth/verify-otp`

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "otpSource": "1234567890",
  "otp": "123456"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "data": {
    "user": {
      "id": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
      "publicUniqueId": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
      "emailAddress": "samuel@savantcare.com",
      // ... other fields
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Invalid OTP or Source"
}
```


---

## Journal Entry Endpoints

### 2. Create Journal Entry

Creates a new journal entry for the authenticated patient.

**Endpoint:** `POST /journal`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token} (optional)
```

**Request Body:**
```json
{
  "patient_id": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
  "title": "Feeling Better Today",
  "content": "Had a good day with minimal symptoms. Morning walk helped.",
  "mood": "😊",
  "symptoms": "Mild headache",
  "medications": "Aspirin 500mg"
}
```

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Entry created successfully",
  "data": {
    "id": 1,
    "patient_id": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
    "title": "Feeling Better Today",
    "content": "Had a good day with minimal symptoms. Morning walk helped.",
    "mood": "😊",
    "symptoms": "Mild headache",
    "medications": "Aspirin 500mg",
    "created_at": "2026-01-07T10:00:00Z",
    "updated_at": "2026-01-07T10:00:00Z"
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "User not logged in"
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "title": "Title is required",
    "content": "Content is required",
    "mood": "Mood is required"
  }
}
```

---

### 3. Get All Patient Entries

Retrieves all journal entries for the authenticated patient.

**Endpoint:** `GET /journal/patient/:patientId`

**Parameters:**
- `patientId` (path) - Patient identifier (user's ID from login)

**Headers:**
```
Authorization: Bearer {token} (optional)
```

**Query Parameters (Optional):**
- `limit` - Number of entries to return (default: 100)
- `offset` - Offset for pagination (default: 0)
- `sort` - Sort order: "asc" or "desc" (default: "desc")

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Entries retrieved successfully",
  "data": [
    {
      "id": 2,
      "patient_id": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
      "title": "Check-up Day",
      "content": "Had my monthly check-up. Doctor says I'm improving.",
      "mood": "😊",
      "symptoms": null,
      "medications": "Vitamin D supplement",
      "created_at": "2026-01-07T14:00:00Z",
      "updated_at": "2026-01-07T14:00:00Z"
    },
    {
      "id": 1,
      "patient_id": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
      "title": "Feeling Better Today",
      "content": "Had a good day with minimal symptoms.",
      "mood": "😊",
      "symptoms": "Mild headache",
      "medications": "Aspirin 500mg",
      "created_at": "2026-01-07T10:00:00Z",
      "updated_at": "2026-01-07T10:00:00Z"
    }
  ],
  "pagination": {
    "total": 2,
    "limit": 100,
    "offset": 0
  }
}
```

---

### 4. Get Single Entry

Retrieves a specific journal entry by ID.

**Endpoint:** `GET /journal/:id`

**Parameters:**
- `id` (path) - Entry identifier

**Headers:**
```
Authorization: Bearer {token} (optional)
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Entry retrieved successfully",
  "data": {
    "id": 1,
    "patient_id": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
    "title": "Feeling Better Today",
    "content": "Had a good day with minimal symptoms.",
    "mood": "😊",
    "symptoms": "Mild headache",
    "medications": "Aspirin 500mg",
    "created_at": "2026-01-07T10:00:00Z",
    "updated_at": "2026-01-07T10:00:00Z"
  }
}
```

---

### 5. Update Journal Entry

Updates an existing journal entry.

**Endpoint:** `PUT /journal/:id`

**Parameters:**
- `id` (path) - Entry identifier

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token} (optional)
```

**Request Body:**
```json
{
  "title": "Updated Title",
  "content": "Updated content...",
  "mood": "😌",
  "symptoms": "No symptoms today",
  "medications": "Aspirin 500mg, Vitamin D"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Entry updated successfully",
  "data": {
    "id": 1,
    "patient_id": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
    "title": "Updated Title",
    "content": "Updated content...",
    "mood": "😌",
    "symptoms": "No symptoms today",
    "medications": "Aspirin 500mg, Vitamin D",
    "created_at": "2026-01-07T10:00:00Z",
    "updated_at": "2026-01-07T15:30:00Z"
  }
}
```

---

### 6. Delete Journal Entry

Deletes a journal entry.

**Endpoint:** `DELETE /journal/:id`

**Parameters:**
- `id` (path) - Entry identifier

**Headers:**
```
Authorization: Bearer {token} (optional)
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Entry deleted successfully"
}
```

**Error Response (404 Not Found):**
```json
{
  "success": false,
  "message": "Entry not found"
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Validation error |
| 401 | Unauthorized - Invalid credentials or not logged in |
| 404 | Not Found - Resource doesn't exist |
| 500 | Internal Server Error |

## Date Format

All dates use ISO 8601 format:
```
2026-01-07T10:00:00Z
```

## Sample PHP/MySQL Implementation

### Login Endpoint

```php
<?php
// POST /api/aaip/auth/login

header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'), true);
$emailAddress = $data['emailAddress'] ?? '';
$password = $data['password'] ?? '';

if (empty($emailAddress) || empty($password)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Email and password are required'
    ]);
    exit;
}

// Query database
$stmt = $pdo->prepare('SELECT id, publicUniqueId, facebookID, emailAddress, password, wikiUid FROM users WHERE emailAddress = ?');
$stmt->execute([$emailAddress]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user || $user['password'] !== $password) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid email or password'
    ]);
    exit;
}

// Remove password from response
unset($user['password']);

// Optional: Generate JWT token
// $token = generateJWT($user['id']);

echo json_encode([
    'success' => true,
    'message' => 'Login successful',
    'data' => [
        'user' => $user,
        'token' => null // or $token if using JWT
    ]
]);
```

### Create Journal Entry Endpoint

```php
<?php
// POST /api/aaip/journal

header('Content-Type: application/json');

$data = json_decode(file_get_contents('php://input'), true);

// Validation
if (empty($data['title']) || empty($data['content']) || empty($data['mood'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Title, content, and mood are required'
    ]);
    exit;
}

// Insert into database
$stmt = $pdo->prepare('
    INSERT INTO journal_entries (patient_id, title, content, mood, symptoms, medications, created_at, updated_at) 
    VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())
');

$stmt->execute([
    $data['patient_id'],
    $data['title'],
    $data['content'],
    $data['mood'],
    $data['symptoms'] ?? null,
    $data['medications'] ?? null
]);

// Fetch created entry
$entryId = $pdo->lastInsertId();
$stmt = $pdo->prepare('SELECT * FROM journal_entries WHERE id = ?');
$stmt->execute([$entryId]);
$entry = $stmt->fetch(PDO::FETCH_ASSOC);

http_response_code(201);
echo json_encode([
    'success' => true,
    'message' => 'Entry created successfully',
    'data' => $entry
]);
```

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id VARCHAR(255) PRIMARY KEY,
  publicUniqueId VARCHAR(255) UNIQUE,
  facebookID VARCHAR(255),
  emailAddress VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  wikiUid VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Journal Entries Table
```sql
CREATE TABLE journal_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  mood VARCHAR(50) NOT NULL,
  symptoms TEXT,
  medications TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_patient_id (patient_id),
  INDEX idx_created_at (created_at)
);
```

## Testing with cURL

### Login
```bash
curl -X POST https://ehr.otip.savantcare.com/v1/api/p20/public/index.php/api/aaip/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "emailAddress": "samuel@savantcare.com",
    "password": "your_password_here"
  }'
```

### Create Entry (with authenticated user ID)
```bash
curl -X POST https://ehr.otip.savantcare.com/v1/api/p20/public/index.php/api/aaip/journal \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "9b5281e6-b78a-49ee-a8db-100090e2b00001",
    "title": "Test Entry",
    "content": "This is a test",
    "mood": "😊"
  }'
```

### Get Entries for Patient
```bash
curl https://ehr.otip.savantcare.com/v1/api/p20/public/index.php/api/aaip/journal/patient/9b5281e6-b78a-49ee-a8db-100090e2b00001
```

### Update Entry
```bash
curl -X PUT https://ehr.otip.savantcare.com/v1/api/p20/public/index.php/api/aaip/journal/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Test Entry",
    "content": "Updated content",
    "mood": "😌"
  }'
```

### Delete Entry
```bash
curl -X DELETE https://ehr.otip.savantcare.com/v1/api/p20/public/index.php/api/aaip/journal/1
```

## Security Notes

1. **Password Storage**: In production, passwords should be hashed using bcrypt or similar
2. **JWT Tokens**: Implement JWT tokens for stateless authentication
3. **HTTPS**: Always use HTTPS in production
4. **Input Validation**: Sanitize all user inputs to prevent SQL injection
5. **Rate Limiting**: Implement rate limiting on login endpoint
6. **CORS**: Configure CORS properly for your iOS app
7. **Session Management**: Consider implementing refresh tokens for better security