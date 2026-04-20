import 'scenarios/auth/login_flow_test.dart' as login_flow_test;
import 'scenarios/auth/register_flow_test.dart' as register_flow_test;
import 'scenarios/articles/browse_articles_test.dart' as browse_articles_test;
import 'scenarios/checkin/checkin_submit_test.dart' as checkin_submit_test;
import 'scenarios/explore/browse_places_test.dart' as browse_places_test;
import 'scenarios/explore/place_detail_test.dart' as place_detail_test;
import 'scenarios/gamification/coins_history_test.dart' as coins_history_test;
import 'scenarios/gamification/profile_gamification_test.dart'
    as profile_gamification_test;
import 'scenarios/leaderboard/leaderboard_test.dart' as leaderboard_test;
import 'scenarios/rewards/rewards_coupon_test.dart' as rewards_coupon_test;
import 'scenarios/review_post/create_post_test.dart' as create_post_test;
import 'scenarios/review_post/submit_review_test.dart' as submit_review_test;
import 'scenarios/social/like_post_test.dart' as like_post_test;
import 'scenarios/social/save_post_test.dart' as save_post_test;

void main() {
  login_flow_test.main();
  register_flow_test.main();
  browse_articles_test.main();
  browse_places_test.main();
  place_detail_test.main();
  coins_history_test.main();
  profile_gamification_test.main();
  leaderboard_test.main();
  rewards_coupon_test.main();
  checkin_submit_test.main();
  create_post_test.main();
  submit_review_test.main();
  like_post_test.main();
  save_post_test.main();
}
