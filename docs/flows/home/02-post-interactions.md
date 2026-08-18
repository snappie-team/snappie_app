# User Flow: Post Interactions (Like, Save, Follow, Share, Comment, Detail)

## Overview
Optimistic UI updates for social interactions on home feed posts. All interactions use optimistic updates with rollback on failure.

## Entry Points
- HomeView: Post cards in feed
- PostDetailView: Individual post view
- Controller: `HomeController`

## Components
- **Controller**: `HomeController` (`lib/app/modules/home/controllers/home_controller.dart`)
- **Repositories**: `PostRepository`, `SocialRepository`, `UserRepository`
- **Views**: `HomeView`, `PostDetailView`, `PostCard` widget

## Activity Diagram: Like/Unlike Post

```mermaid
flowchart TD
    A[User Taps Heart Icon] --> B{Already Liked?}
    B -->|Yes| C[Optimistic: Remove from _likedPostIds]
    B -->|No| D[Optimistic: Add to _likedPostIds]
    C --> E[Update Post likesCount -1]
    D --> F[Update Post likesCount +1]
    E --> G[PostRepository.toggleLikePost]
    F --> G
    G --> H{API Success?}
    H -->|Yes| I[Confirm State]
    H -->|No| J[Revert Optimistic]
    J --> K[Revert likesCount]
    K --> L[Show Error Snackbar]
    I --> M[UI Updated]
```

## Sequence Diagram: Like/Unlike Post

```mermaid
sequenceDiagram
    participant User
    participant PostCard
    participant HomeController
    participant PostRepository
    participant Backend API
    participant AppSnackbar

    User->>PostCard: Taps heart icon
    PostCard->>HomeController: toggleLikePost(postId)
    
    HomeController->>HomeController: Check _isTogglingLikePostIds.contains(postId)
    alt Already Toggling
        HomeController-->>PostCard: Return early
    else Not Toggling
        HomeController->>HomeController: _isTogglingLikePostIds.add(postId)
        HomeController->>HomeController: currentlyLiked = _likedPostIds.contains(postId)
        
        %% Optimistic Update
        alt Currently Liked (Unlike)
            HomeController->>HomeController: _likedPostIds.remove(postId)
            HomeController->>HomeController: post.likesCount--
        else Not Liked (Like)
            HomeController->>HomeController: _likedPostIds.add(postId)
            HomeController->>HomeController: post.likesCount++
        end
        
        HomeController->>PostRepository: toggleLikePost(postId)
        PostRepository->>Backend API: POST /posts/{id}/like
        
        alt Success (returns isLiked)
            Backend API-->>PostRepository: {isLiked: true/false}
            PostRepository-->>HomeController: isLiked
            
            HomeController->>HomeController: Sync with backend
            alt Backend says liked but local not
                HomeController->>HomeController: _likedPostIds.add(postId)
            else Backend says not liked but local yes
                HomeController->>HomeController: _likedPostIds.remove(postId)
            end
        else Failure
            Backend API-->>PostRepository: Error
            PostRepository-->>HomeController: Throws Exception
            
            HomeController->>HomeController: REVERT Optimistic
            alt Was Liked
                HomeController->>HomeController: _likedPostIds.add(postId)
                HomeController->>HomeController: post.likesCount++
            else Was Not Liked
                HomeController->>HomeController: _likedPostIds.remove(postId)
                HomeController->>HomeController: post.likesCount--
            end
            
            HomeController->>AppSnackbar: error('Gagal menyukai post')
            HomeController->>HomeController: Throw Exception
        end
        
        HomeController->>HomeController: _isTogglingLikePostIds.remove(postId)
    end
```

## Activity Diagram: Save/Unsave Post

```mermaid
flowchart TD
    A[User Taps Bookmark Icon] --> B{Already Saved?}
    B -->|Yes| C[Optimistic: Remove from _savedPostIds]
    B -->|No| D[Optimistic: Add to _savedPostIds]
    C --> E[UserRepository.toggleSavedPost with full list]
    D --> E
    E --> F{API Success?}
    F -->|Yes| G[Sync with Server Response]
    F -->|No| H[Revert Optimistic]
    H --> I[Reload Saved Posts from Server]
    I --> J[Show Error Snackbar]
    G --> K[UI Updated]
```

## Sequence Diagram: Save/Unsave Post

```mermaid
sequenceDiagram
    participant User
    participant PostCard
    participant HomeController
    participant UserRepository
    participant Backend API
    participant AppSnackbar

    User->>PostCard: Taps bookmark icon
    PostCard->>HomeController: toggleSavePost(postId)
    
    HomeController->>HomeController: Check _isTogglingSavedPostIds.contains(postId)
    alt Already Toggling
        HomeController-->>PostCard: Return early
    else Not Toggling
        HomeController->>HomeController: _isTogglingSavedPostIds.add(postId)
        HomeController->>HomeController: currentlySaved = _savedPostIds.contains(postId)
        
        %% Optimistic Update
        alt Currently Saved (Unsave)
            HomeController->>HomeController: _savedPostIds.remove(postId)
        else Not Saved (Save)
            HomeController->>HomeController: _savedPostIds.add(postId)
        end
        
        HomeController->>UserRepository: toggleSavedPost(_savedPostIds)
        Note over UserRepository: Sends FULL list of saved post IDs
        UserRepository->>Backend API: POST /user/saved-posts {post_ids: [...]}
        
        alt Success (returns updated list)
            Backend API-->>UserRepository: List<int> savedPostIds
            UserRepository-->>HomeController: updatedIds
            HomeController->>HomeController: _savedPostIds.assignAll(updatedIds)
        else Failure
            Backend API-->>UserRepository: Error
            UserRepository-->>HomeController: Throws Exception
            
            HomeController->>HomeController: REVERT Optimistic
            HomeController->>UserRepository: getUserSaved() // Reload from server
            HomeController->>AppSnackbar: error
            HomeController->>HomeController: Throw Exception
        end
        
        HomeController->>HomeController: _isTogglingSavedPostIds.remove(postId)
    end
```

## Activity Diagram: Follow/Unfollow User

```mermaid
flowchart TD
    A[User Taps Follow Button] --> B{Currently Following?}
    B -->|Yes| C[Optimistic: _followingOverrides[userId] = false]
    B -->|No| D[Optimistic: _followingOverrides[userId] = true]
    C --> E[SocialRepository.followUser]
    D --> E
    E --> F{API Success?}
    F -->|Yes| G[Override Confirmed]
    F -->|No| H[Revert Override]
    H --> I[Show Error Snackbar]
    G --> J[UI Updated]
```

## Sequence Diagram: Follow/Unfollow

```mermaid
sequenceDiagram
    participant User
    participant PostCard
    participant HomeController
    participant SocialRepository
    participant Backend API

    User->>PostCard: Taps follow button
    PostCard->>HomeController: toggleFollowUser(userId)
    
    HomeController->>HomeController: current = _isFollowing(userId)
    
    %% Optimistic Update
    HomeController->>HomeController: _followingOverrides[userId] = !current
    
    HomeController->>SocialRepository: followUser(userId)
    SocialRepository->>Backend API: POST /social/follow {user_id}
    
    alt Success
        Backend API-->>SocialRepository: Success
        SocialRepository-->>HomeController: Success
        HomeController->>HomeController: Override confirmed (no revert needed)
    else Failure
        Backend API-->>SocialRepository: Error
        SocialRepository-->>HomeController: Throws Exception
        
        HomeController->>HomeController: REVERT Override
        HomeController->>HomeController: _followingOverrides[userId] = current
        HomeController->>HomeController: Re-throw Exception
    end
```

## Post Detail Navigation

```mermaid
sequenceDiagram
    participant User
    participant HomeView
    participant HomeController
    participant GetX Navigation
    participant PostDetailView

    User->>HomeView: Taps post content
    HomeView->>HomeController: selectPost(post)
    HomeController->>HomeController: _selectedPost = post
    HomeController->>HomeController: _selectedImageUrls = post.imageUrls
    HomeController->>GetX Navigation: toNamed(AppPages.POST_DETAIL)
    GetX Navigation->>PostDetailView: Build with selectedPost
    PostDetailView->>HomeController: Get selectedPost + imageUrls
    PostDetailView->>User: Render full post detail
```

## Share & Comment (TODO)

```mermaid
sequenceDiagram
    participant User
    participant PostCard
    participant HomeController
    participant AppSnackbar

    User->>PostCard: Taps share icon
    PostCard->>HomeController: sharePost(postId)
    HomeController->>AppSnackbar: info('Post shared successfully!')
    Note over HomeController: TODO: Implement actual share

    User->>PostCard: Taps comment icon
    PostCard->>HomeController: commentPost(postId)
    HomeController->>AppSnackbar: info('Comment feature coming soon!')
    Note over HomeController: TODO: Implement comments
```

## State Management (Interaction Tracking)

| Variable | Purpose |
|----------|---------|
| `_isTogglingLikePostIds` | Prevents double-tap on like |
| `_isTogglingSavedPostIds` | Prevents double-tap on save |
| `_followingOverrides` | Optimistic follow state (Map<userId, bool>) |
| `_likedPostIds` | Local cache of liked posts |
| `_savedPostIds` | Local cache of saved posts |

## Optimistic Update Pattern

```dart
// Generic pattern used for all interactions
Future<void> toggleXxx(int id) async {
  // 1. Guard against double execution
  if (_isTogglingXxxIds.contains(id)) return;
  _isTogglingXxxIds.add(id);
  
  // 2. Capture current state
  final currentlyXxx = _xxxIds.contains(id);
  
  // 3. Optimistic update
  if (currentlyXxx) _xxxIds.remove(id); else _xxxIds.add(id);
  // Update related UI state (counts, etc.)
  
  try {
    // 4. API call
    final result = await repository.toggleXxx(id);
    
    // 5. Sync with backend
    if (result != currentlyXxx) {
      if (result) _xxxIds.add(id); else _xxxIds.remove(id);
    }
  } catch (e) {
    // 6. Revert on failure
    if (currentlyXxx) _xxxIds.add(id); else _xxxIds.remove(id);
    // Revert UI state
    rethrow;
  } finally {
    _isTogglingXxxIds.remove(id);
  }
}
```

## Error Handling

| Interaction | Failure Behavior |
|-------------|------------------|
| Like | Revert heart state + count, snackbar "Gagal menyukai post" |
| Save | Revert bookmark state, reload saved from server, snackbar |
| Follow | Revert follow button, snackbar (error bubbles up) |
| Share | Snackbar only (TODO) |
| Comment | Snackbar only (TODO) |

## Navigation Flow

```
┌──────────────────┐
│ HomeView         │
│ Feed: Post Cards │
└────────┬─────────┘
         │
    ┌────┼────┐
    ▼    ▼    ▼
 Like  Save  Follow
    │    │    │
    ▼    ▼    ▼
Optimistic    Optimistic    Optimistic
Update       Update         Update
    │    │    │
    └────┼────┘
         ▼
┌──────────────────┐
│ API Calls        │
│ (Parallel)       │
└────────┬─────────┘
         │
    ┌────┴────┐
    ▼         ▼
 Success    Failure
    │         │
    ▼         ▼
 Confirm    Revert + Snackbar
 State
```

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Rapid double-tap | `_isTogglingXxxIds` guard prevents duplicate API calls |
| Network timeout | Revert + snackbar |
| 401 during interaction | Dio interceptor refreshes token → retry (transparent) |
| 403/404 (post deleted) | Error snackbar, post may be removed from feed |
| Offline | NetworkException → revert + snackbar |
| Post updated externally | `HomeController.updatePost()` called from detail view |

## Testing Checklist

- [ ] Like: Heart toggles, count updates optimistically
- [ ] Like: Failure reverts heart + count, shows snackbar
- [ ] Save: Bookmark toggles optimistically
- [ ] Save: Failure reverts, reloads from server
- [ ] Follow: Button toggles optimistically
- [ ] Follow: Failure reverts button state
- [ ] Post detail: Navigates with correct data
- [ ] Share: Shows "coming soon" snackbar
- [ ] Comment: Shows "coming soon" snackbar
- [ ] Multiple rapid interactions handled correctly
- [ ] Token refresh during interaction works transparently

## Related Files

- `lib/app/modules/home/controllers/home_controller.dart` (lines 219-340)
- `lib/app/modules/home/views/home_view.dart`
- `lib/app/modules/home/views/post_detail_view.dart`
- `lib/app/modules/shared/widgets/_card_widgets/post_card.dart`
- `lib/app/data/repositories/post_repository_impl.dart`
- `lib/app/data/repositories/social_repository_impl.dart`
- `lib/app/data/repositories/user_repository_impl.dart`