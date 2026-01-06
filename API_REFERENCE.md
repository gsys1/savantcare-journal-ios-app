# Backend API Reference

This document describes the required REST API endpoints for the SavantCare Journal iOS App.

## Base URL

```
Development: http://localhost:3000/api/v1
Production: https://api.savantcare.com/api/v1
```

## Authentication

Currently, the app uses a static patient ID. In production, implement JWT or OAuth2 authentication.

## Endpoints

### 1. Create Journal Entry

Creates a new journal entry for a patient.

**Endpoint:** `POST /journal`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {token} (for production)
```

**Request Body:**
```json
{
  "patient_id": "PATIENT_001",
  "title": "Feeling Better Today",
  "content": "Had a good day with minimal symptoms. Morning walk helped.",
  "mood": "😊 Happy",
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
    "patient_id": "PATIENT_001",
    "title": "Feeling Better Today",
    "content": "Had a good day with minimal symptoms. Morning walk helped.",
    "mood": "😊 Happy",
    "symptoms": "Mild headache",
    "medications": "Aspirin 500mg",
    "created_at": "2026-01-07T10:00:00Z",
    "updated_at": "2026-01-07T10:00:00Z"
  }
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": {
    "title": "Title is required",
    "content": "Content is required"
  }
}
```

---

### 2. Get All Patient Entries

Retrieves all journal entries for a specific patient.

**Endpoint:** `GET /journal/patient/:patientId`

**Parameters:**
- `patientId` (path) - Patient identifier

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
      "patient_id": "PATIENT_001",
      "title": "Check-up Day",
      "content": "Had my monthly check-up. Doctor says I'm improving.",
      "mood": "😊 Happy",
      "symptoms": null,
      "medications": "Vitamin D supplement",
      "created_at": "2026-01-07T14:00:00Z",
      "updated_at": "2026-01-07T14:00:00Z"
    },
    {
      "id": 1,
      "patient_id": "PATIENT_001",
      "title": "Feeling Better Today",
      "content": "Had a good day with minimal symptoms.",
      "mood": "😊 Happy",
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

### 3. Get Single Entry

Retrieves a specific journal entry by ID.

**Endpoint:** `GET /journal/:id`

**Parameters:**
- `id` (path) - Entry identifier

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Entry retrieved successfully",
  "data": {
    "id": 1,
    "patient_id": "PATIENT_001",
    "title": "Feeling Better Today",
    "content": "Had a good day with minimal symptoms.",
    "mood": "😊 Happy",
    "symptoms": "Mild headache",
    "medications": "Aspirin 500mg",
    "created_at": "2026-01-07T10:00:00Z",
    "updated_at": "2026-01-07T10:00:00Z"
  }
}
```

---

### 4. Update Journal Entry

Updates an existing journal entry.

**Endpoint:** `PUT /journal/:id`

**Parameters:**
- `id` (path) - Entry identifier

**Request Body:**
```json
{
  "title": "Updated Title",
  "content": "Updated content...",
  "mood": "😌 Calm",
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
    "patient_id": "PATIENT_001",
    "title": "Updated Title",
    "content": "Updated content...",
    "mood": "😌 Calm",
    "symptoms": "No symptoms today",
    "medications": "Aspirin 500mg, Vitamin D",
    "created_at": "2026-01-07T10:00:00Z",
    "updated_at": "2026-01-07T15:30:00Z"
  }
}
```

---

### 5. Delete Journal Entry

Deletes a journal entry.

**Endpoint:** `DELETE /journal/:id`

**Parameters:**
- `id` (path) - Entry identifier

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
| 401 | Unauthorized - Invalid credentials |
| 404 | Not Found - Resource doesn't exist |
| 500 | Internal Server Error |

## Date Format

All dates use ISO 8601 format:
```
2026-01-07T10:00:00Z
```

## Sample Node.js/Express Implementation

```javascript
// Example endpoint implementation
app.post('/api/v1/journal', async (req, res) => {
  try {
    const { patient_id, title, content, mood, symptoms, medications } = req.body;
    
    // Validation
    if (!title || !content || !mood) {
      return res.status(400).json({
        success: false,
        message: 'Title, content, and mood are required'
      });
    }
    
    // Insert into database
    const [result] = await db.query(
      'INSERT INTO journal_entries (patient_id, title, content, mood, symptoms, medications) VALUES (?, ?, ?, ?, ?, ?)',
      [patient_id, title, content, mood, symptoms, medications]
    );
    
    // Fetch created entry
    const [entries] = await db.query(
      'SELECT * FROM journal_entries WHERE id = ?',
      [result.insertId]
    );
    
    res.status(201).json({
      success: true,
      message: 'Entry created successfully',
      data: entries[0]
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});
```

## Testing with cURL

### Create Entry
```bash
curl -X POST http://localhost:3000/api/v1/journal \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "PATIENT_001",
    "title": "Test Entry",
    "content": "This is a test",
    "mood": "😊 Happy"
  }'
```

### Get Entries
```bash
curl http://localhost:3000/api/v1/journal/patient/PATIENT_001
```

### Update Entry
```bash
curl -X PUT http://localhost:3000/api/v1/journal/1 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Updated Test Entry",
    "content": "Updated content",
    "mood": "😌 Calm"
  }'
```

### Delete Entry
```bash
curl -X DELETE http://localhost:3000/api/v1/journal/1
```