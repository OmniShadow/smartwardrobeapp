import 'package:flutter/material.dart';
import 'package:wardrobe/home/screens/clothes_screen.dart';
import 'package:wardrobe/home/screens/drawer_screen.dart';
import 'package:wardrobe/home/screens/settings_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        title: Text(
          'Smart Wardrobe',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 50),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
          ),
          children: const [
            HomeScreenTile(
              icon: Icons.checkroom,
              title: 'Clothes',
              page: ClothingListPage(),
            ),
            HomeScreenTile(
              icon: Icons.room_preferences,
              title: 'Outfits',
              page: ClothingListPage(),
            ),
            HomeScreenTile(
              icon: Icons.density_small_outlined,
              title: 'Drawers',
              page: DrawerScreen(),
            ),
            HomeScreenTile(
              icon: Icons.settings,
              title: 'Settings',
              page: SettingsPage(),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreenTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget page;
  const HomeScreenTile({
    super.key,
    required this.icon,
    required this.title,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return GridTile(
      footer: GridTileBar(
        title: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
      child: InkWell(
        onHover: (value) {},
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) {
              return page;
            },
          ));
        },
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(100),
              bottomEnd: Radius.circular(100),
              topEnd: Radius.circular(10),
              bottomStart: Radius.circular(10),
            ),
          ),
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(200),
          child: Center(
            child: Icon(
              icon,
              size: 200,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
      ),
    );
  }
}
