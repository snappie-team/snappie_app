import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../shared/widgets/index.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Notifikasi',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text(
                'Hari ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              // TODO: Apply real data using dynamic data from controller
              NotificationCardWidget(
                avatar: 'avatar_m1_hdpi.png',
                title: 'm.tafif mengikuti anda.',
                buttonLabel: 'Ikuti Balik',
                onButtonTap: () {
                  Get.snackbar('Info', 'Kamu mengikuti balik m.tafif', snackPosition: SnackPosition.BOTTOM);
                },
                onMoreTap: () {},
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
