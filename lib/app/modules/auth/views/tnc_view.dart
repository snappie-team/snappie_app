import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import '../../shared/layout/views/scaffold_frame.dart';

class TncView extends StatefulWidget {
  const TncView({Key? key}) : super(key: key);

  @override
  State<TncView> createState() => _TncViewState();
}

class _TncViewState extends State<TncView> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: _currentPage == 0 ? 'Syarat dan Ketentuan' : 'Kebijakan Privasi',
      slivers: [
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
                child: _currentPage == 0
                    ? _buildTermsPage()
                    : _buildPrivacyPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Syarat dan Ketentuan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: '1. Penggunaan Aplikasi',
          content:
              'Aplikasi Snappie memungkinkan pengguna untuk mencari tempat kuliner hidden gems di sekitar mereka. Anda setuju untuk menggunakan aplikasi ini hanya untuk tujuan yang sah dan tidak melanggar hukum yang berlaku.',
        ),
        _buildSection(
          title: '2. Akun Pengguna',
          content:
              'Untuk mengakses fitur tertentu aplikasi Snappie, Anda diminta untuk membuat akun pengguna. Anda bertanggung jawab penuh untuk menjaga kerahsiaan informasi akun dan kata sandi Anda. Anda juga bertanggung jawab atas semua aktivitas yang terjadi di akun Anda.',
        ),
        _buildSection(
          title: '3. Hak Kekayaan Intelektual',
          content:
              'Semua konten yang ada dalam aplikasi Snappie, termasuk namun tidak terbatas pada teks, gambar, logo, dan desain aplikasi, adalah hak milik Snappie atau pemegang lisensi kami. Anda tidak diperbolehkan untuk menyalin, mendistribusikan, atau menggubah konten tanpa izin kami.',
        ),
        _buildSection(
          title: '4. Data Pribadi dan Privasi',
          content:
              'Kami mengumpulkan data pribadi Anda sesuai dengan Kebijakan Privasi yang kami sediakan. Dengan menggunakan aplikasi ini, Anda setuju untuk memberikan data pribadi Anda sebagaimana dijelaskan dalam Kebijakan Privasi kami.',
        ),
        _buildSection(
          title: '5. Pembatasan Tanggung Jawab',
          content:
              'Snappie tidak bertanggung jawab atas kerusakan atau kerugian yang timbul akibat penggunaan aplikasi, termasuk namun tidak terbatas pada kehilangan data, gangguan layanan, atau kerugian perangkat. Semua informasi yang disdediakan melalui aplikasi ini bersifat umum dan kami tidak menjamin kekuratan atau kelengkapan informasi tersebut.',
        ),
        _buildSection(
          title: '6. Pembaruan dan Perubahan Aplikasi',
          content:
              'Snappie dapat memperbaharui atau memodifikasi aplikasi dari waktu ke waktu, termasuk menambahkan atau menghapus fitur. Kami berhak untuk menghentikan layanan aplikasi atau layanan kapan saja tanpa pemberitahuan sebelumnya.',
        ),
        _buildSection(
          title: '7. Penghentian Akses',
          content:
              'Kami berhak untuk menangguhkan atau menghentikan akses Anda ke aplikasi Snappie jika Anda melanggar syarat dan ketentuan ini atau jika kami merasa perlu untuk melindungi keamanan aplikasi dan pengguna lainnya.',
        ),
        _buildSection(
          title: '8. Perubahan Syarat dan Ketentuan',
          content:
              'Kami dapat memperbarui syarat dan ketentuan ini dari waktu ke waktu. Setiap perubahan akan diumumkan melalui pembaruan aplikasi atau pemberitahuan langsung kepada Anda. Penggunaan aplikasi setelah perubahan syarat dan ketentuan berarti Anda menerima perubahan tersebut.',
        ),
        _buildSection(
          title: '9. Hukum yang Berlaku',
          content:
              'Syarat dan ketentuan ini diatur oleh hukum yang berlaku di Indonesia. Setiap sengketa yang timbul terkait dengan aplikasi ini akan diselesaikan melalui proses hukum yang berlaku di Indonesia.',
        ),
        _buildSection(
          title: '10. Kontak',
          content:
              'Jika Anda memiliki pertanyaan atau masalah terkait dengan syarat dan ketentuan ini, Anda dapat menghubungi kami di alamat email.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            'Dengan menggunakan aplikasi Snappie, Anda menyetujui untuk mematuhi semua syarat dan ketentuan yang tercantum di atas.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 32),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildPrivacyPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kebijakan Privasi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Adanya kebijakan privasi ini adalah komitmen nyata dari Snappie untuk melindungi privasi Anda saat menikmati aplikasi kami. Kebijakan Privasi ini menjelaskan bagaimana Snappie mengumpulkan, menggunakan, melindungi, dan membagikan informasi pribadi Anda.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        _buildSection(
          title: '1. Informasi yang Kami Kumpulkan',
          content:
              'Kami mengumpulkan informasi berikut saat Anda menggunakan aplikasi Snappie:\n'
              '• Informasi Pribadi: Nama, alamat email, dan informasi lain yang Anda berikan saat mendaftar melalui interaksi dengan aplikasi.\n'
              '• Informasi Lokasi: Kami mengakses data lokasi untuk membantu Anda menemukan tempat kuliner terdekat.\n'
              '• Data Penggunaan: Kami mengumpulkan informasi terkait bagaimana Anda menggunakan aplikasi, seperti jenis perangkat, waktu penggunaan, dan interaksi dengan konten.',
        ),
        _buildSection(
          title: '2. Penggunaan Informasi',
          content: 'Informasi yang kami kumpulkan digunakan untuk:\n'
              '• Menyediakan dan mempersonalisasi layanan aplikasi.\n'
              '• Meningkatkan pengalaman pengguna dengan memberikan rekomendasi tempat kuliner yang relevan.\n'
              '• Mengumpulkan pembatuan atau informasi terkait aplikasi.',
        ),
        _buildSection(
          title: '3. Keamanan Informasi',
          content:
              'Kami berkomitmen untuk menjaga keamanan informasi pribadi Anda dengan menggunakan protokol keamanan yang sesuai. Meskipun kami berusaha keras untuk melindungi data Anda, tidak ada metode transmisi data melalui internet yang sepenuhnya aman.',
        ),
        _buildSection(
          title: '4. Berbagi Informasi',
          content:
              'Kami tidak akan membagikan informasi pribadi Anda kepada pihak ketiga tanpa izin Anda, kecuali jika diwajibkan oleh hukum atau untuk memberikan layanan yang Anda minta (misalnya, berbagi informasi dengan penyedia layanan atau mitra yang membantu aplikasi kami).',
        ),
        _buildSection(
          title: '5. Pengaturan Privasi Anda',
          content:
              'Anda dapat mengelola preferensi privasi Anda, termasuk memperbarui atau menghapus informasi pribadi melalui pengaturan aplikasi. Jika Anda tidak ingin berbagi data lokasi, Anda dapat menonaktifkan fitur tersebut di pengaturan perangkat Anda.',
        ),
        _buildSection(
          title: '6. Perubahan pada Kebijakan Privasi',
          content:
              'Kami dapat memperbarui Kebijakan Privasi ini dari waktu ke waktu. Setiap perubahan akan diumumkan melalui pembaruan aplikasi atau pemberitahuan langsung.',
        ),
        _buildSection(
          title: '7. Kontak',
          content:
              'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, Anda dapat menghubungi kami di alamat email.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Text(
            'Dengan menggunakan aplikasi Snappie, Anda menyetujui pengumpulan dan penggunaan data Anda sebagaimana dijelaskan dalam Kebijakan Privasi ini.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        const SizedBox(height: 32),
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
