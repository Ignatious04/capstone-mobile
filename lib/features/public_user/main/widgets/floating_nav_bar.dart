import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:flutter/material.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(Icons.map_outlined, Icons.map, 'Map',),
    _NavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Reports'),
    _NavItem(Icons.home_outlined, Icons.home, 'Home'),
    _NavItem(Icons.menu_book_outlined, Icons.menu_book, 'Guidance'),
    _NavItem(Icons.account_circle_outlined, Icons.account_circle, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepOrange,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 75,
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: _items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const inactive = Colors.white70;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 25,
              color: selected ? Colors.white : inactive,
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: LabelText(
                  value: item.label,
                  color: selected ? Colors.deepOrange : inactive,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
