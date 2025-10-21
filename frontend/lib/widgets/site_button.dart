import 'package:flutter/material.dart';

class SiteFilterButtons extends StatelessWidget {
  final String selectedSite;
  final Function(String) onSelected;

  const SiteFilterButtons({
    super.key,
    required this.selectedSite,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sites = [
      {"code": "fmkorea", "name": "에펨코리아"},
      {"code": "dcinside", "name": "디시인사이드"},
      {"code": "naver", "name": "네이버"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: sites.map((site) {
          final isSelected = selectedSite == site["code"];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected
                    ? Colors.deepPurple.shade50
                    : Colors.transparent,
                side: BorderSide(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                // 같은 버튼을 다시 누르면 전체 보기 ("all")
                if (isSelected) {
                  onSelected("all");
                } else {
                  onSelected(site["code"]!);
                }
              },
              child: Text(
                site["name"]!,
                style: TextStyle(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
