## 📊 DIAGRAM & PENJELASAN LOGIC LIKE & COMMENT (SAAT INI)

---

## 1️⃣ LIKE POST FLOW

### **Architecture Flow:**

```
┌─────────────────────────────────────────────────────────────────────┐
│                          USER INTERFACE                              │
│  (PostCard / PostDetailView)                                        │
│  • User tap ❤️ icon                                                 │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      HOME CONTROLLER                                 │
│  toggleLikePost(postId)                                             │
│                                                                      │
│  1️⃣ Check if already toggling → return early                        │
│  2️⃣ Optimistic UI Update:                                           │
│     • If liked → remove from _likedPostIds                          │
│     • If not liked → add to _likedPostIds                           │
│     • Update post likesCount ±1                                     │
│  3️⃣ Call Repository                                                 │
│  4️⃣ Sync with backend result                                        │
│  5️⃣ If error → Revert changes                                       │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      POST REPOSITORY                                 │
│  toggleLikePost(postId)                                             │
│                                                                      │
│  1️⃣ Check network connectivity                                      │
│  2️⃣ If no network → throw NetworkException                          │
│  3️⃣ Call RemoteDataSource.toggleLikePost()                         │
│  4️⃣ Return boolean result                                           │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   POST REMOTE DATASOURCE                             │
│  toggleLikePost(postId)                                             │
│                                                                      │
│  1️⃣ Build endpoint:                                                 │
│     ApiEndpoints.postLike.replaceFirst('{post_id}', '$postId')     │
│     Result: '/social/posts/id/{post_id}/like'                      │
│             → '/social/posts/id/123/like'                           │
│                                                                      │
│  2️⃣ Make HTTP POST request via DioClient                            │
│                                                                      │
│  3️⃣ Parse response with extractApiResponseData<bool>:               │
│     ❌ PROBLEM: Expect boolean, but got object!                     │
│     final isLiked = extractApiResponseData<bool>(                   │
│       response,                                                      │
│       (json) => json as bool  ← CRASH HERE!                         │
│     );                                                               │
│                                                                      │
│  4️⃣ Return boolean (never reaches here)                             │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         DIO CLIENT                                   │
│  • Add auth headers (Bearer token)                                  │
│  • Build full URL:                                                  │
│    https://test.snappie.my.id/api/v2/social/posts/id/123/like      │
│  • Send POST request                                                │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      BACKEND API                                     │
│  POST /api/v2/social/posts/id/123/like                             │
│                                                                      │
│  Response (200 OK):                                                 │
│  {                                                                   │
│    "success": true,                                                 │
│    "message": "Post liked",                                         │
│    "data": {                                                        │
│      "action": "like",      ← This is OBJECT, not boolean!         │
│      "post_id": 17                                                  │
│    }                                                                │
│  }                                                                   │
└─────────────────────────────────────────────────────────────────────┘
```

---

### **Detail Step-by-Step:**

#### **STEP 1: UI Interaction (PostCard)**
```dart
// post_card.dart
GestureDetector(
  onTap: () {
    try {
      await controller.toggleLikePost(postId);
    } catch (e) {
      Get.snackbar('Error', e.toString()); // Shows technical error ❌
    }
  },
  child: Icon(isLiked ? Icons.favorite : Icons.favorite_border)
)
```

**Current Issue:**
- Error langsung diexpose ke user (technical message)
- No loading state during request

---

#### **STEP 2: Controller (home_controller.dart:173-221)**
```dart
Future<void> toggleLikePost(int postId) async {
  // Guard: Prevent double-tap
  if (_isTogglingLikePostIds.contains(postId)) return;
  
  _isTogglingLikePostIds.add(postId);
  final currentlyLiked = _likedPostIds.contains(postId);
  
  // 🎯 OPTIMISTIC UPDATE
  if (currentlyLiked) {
    _likedPostIds.remove(postId);  // UI: Unlike
  } else {
    _likedPostIds.add(postId);     // UI: Like
  }
  
  // Update count immediately
  final postIndex = _posts.indexWhere((p) => p.id == postId);
  if (postIndex != -1) {
    final post = _posts[postIndex];
    final newCount = (post.likesCount ?? 0) + (currentlyLiked ? -1 : 1);
    _posts[postIndex] = post.copyWith(likesCount: newCount);
  }
  
  try {
    // 🌐 API CALL
    final isLiked = await postRepository.toggleLikePost(postId);
    
    // 🔄 SYNC with backend
    if (isLiked && !_likedPostIds.contains(postId)) {
      _likedPostIds.add(postId);
    } else if (!isLiked && _likedPostIds.contains(postId)) {
      _likedPostIds.remove(postId);
    }
    
  } catch (e) {
    // 🔙 REVERT on error
    if (currentlyLiked) {
      _likedPostIds.add(postId);
    } else {
      _likedPostIds.remove(postId);
    }
    
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final revertCount = (post.likesCount ?? 0) + (currentlyLiked ? 1 : -1);
      _posts[postIndex] = post.copyWith(likesCount: revertCount);
    }
    
    rethrow; // ❌ Error bubbles up to UI
    
  } finally {
    _isTogglingLikePostIds.remove(postId);
  }
}
```

**Current Issues:**
1. ✅ **Good:** Optimistic update
2. ✅ **Good:** Revert on failure
3. ❌ **Bad:** `_likedPostIds` never initialized from backend
4. ❌ **Bad:** Error rethrown to UI (no sanitization)

---

#### **STEP 3: Repository (post_repository_impl.dart:74-82)**
```dart
Future<bool> toggleLikePost(int postId) async {
  // Check network
  if (!(await networkInfo.isConnected)) {
    throw NetworkException('No internet connection');
  }
  
  // Delegate to datasource
  return await remoteDataSource.toggleLikePost(postId);
}
```

**Current Issues:**
- ✅ **Good:** Network check
- ✅ **Good:** Simple delegation
- ❌ **Bad:** No error transformation

---

#### **STEP 4: Datasource (post_remote_datasource.dart:152-173) - CRASH POINT**
```dart
@override
Future<bool> toggleLikePost(int postId) async {
  try {
    final response = await dioClient.dio.post(
      ApiEndpoints.postLike.replaceFirst('{post_id}', '$postId'),
      // URL: /social/posts/id/17/like
    );
    
    // ❌ CRASH HERE!
    // Backend returns: { "action": "like", "post_id": 17 }
    // Code expects: true or false
    final isLiked = extractApiResponseData<bool>(
      response,
      (json) => json as bool,  // ← Type Cast Error!
    );
    
    return isLiked;
    
  } on ApiResponseException catch (e) {
    throw ServerException(e.message, e.statusCode ?? 500);
  } on DioException catch (e) {
    throw _mapDioException(e);
  } catch (e) {
    throw ServerException('Unexpected error occurred: $e', 500);
  }
}
```

**Root Cause:**
```
Backend Response:     { "action": "like", "post_id": 17 }
Code Expectation:     true (boolean)
Result:              Type Cast Exception → ServerException
```

---

## 2️⃣ COMMENT POST FLOW

### **Architecture Flow:**

```
┌─────────────────────────────────────────────────────────────────────┐
│                          USER INTERFACE                              │
│  (PostDetailView)                                                   │
│  • User types comment in TextField                                  │
│  • User taps send icon                                              │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    POST DETAIL VIEW                                  │
│  _submitComment()                                                   │
│                                                                      │
│  1️⃣ Validate: comment not empty                                     │
│  2️⃣ Call Repository.createComment()                                │
│  3️⃣ Clear text field                                                │
│  4️⃣ Reload entire post (fetch fresh data)                          │
│  5️⃣ Show success/error snackbar                                     │
│                                                                      │
│  ⚠️ PROBLEM: No sync with HomeController!                           │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      POST REPOSITORY                                 │
│  createComment(postId, comment)                                     │
│                                                                      │
│  1️⃣ Check network connectivity                                      │
│  2️⃣ If no network → throw NetworkException                          │
│  3️⃣ Call RemoteDataSource.createComment()                          │
│  4️⃣ Return CommentModel                                             │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   POST REMOTE DATASOURCE                             │
│  createComment(postId, comment)                                     │
│                                                                      │
│  1️⃣ Build endpoint:                                                 │
│     ApiEndpoints.postComment.replaceFirst('{post_id}', '$postId')  │
│     Result: '/social/posts/id/123/comment'                         │
│                                                                      │
│  2️⃣ Build request body:                                             │
│     { "comment": "Great post!" }                                    │
│                                                                      │
│  3️⃣ Make HTTP POST request via DioClient                            │
│                                                                      │
│  4️⃣ Parse response with extractApiResponseData<CommentModel>:       │
│     ⚠️ UNKNOWN: Response structure not verified!                    │
│     Might crash like toggleLike if structure mismatch               │
│                                                                      │
│  5️⃣ Return CommentModel                                             │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         DIO CLIENT                                   │
│  • Add auth headers                                                 │
│  • Build full URL                                                   │
│  • Send POST with body                                              │
└────────────────────┬────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      BACKEND API                                     │
│  POST /api/v2/social/posts/id/123/comment                          │
│  Body: { "comment": "Great post!" }                                │
│                                                                      │
│  Response: ???                                                      │
│  • Might return full CommentModel ✅                                │
│  • Might return success message only ❌                             │
│  • Need to verify actual response structure                         │
└─────────────────────────────────────────────────────────────────────┘
```

---

### **Detail Step-by-Step:**

#### **STEP 1: UI (post_detail_view.dart:600-635)**
```dart
Widget _buildCommentInput() {
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: _commentController,
          decoration: InputDecoration(hintText: 'Tulis komentar...'),
        ),
      ),
      IconButton(
        onPressed: _submitComment,
        icon: Icon(Icons.send),
      ),
    ],
  );
}

void _submitComment() async {
  final comment = _commentController.text.trim();
  final postId = _post?.id;
  
  if (comment.isEmpty || postId == null) return;
  
  try {
    // Call repository
    await _postRepository.createComment(postId, comment);
    
    // Clear input
    _commentController.clear();
    
    // Reload post (refetch from API)
    await _loadPost();
    
    // Success message
    Get.snackbar('Berhasil', 'Komentar berhasil ditambahkan');
    
  } catch (e) {
    // ❌ Error exposed to user
    Get.snackbar('Gagal', 'Tidak dapat menambahkan komentar');
  }
}
```

**Current Issues:**
1. ❌ PostDetailView uses **local state** (not GetX controller)
2. ❌ No sync with HomeController after comment
3. ❌ Full post reload (inefficient)
4. ❌ Error message generic but still shows technical error in logs

---

#### **STEP 2: Repository (post_repository_impl.dart:85-94)**
```dart
Future<CommentModel> createComment(int postId, String comment) async {
  if (!(await networkInfo.isConnected)) {
    throw NetworkException('No internet connection');
  }
  
  return await remoteDataSource.createComment(postId, comment);
}
```

---

#### **STEP 3: Datasource (post_remote_datasource.dart:175-193)**
```dart
@override
Future<CommentModel> createComment(int postId, String comment) async {
  try {
    final response = await dioClient.dio.post(
      ApiEndpoints.postComment.replaceFirst('{post_id}', '$postId'),
      data: {'comment': comment},
    );
    
    // ⚠️ POTENTIAL CRASH if response structure mismatch
    return extractApiResponseData<CommentModel>(
      response,
      (json) => CommentModel.fromJson(json as Map<String, dynamic>),
    );
    
  } on ApiResponseException catch (e) {
    throw ServerException(e.message, e.statusCode ?? 500);
  } on DioException catch (e) {
    throw _mapDioException(e);
  } catch (e) {
    throw ServerException('Unexpected error occurred: $e', 500);
  }
}
```

---

## 🎯 SUMMARY MASALAH

### **LIKE:**
| Issue | Impact | Severity |
|-------|--------|----------|
| Response type mismatch (expect bool, got object) | **CRASH** | 🔴 CRITICAL |
| `_likedPostIds` never initialized from backend | UI tidak sync | 🟡 HIGH |
| Error exposed to user | Bad UX | 🟡 HIGH |

### **COMMENT:**
| Issue | Impact | Severity |
|-------|--------|----------|
| Response structure unknown | **MIGHT CRASH** | 🔴 CRITICAL |
| No sync between DetailView & HomeController | Stale data | 🟡 HIGH |
| PostDetailView not using GetX controller | Architecture inconsistency | 🟡 HIGH |
| Full post reload after comment | Inefficient | 🟢 MEDIUM |

### **GENERAL:**
| Issue | Impact | Severity |
|-------|--------|----------|
| Technical errors shown to users | Bad UX | 🔴 CRITICAL |
| No centralized error sanitization | Inconsistent error handling | 🟡 HIGH |

---

Apakah Anda punya **curl request & response untuk comment endpoint** juga? Saya perlu verify response structure sebelum implement fix yang tepat.