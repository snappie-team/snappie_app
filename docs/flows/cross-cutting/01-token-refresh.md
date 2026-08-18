# User Flow: Cross-Cutting - Token Auto-Refresh

## Overview
Transparent token refresh on 401 responses. Handles expired access tokens using refresh tokens.

## Trigger Points
- Any API call returning 401 Unauthorized
- Dio interceptor in `DioClient`

## Components
- **Network**: `DioClient` (`lib/app/core/network/dio_client.dart`)
- **Service**: `AuthService` (`lib/app/core/services/auth_service.dart`)
- **Storage**: SharedPreferences (tokens)

## Activity Diagram

```mermaid
flowchart TD
    A[API Request] --> B[Dio Interceptor: Add Auth Header]
    B --> C[Request Sent]
    C --> D{Response Status}
    D -->|2xx| E[Return Response]
    D -->|401| F[Token Expired?]
    F -->|Yes| G[Attempt Refresh]
    F -->|No| H[Return Error]
    G --> I[POST /auth/refresh]
    I --> J{Refresh Success?}
    J -->|Yes| K[Update Tokens]
    K --> L[Retry Original Request]
    L --> M[Return Response]
    J -->|No| N[AuthService.logout]
    N --> O[Clear All Tokens]
    O --> P[Navigate to /login]
    H --> Q[Throw Exception]
```

## Sequence Diagram

```mermaid
sequenceDiagram
    participant App
    participant DioClient
    participant AuthService
    participant Backend API
    participant SharedPreferences
    participant GetX Navigation
    participant User

    App->>DioClient: API Request (e.g., getPosts)
    DioClient->>DioClient: Add Authorization: Bearer <access_token>
    DioClient->>Backend API: Request
    
    alt Success (2xx)
        Backend API-->>DioClient: Response
        DioClient-->>App: Response Data
    else 401 Unauthorized
        Backend API-->>DioClient: 401 Response
        
        DioClient->>DioClient: Check if refresh already in progress
        alt Refresh In Progress
            DioClient->>DioClient: Wait for refresh
        else First 401
            DioClient->>DioClient: Set refreshInProgress = true
            DioClient->>AuthService: refreshToken()
            
            AuthService->>SharedPreferences: Get refresh_token
            AuthService->>Backend API: POST /auth/refresh {refresh_token}
            
            alt Refresh Success (200)
                Backend API-->>AuthService: New {access_token, refresh_token, expiry}
                AuthService->>SharedPreferences: Update all tokens
                AuthService->>AuthService: Update in-memory tokens
                AuthService-->>DioClient: New access_token
                
                DioClient->>DioClient: Update default headers
                DioClient->>DioClient: refreshInProgress = false
                DioClient->>DioClient: Notify waiting requests
                
                DioClient->>Backend API: Retry Original Request (with new token)
                Backend API-->>DioClient: Response
                DioClient-->>App: Response Data
            else Refresh Failed (401/Network/Expired)
                Backend API-->>AuthService: Error
                AuthService->>AuthService: logout()
                
                AuthService->>SharedPreferences: Clear all auth keys
                AuthService->>Isar: Clear user cache
                AuthService->>FirebaseAuth: signOut()
                AuthService->>GoogleAuthService: signOut()
                AuthService->>AuthService: _isLoggedIn = false, _userData = null
                
                AuthService-->>DioClient: Refresh Failed
                DioClient->>DioClient: refreshInProgress = false
                
                DioClient->>GetX Navigation: offAllNamed(LOGIN)
                GetX Navigation->>User: Redirect to Login
            end
        end
    else Other Error (4xx/5xx)
        Backend API-->>DioClient: Error Response
        DioClient-->>App: Throw Exception
    end
```

## DioClient Interceptor Implementation

```dart
// lib/app/core/network/dio_client.dart (simplified)

class DioClient {
  static bool _isRefreshing = false;
  static final List<Function> _waitingRequests = [];

  static void setupInterceptors(Dio dio) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth header
        final token = AuthService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          
          try {
            final authService = Get.find<AuthService>();
            await authService.refreshToken(); // Updates tokens
            
            // Retry failed request
            final newToken = authService.token;
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            
            final response = await dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            // Refresh failed - logout
            await Get.find<AuthService>().logout();
            Get.offAllNamed(AppPages.LOGIN);
            return handler.reject(error);
          } finally {
            _isRefreshing = false;
            // Process waiting requests
            for (final callback in _waitingRequests) {
              callback();
            }
            _waitingRequests.clear();
          }
        }
        
        // For waiting requests
        if (error.response?.statusCode == 401 && _isRefreshing) {
          return _retryAfterRefresh(error, handler);
        }
        
        return handler.next(error);
      },
    ));
  }
}
```

## AuthService.refreshToken()

```dart
// lib/app/core/services/auth_service.dart
Future<void> refreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString('refresh_token');
  
  if (refreshToken == null) throw Exception('No refresh token');
  
  final response = await _dio.post('/auth/refresh', data: {
    'refresh_token': refreshToken,
  });
  
  // Save new tokens
  await _saveTokens(response.data);
}

Future<void> _saveTokens(Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('access_token', data['access_token']);
  await prefs.setString('refresh_token', data['refresh_token']);
  await prefs.setInt('token_expiry', DateTime.now()
    .add(Duration(seconds: data['expires_in'])).millisecondsSinceEpoch);
  
  _accessToken = data['access_token'];
  _refreshToken = data['refresh_token'];
  _tokenExpiry = prefs.getInt('token_expiry');
}
```

## Error Handling Flow

| Refresh Result | Action |
|----------------|--------|
| Success (200) | Update tokens, retry original request |
| 401 (Invalid refresh) | Logout → `/login` |
| 403 (Revoked) | Logout → `/login` |
| Network Error | Logout → `/login` |
| Timeout | Logout → `/login` |

## User Experience

```
Normal API Call
       │
       ▼
┌──────────────────┐
│ 401 Received     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Silent Refresh   │
│ (Background)     │
└────────┬─────────┘
         │
    ┌────┴────┐
    ▼         ▼
 Success   Failed
    │         │
    ▼         ▼
 Retry    Logout +
 Request  Redirect
    │         │
    ▼         ▼
 Success   Login
  (User    Screen
  unaware)
```

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Multiple simultaneous 401s | Queue waits for single refresh |
| Refresh during app startup | `AuthService.onInit()` handles |
| Refresh token expired | Logout |
| Network offline | Logout (after retry) |
| User force-closes during refresh | Next launch: tokens invalid → onboarding |
| Background/foreground | No auto-refresh (only on API call) |

## Testing Checklist

- [ ] Valid token: Request succeeds
- [ ] Expired access + valid refresh: Silent refresh + retry
- [ ] Expired refresh: Logout → login
- [ ] Multiple parallel 401s: Single refresh, all retry
- [ ] Refresh network error: Logout
- [ ] Refresh 403: Logout
- [ ] No refresh token: Logout
- [ ] Token update persists across requests
- [ ] User unaware of silent refresh

## Related Files

- `lib/app/core/network/dio_client.dart`
- `lib/app/core/services/auth_service.dart` (refreshToken, logout, _saveTokens)
- `lib/app/core/helpers/api_response_helpers.dart` (error extraction)