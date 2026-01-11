import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/constants/food_type.dart';
import 'package:snappie_app/app/core/localization/locale_keys.g.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/_display_widgets/app_icon.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(title: tr(LocaleKeys.register_title), slivers: [
      SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderSection(),

                  const SizedBox(height: 16),

                  // Page Content
                  Obx(() {
                    switch (controller.selectedPageIndex) {
                      case 0:
                        return _buildInputDataUser();
                      case 1:
                        return _buildInputFoodType();
                      case 2:
                        return _buildInputPlaceValue();
                      default:
                        return _buildInputDataUser();
                    }
                  }),

                  const SizedBox(height: 24),

                  // Navigation Buttons
                  Obx(() => Row(
                        children: [
                          if (controller.selectedPageIndex > 0)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.previousPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                ),
                                child: Text(
                                  tr(LocaleKeys.register_back),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          if (controller.selectedPageIndex > 0)
                            const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() {
                              // Reactive validation for each page
                              bool canProceed = false;

                              switch (controller.selectedPageIndex) {
                                case 0:
                                  // Page 1: Check if all fields are filled
                                  canProceed =
                                      controller.isFirstnameValid.value &&
                                          controller.isLastnameValid.value &&
                                          controller.selectedGender.value
                                              .isNotEmpty &&
                                          controller.selectedGender.value !=
                                              'others' &&
                                          controller.selectedAvatar.value
                                              .isNotEmpty &&
                                          controller.isUsernameValid.value;
                                  break;
                                case 1:
                                  // Page 2: Check if exactly 3 food types selected
                                  canProceed =
                                      controller.selectedFoodTypes.length == 3;
                                  break;
                                case 2:
                                  // Page 3: Check if exactly 3 place values selected
                                  canProceed =
                                      controller.selectedPlaceValues.length ==
                                          3;
                                  break;
                              }

                              return ElevatedButton(
                                onPressed: canProceed
                                    ? () {
                                        if (controller.selectedPageIndex < 2) {
                                          controller.nextPage();
                                        } else {
                                          controller.register();
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  disabledForegroundColor: Colors.grey.shade600,
                                ),
                                child: Text(
                                  controller.selectedPageIndex < 2
                                      ? tr(LocaleKeys.register_next)
                                      : tr(LocaleKeys.register_submit),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      )),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ))
    ]);
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          tr(LocaleKeys.register_join_us),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          tr(LocaleKeys.register_subtitle),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        // Progress Indicator
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: 90,
                  decoration: BoxDecoration(
                    color: index <= controller.selectedPageIndex
                        ? AppColors.accent
                        : AppColors.accent.withAlpha(75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputDataUser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Form Section Title
        Text(
          tr(LocaleKeys.register_complete_profile),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Email field (read-only, from Google)
        Text(
          tr(LocaleKeys.register_email),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.registerEmailController,
          enabled: false,
          decoration: InputDecoration(
            hintText: tr(LocaleKeys.register_email_hint),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            fillColor: Colors.grey.shade100,
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),

        // First Name and Last Name Row
        Text(
          tr(LocaleKeys.register_full_name),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.firstnameController,
                decoration: InputDecoration(
                  hintText: tr(LocaleKeys.register_first_name),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller.lastnameController,
                decoration: InputDecoration(
                  hintText: tr(LocaleKeys.register_last_name),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Gender Selection
        Text(
          tr(LocaleKeys.register_gender),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Obx(
          () => RadioGroup<Gender>(
            groupValue: controller.selectedGenderEnum,
            onChanged: (Gender? value) {
              if (value != null) controller.setGender(value);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () => controller.setGender(Gender.male),
                  child: Row(
                    children: [
                      Radio<Gender>(
                        value: Gender.male,
                      ),
                      Text(tr(LocaleKeys.register_male)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: () => controller.setGender(Gender.female),
                  child: Row(
                    children: [
                      Radio<Gender>(
                        value: Gender.female,
                      ),
                      Text(tr(LocaleKeys.register_female)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Show avatar picker button if gender is selected
        Obx(
          () => controller.selectedGender.value != 'others'
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar grid (show/hide based on toggle)
                    Obx(
                      () => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: controller.selectedGender.value.isNotEmpty
                            ? null
                            : 0,
                        child: controller.selectedGender.value.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    tr(LocaleKeys.register_choose_avatar),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(top: 0),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      crossAxisSpacing: 12,
                                    ),
                                    itemCount: controller
                                        .getAvatarOptions(
                                            controller.selectedGender.value)
                                        .length,
                                    itemBuilder: (context, index) {
                                      final avatar =
                                          controller.getAvatarOptions(controller
                                              .selectedGender.value)[index];
                                      return GestureDetector(
                                        onTap: () {
                                          controller.setAvatar(avatar['path']);
                                        },
                                        child: Obx(
                                          () => Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  avatar['color'].withAlpha(75),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: controller.selectedAvatar
                                                            .value ==
                                                        avatar['path']
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                width: controller.selectedAvatar
                                                            .value ==
                                                        avatar['path']
                                                    ? 3
                                                    : 0,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: ClipRRect(
                                              child: Image.network(
                                                avatar['path'],
                                                fit: BoxFit.contain,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null)
                                                    return child;
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  // Fallback to local asset if network fails
                                                  return Image.asset(
                                                    avatar['localPath'],
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return AppIcon(
                                                          AppAssets.iconsSvg
                                                              .profile,
                                                          size: 40);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),

        // Username field
        Text(
          tr(LocaleKeys.register_username),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          tr(LocaleKeys.register_username_validation),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.usernameController,
          decoration: InputDecoration(
            hintText: tr(LocaleKeys.register_username_hint),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildInputFoodType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.register_choose_food_types),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Food type selection grid
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemCount: controller.foodTypes.length,
          itemBuilder: (context, index) {
            final foodType = controller.foodTypes[index];
            final imagePath = FoodTypeExtension.getImageByLabel(foodType);

            return Obx(
              () {
                final isSelected =
                    controller.selectedFoodTypes.contains(foodType);
                final isLimitReached = controller.selectedFoodTypes.length >= 3;
                final isDisabled = !isSelected && isLimitReached;

                return GestureDetector(
                  onTap: () {
                    controller.toggleFoodTypeSelection(foodType);
                  },
                  child: Opacity(
                    opacity: isDisabled ? 0.4 : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha(50)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            imagePath!,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            foodType,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInputPlaceValue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          tr(LocaleKeys.register_choose_place_values),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Place value selection grid
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: controller.placeValues.length,
          itemBuilder: (context, index) {
            final placeValue = controller.placeValues[index];

            return Obx(
              () {
                final isSelected =
                    controller.selectedPlaceValues.contains(placeValue);
                final isLimitReached =
                    controller.selectedPlaceValues.length >= 3;
                final isDisabled = !isSelected && isLimitReached;

                return GestureDetector(
                  onTap: () {
                    controller.togglePlaceValueSelection(placeValue);
                  },
                  child: Opacity(
                    opacity: isDisabled ? 0.4 : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withAlpha(100)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Text(
                        placeValue,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              isSelected ? AppColors.primary : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
