import 'package:flutter/material.dart';
import 'package:pixcellz/utils/shared_prefs_manager.dart';

class PixCellZAppBar extends StatefulWidget implements PreferredSizeWidget {
  const PixCellZAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  State<PixCellZAppBar> createState() => _PixCellZAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PixCellZAppBarState extends State<PixCellZAppBar> {
  late bool _isLogged;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    _isLogged = await SharedPreferencesManager.isUserLoggedIn();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(
        widget.title,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      actions: [
        if (widget.actions != null) ...widget.actions!,
        _isLoading
            ? CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              )
            : _isLogged
                ? IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await SharedPreferencesManager.logoutUser();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      }
                    },
                  )
                : const SizedBox(),
      ],
    );
  }
}
