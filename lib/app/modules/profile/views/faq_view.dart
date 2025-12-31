import 'package:flutter/material.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = _faqSections();

    return ScaffoldFrame.detail(
      title: 'FAQ',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final section = sections[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FaqCard(section: section),
                );
              },
              childCount: sections.length,
            ),
          ),
        ),
      ],
    );
  }

  List<_FaqSection> _faqSections() {
    return [
      _FaqSection(
        title: 'Mengenai Snappie',
        items: [
          _FaqItem(
            question: 'Apa itu Snappie?',
            answer:
                'Snappie adalah aplikasi yang berfokus pada pencarian dan rekomendasi tempat kuliner "hidden gems" di Pontianak yang dipilih secara kurasi dan berbasis gamifikasi.',
          ),
          _FaqItem(
            question: 'Bagaimana cara Snappie bekerja?',
            answer:
                'Kami menampilkan tempat kuliner yang telah dikurasi oleh tim Snappie. Tugas Anda adalah mencari, mengulas, dan membagikan pengalaman Anda untuk membantu orang lain.',
          ),
        ],
      ),
      _FaqSection(
        title: 'Fitur dan Ulasan',
        items: [
          _FaqItem(
            question: 'Bagaimana cara mencari tempat makan?',
            answer:
                'Gunakan fitur pencarian berdasarkan nama, lokasi, atau kata kunci. Anda juga bisa menggunakan filter untuk hasil yang lebih spesifik.',
          ),
          _FaqItem(
            question: 'Bolehkah saya mengulas tempat makan?',
            answer:
                'Tentu! Cari nama tempat yang Anda kunjungi, pergi ke halaman ulasan, lalu klik tombol "Beri Ulasan" untuk memberikan rating, menulis ulasan, atau mengunggah foto dan video.',
          ),
          _FaqItem(
            question: 'Bagaimana cara membagikan informasi tempat kuliner ke media sosial?',
            answer:
                'Pada halaman detail tempat, klik ikon "Bagikan" untuk memposting informasi tempat tersebut ke media sosial favorit Anda.',
          ),
        ],
      ),
      _FaqSection(
        title: 'Papan Peringkat, Tantangan, Hadiah, dan Pencapaian',
        items: [
          _FaqItem(
            question: 'Apa itu Papan Peringkat?',
            answer:
                'Papan Peringkat menampilkan daftar para kontributor terbaik di Snappie. Peringkat Anda ditentukan oleh jumlah XP yang Anda kumpulkan. Semakin aktif Anda menyelesaikan misi, semakin tinggi posisi Anda di papan peringkat.',
          ),
          _FaqItem(
            question: 'Apa itu Tantangan dan bagaimana cara mengikutinya?',
            answer:
                'Tantangan adalah misi khusus yang kami berikan kepada komunitas. Contohnya, "Ulas 3 tempat kopi dalam minggu ini." Anda bisa melihat tantangan yang tersedia di halaman profil Anda. Setelah menyelesaikannya, Anda akan mendapatkan hadiah ekstra!',
          ),
          _FaqItem(
            question: 'Bagaimana cara mendapatkan Hadiah Kupon?',
            answer:
                'Anda bisa mendapatkan Hadiah Kupon dengan menukarkan Koin yang sudah Anda kumpulkan dari misi yang telah diselesaikan.',
          ),
          _FaqItem(
            question: 'Apa itu Pencapaian?',
            answer:
                'Pencapaian adalah lencana atau badge permanen yang diberikan sebagai bentuk apresiasi atas kontribusi besar Anda di Snappie. Pencapaian ini tidak bisa ditukar, tetapi akan selalu terpajang di profil Anda sebagai bukti kontribusi dan pencapaian Anda dalam komunitas. Contohnya adalah lencana "Ulasan ke-50".',
          ),
        ],
      ),
    ];
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.section});
  final _FaqSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < section.items.length; i++) ...[
            _FaqQA(item: section.items[i]),
            if (i != section.items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FaqQA extends StatelessWidget {
  const _FaqQA({required this.item});
  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            children: [
              const TextSpan(text: 'Q: '),
              TextSpan(text: item.question),
            ],
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            children: [
              const TextSpan(text: 'A: '),
              TextSpan(text: item.answer),
            ],
          ),
        ),
      ],
    );
  }
}

class _FaqSection {
  const _FaqSection({required this.title, required this.items});
  final String title;
  final List<_FaqItem> items;
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}
