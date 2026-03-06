# Challenge Claim System - Dokumentasi Teknis

## 1. Konsep Mekanik Claim

```
Challenge Lifecycle:
┌─────────────────┐
│ Challenge Idle  │  (User belum selesai)
└────────┬────────┘
         │ User complete challenge (progress >= target)
         ↓
┌─────────────────┐
│ Challenge       │  (Status: COMPLETED)
│ COMPLETED       │  NOT YET CLAIMED
└────────┬────────┘
         │ (Jika belum diklaim)
         │ → UI: Tampilkan "CLAIM" button (primary/highlighted)
         │
         ├─ User klik "CLAIM"
         │  → Call: POST /gamification/challenges/claim/{challenge_id}
         │
         ↓
┌─────────────────┐
│ Challenge       │  (Status: COMPLETED)
│ CLAIMED         │  ALREADY CLAIMED
└─────────────────┘
      ↓ (Jika sudah diklaim)
      → UI: Tampilkan "CLAIMED" label (greyed out)
      → Rewards sudah diterima user
```

---

## 2. API Endpoints - Challenge Claim System

### A. GET - List Challenges yang Bisa Di-Claim

**Endpoint:**
```
GET /api/v2/gamification/challenges/claimable
```

**Purpose:** Ambil list challenges yang status COMPLETED tapi BELUM di-claim

**Query Parameters:**
```
None (currently tidak ada pagination di endpoint ini)
```

**Request Headers:**
```
Authorization: Bearer {user_token}
Accept: application/json
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Claimable challenges retrieved",
  "data": {
    "items": [
      {
        "id": 1,
        "user_achievement_id": 24,
        "code": "DAILY_CHECKIN_5",
        "name": "Daily Checkin - 5 Times",
        "description": "Checkin at 5 different places in one day",
        "icon_url": "https://cdn.example.com/challenges/daily-checkin.png",
        "type": "challenge",
        "reset_schedule": "daily",
        "reward_coins": 50,
        "reward_xp": 10,
        "completed_at": "2026-03-03T15:30:00.000000Z",
        "is_claimed": false
      },
      {
        "id": 5,
        "user_achievement_id": 28,
        "code": "WEEKLY_REVIEW_3",
        "name": "Weekly Review - 3 Times",
        "description": "Write 3 reviews in one week",
        "icon_url": "https://cdn.example.com/challenges/weekly-review.png",
        "type": "challenge",
        "reset_schedule": "weekly",
        "reward_coins": 100,
        "reward_xp": 25,
        "completed_at": "2026-03-02T10:15:00.000000Z",
        "is_claimed": false
      }
    ],
    "total": 2
  }
}
```

**Response Error (401 - Not Authenticated):**
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

**Response Error (500):**
```json
{
  "success": false,
  "message": "Failed to retrieve claimable challenges",
  "error": "Database connection error..."
}
```

---

### B. POST - Claim Single Challenge

**Endpoint:**
```
POST /api/v2/gamification/challenges/claim/{challenge_id}
```

**Purpose:** Claim rewards dari 1 challenge yang sudah completed

**Path Parameters:**
```
challenge_id (int) - ID achievement yang bertipe "challenge"
```

**Request Headers:**
```
Authorization: Bearer {user_token}
Accept: application/json
Content-Type: application/json
```

**Request Body:**
```json
{} 
// Empty body, semua data ambil dari path parameter
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Challenge claimed successfully",
  "data": {
    "challenge": {
      "id": 1,
      "code": "DAILY_CHECKIN_5",
      "name": "Daily Checkin - 5 Times",
      "description": "Checkin at 5 different places in one day",
      "icon_url": "https://cdn.example.com/challenges/daily-checkin.png",
      "reward_coins": 50,
      "reward_xp": 10
    },
    "user_achievement": {
      "id": 24,
      "user_id": 5,
      "achievement_id": 1,
      "current_progress": 5,
      "target_progress": 5,
      "status": true,
      "completed_at": "2026-03-03T15:30:00.000000Z",
      "period_date": "2026-03-03",
      "additional_info": {
        "claim_info": {
          "is_claimed": true,
          "claimed_at": "2026-03-03T16:45:32.123456Z"
        }
      },
      "created_at": "2026-03-03T15:30:00.000000Z",
      "updated_at": "2026-03-03T16:45:32.000000Z"
    },
    "user_stats": {
      "total_coin": 520,
      "total_exp": 145,
      "total_achievement": 12,
      "total_challenge": 8
    }
  }
}
```

**Response Error (401 - Not Authenticated):**
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

**Response Error (404 - Challenge Not Found):**
```json
{
  "success": false,
  "message": "Challenge not found for this user"
}
```

**Response Error (409 - Challenge Not Yet Completed):**
```json
{
  "success": false,
  "message": "Challenge not yet completed"
}
```

**Response Error (409 - Already Claimed):**
```json
{
  "success": false,
  "message": "This challenge has already been claimed"
}
```

**Response Error (500):**
```json
{
  "success": false,
  "message": "Failed to claim challenge",
  "error": "Database transaction failed..."
}
```

---

### C. GET - Claim History

**Endpoint:**
```
GET /api/v2/gamification/challenges/claim-history
```

**Purpose:** Lihat riwayat challenges yang sudah di-claim

**Query Parameters:**
```
?limit=20&page=1

- limit (int, optional): Jumlah item per halaman (default: 20)
- page (int, optional): Halaman ke berapa (default: 1)
```

**Request Headers:**
```
Authorization: Bearer {user_token}
Accept: application/json
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Challenge claim history retrieved",
  "data": {
    "items": [
      {
        "id": 1,
        "code": "DAILY_CHECKIN_5",
        "name": "Daily Checkin - 5 Times",
        "description": "Checkin at 5 different places in one day",
        "icon_url": "https://cdn.example.com/challenges/daily-checkin.png",
        "reward_coins": 50,
        "reward_xp": 10,
        "completed_at": "2026-03-03T15:30:00.000000Z",
        "claimed_at": "2026-03-03T16:45:32.123456Z"
      },
      {
        "id": 5,
        "code": "WEEKLY_REVIEW_3",
        "name": "Weekly Review - 3 Times",
        "description": "Write 3 reviews in one week",
        "icon_url": "https://cdn.example.com/challenges/weekly-review.png",
        "reward_coins": 100,
        "reward_xp": 25,
        "completed_at": "2026-03-02T10:15:00.000000Z",
        "claimed_at": "2026-03-03T09:20:15.456789Z"
      }
    ],
    "total": 2,
    "limit": 20,
    "current_page": 1,
    "last_page": 1
  }
}
```

---

## 3. Flow UI - Menampilkan Status Claim

### Scenario A: Challenge BELUM Diklaim

```
UI Status: COMPLETED (tidak diklaim)

Tampilkan:
├─ Challenge name, icon, description
├─ Progress bar (100% - completed)
├─ Reward: +50 coins, +10 XP
├─ Status badge: "READY TO CLAIM" (color: green/highlight)
└─ Button: "CLAIM REWARDS" (primary button, enabled)

User klik "CLAIM REWARDS":
  → POST /api/v2/gamification/challenges/claim/{challenge_id}
  → IF success:
       - Tampilkan toast/snackbar: "Challenge claimed! +50 coins +10 XP"
       - Update UI status ke "CLAIMED"
       - Refresh user stats (coins, xp)
       - Remove dari "claimable" list
  → IF error (400/409):
       - Tampilkan error message yang sesuai
       - Jangan close dialog
```

### Scenario B: Challenge SUDAH Diklaim

```
UI Status: COMPLETED (sudah diklaim)

Tampilkan:
├─ Challenge name, icon, description
├─ Progress bar (100% - completed)
├─ Reward: +50 coins, +10 XP (greyed out)
├─ Status badge: "CLAIMED" (color: grey)
├─ Claimed date: "Claimed on Mar 3, 2026 at 4:45 PM"
└─ Button: "CLAIMED" (disabled, greyed out)

User bisa:
  → Click status badge untuk lihat claim history
  → Atau swipe/collapse challenge dari view
```

---

## 4. Implementasi Steps Untuk Frontend

### Step 1: Load Claimable Challenges

```javascript
// Setiap kali user buka halaman Challenges/Rewards

fetch('/api/v2/gamification/challenges/claimable', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${userToken}`,
    'Accept': 'application/json'
  }
})
.then(response => response.json())
.then(data => {
  if (data.success) {
    // data.data.items = array of claimable challenges
    renderClaimableList(data.data.items);
  }
})
```

### Step 2: Get Full Challenge List (dengan status claim)

```javascript
// Endpoint yang sudah extend: GET /gamification/challenges
// Response sudah include field "is_claimed" di setiap challenge

fetch('/api/v2/gamification/challenges', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${userToken}`,
    'Accept': 'application/json'
  }
})
.then(response => response.json())
.then(data => {
  // data.data = array challenges dengan field is_claimed
  // is_claimed: true/false
  
  challenges.forEach(challenge => {
    if (challenge.is_completed && !challenge.is_claimed) {
      // Tampilkan "CLAIM" button
      showClaimButton(challenge.id);
    } else if (challenge.is_completed && challenge.is_claimed) {
      // Tampilkan "CLAIMED" status
      showClaimedStatus(challenge.id);
    }
  });
})
```

### Step 3: Claim Challenge

```javascript
// User click "CLAIM" button

async function claimChallenge(challengeId) {
  try {
    const response = await fetch(
      `/api/v2/gamification/challenges/claim/${challengeId}`,
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${userToken}`,
          'Accept': 'application/json',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      }
    );
    
    const result = await response.json();
    
    if (response.ok && result.success) {
      // SUCCESS
      const coins = result.data.challenge.reward_coins;
      const xp = result.data.challenge.reward_xp;
      
      showSuccessToast(`Claimed! +${coins} coins +${xp} XP`);
      updateUserStats(result.data.user_stats);
      updateChallengeStatus(challengeId, 'claimed');
      refreshClaimableList();
      
    } else if (response.status === 409) {
      // CONFLICT - Challenge not completed or already claimed
      showErrorToast(result.message);
      
    } else if (response.status === 404) {
      // NOT FOUND
      showErrorToast('Challenge not found');
      
    } else {
      // SERVER ERROR
      showErrorToast('Failed to claim challenge');
    }
  } catch (error) {
    console.error('Claim error:', error);
    showErrorToast('Network error');
  }
}
```

### Step 4: View Claim History

```javascript
// User click "Claim History" atau profile section

fetch('/api/v2/gamification/challenges/claim-history?limit=10&page=1', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${userToken}`,
    'Accept': 'application/json'
  }
})
.then(response => response.json())
.then(data => {
  // data.data.items = array of claimed challenges
  // data.data.total = total claimed challenges
  // data.data.current_page, last_page = untuk pagination
  
  renderClaimHistory(data.data.items, data.data);
})
```

---

## 5. Field Explanation - Penting untuk Frontend

| Field | Type | Deskripsi |
|-------|------|-----------|
| `id` | int | ID achievement (challenge) |
| `user_achievement_id` | int | ID record di user_achievements table |
| `code` | string | Unique code challenge (e.g., "DAILY_CHECKIN_5") |
| `name` | string | Display name challenge |
| `is_completed` | boolean | True jika progress >= target |
| `is_claimed` | boolean | True jika rewards sudah di-claim |
| `completed_at` | string (ISO8601) | Timestamp saat challenge selesai |
| `claimed_at` | string (ISO8601) | Timestamp saat di-claim (null jika belum) |
| `reward_coins` | int | Jumlah coins yang akan didapat |
| `reward_xp` | int | Jumlah XP yang akan didapat |
| `reset_schedule` | enum | "daily", "weekly", atau "none" |

---

## 6. Logic Untuk Menentukan Button State

```
Challenge State Decision Tree:

if (is_completed === false) {
  // ONGOING
  Status: "IN PROGRESS"
  Button: Disabled
  Progress: Show % (e.g., 3/5)
}
else if (is_completed === true && is_claimed === false) {
  // COMPLETED, READY TO CLAIM
  Status: "READY TO CLAIM" (green badge)
  Button: "CLAIM REWARDS" (enabled, primary color)
  Progress: 100%
}
else if (is_completed === true && is_claimed === true) {
  // COMPLETED AND CLAIMED
  Status: "CLAIMED" (grey badge) + Date
  Button: "CLAIMED" (disabled, grey)
  Progress: 100%
}
```

---

## 7. Error Handling Reference

| HTTP Code | Error Message | Frontend Action |
|-----------|---------------|-----------------|
| 401 | Unauthorized | Redirect ke login |
| 404 | Challenge not found | Refresh page / Reload data |
| 409 | Not yet completed | Tampilkan "Complete challenge first" |
| 409 | Already claimed | Refresh page, update to "CLAIMED" status |
| 500 | Server error | Retry button, show fallback message |

---

## 8. Data Structure - Challenge dengan Claim Info

### Stored in: `user_achievements.additional_info`

```json
{
  "claim_info": {
    "is_claimed": true,
    "claimed_at": "2026-03-03T16:45:32.123456Z"
  }
}
```

### Notes:
- `is_claimed`: Boolean flag untuk mengetahui challenge sudah diklaim atau belum
- `claimed_at`: ISO8601 timestamp kapan challenge di-claim (null jika belum diklaim)
- Data ini dimulai sebagai empty object ketika challenge pertama kali completed
- Saat claim, field ini di-merge (tidak overwrite existing data)

---

## 9. Implementasi Backend (Reference)

### Service Methods:
1. **`getClaimableChallenges(User $user)`** - List challenges yang bisa diklaim
2. **`claimChallenge(User $user, int $challenge_id)`** - Claim rewards
3. **`getClaimHistory(User $user, int $limit, int $page)`** - View history

### Controller Methods:
1. **`claimableChallenges(Request $request)`** - GET endpoint
2. **`claimChallenge(Request $request, int $challenge_id)`** - POST endpoint
3. **`challengeClaimHistory(Request $request)`** - GET history endpoint

### Routes:
```
GET    /api/v2/gamification/challenges/claimable
POST   /api/v2/gamification/challenges/claim/{challenge_id}
GET    /api/v2/gamification/challenges/claim-history
```

---

## Version
- **Created:** March 3, 2026
- **Version:** 1.0
- **Status:** Ready for Frontend Implementation
