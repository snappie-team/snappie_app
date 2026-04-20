import 'package:snappie_app/app/data/models/articles_model.dart';
import 'package:snappie_app/app/data/models/leaderboard_model.dart';
import 'package:snappie_app/app/data/models/place_model.dart';
import 'package:snappie_app/app/data/models/post_model.dart';
import 'package:snappie_app/app/data/models/user_model.dart';

class MockData {
  static UserModel get testUser {
    final settings = UserSettings()..frameUrl = '';

    return UserModel()
      ..id = 1
      ..name = 'Test User'
      ..username = 'testuser'
      ..email = 'test@snappie.com'
      ..imageUrl = 'https://example.com/avatar.jpg'
      ..totalCoin = 120
      ..totalExp = 320
      ..totalFollowing = 5
      ..totalFollower = 8
      ..totalCheckin = 2
      ..totalPost = 1
      ..totalArticle = 0
      ..totalReview = 1
      ..totalAchievement = 1
      ..userSettings = settings;
  }

  static List<PlaceModel> get testPlaces {
    final place1 = PlaceModel()
      ..id = 1
      ..name = 'Warung Hidden Gem'
      ..description = 'Makanan rumahan enak'
      ..avgRating = 4.5
      ..partnershipStatus = true
      ..foodType = ['Non-Sup']
      ..placeValue = ['Harga Terjangkau']
      ..imageUrls = [
        PlaceImage()..url = 'https://example.com/place1.jpg',
      ];

    final place2 = PlaceModel()
      ..id = 2
      ..name = 'Kedai Rahasia'
      ..description = 'Kedai kopi nyaman'
      ..avgRating = 4.8
      ..partnershipStatus = false
      ..foodType = ['Mi Instan']
      ..placeValue = ['Suasana Tenang']
      ..imageUrls = [
        PlaceImage()..url = 'https://example.com/place2.jpg',
      ];

    return [place1, place2];
  }

  static List<PostModel> get testPosts {
    final user = UserPost()
      ..id = 2
      ..name = 'Foodie'
      ..username = 'foodie';

    final post = PostModel()
      ..id = 1
      ..userId = 2
      ..placeId = 1
      ..content = 'Tempat ini amazing!'
      ..imageUrls = ['https://example.com/post1.jpg']
      ..likesCount = 10
      ..commentsCount = 2
      ..user = user;

    return [post];
  }

  static List<ArticlesModel> get testArticles {
    final article = ArticlesModel()
      ..id = 1
      ..title = 'Kuliner Hidden Gem Jakarta'
      ..category = 'Kuliner'
      ..author = 'Snappie Team'
      ..description = 'Daftar hidden gem terbaik';

    return [article];
  }

  static UserSaved get testUserSaved {
    final savedPlace = SavedPlacePreview()
      ..id = 1
      ..name = 'Warung Hidden Gem';

    final savedPost = SavedPostPreview()
      ..id = 1
      ..contentPreview = 'Tempat ini amazing!';

    return UserSaved()
      ..savedPlaces = [savedPlace]
      ..savedPosts = [savedPost]
      ..savedArticles = [1];
  }

  static List<LeaderboardEntry> get weeklyLeaderboard {
    final entry = LeaderboardEntry()
      ..rank = 1
      ..userId = 1
      ..name = 'Test User'
      ..username = 'testuser'
      ..totalExp = 320
      ..totalCheckin = 2
      ..period = 'weekly';

    return [entry];
  }

  static List<LeaderboardEntry> get monthlyLeaderboard {
    final entry = LeaderboardEntry()
      ..rank = 1
      ..userId = 1
      ..name = 'Test User'
      ..username = 'testuser'
      ..totalExp = 640
      ..totalCheckin = 4
      ..period = 'monthly';

    return [entry];
  }
}
