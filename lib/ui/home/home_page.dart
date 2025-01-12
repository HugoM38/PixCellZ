import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pixcellz/services/pixcellz_service.dart';
import 'package:pixcellz/ui/pixcellz/pixcellz_page.dart';
import 'package:pixcellz/ui/widgets/pixcellz_appbar.dart';
import 'package:pixcellz/utils/shared_prefs_manager.dart';
import 'package:pixcellz/services/auth_service.dart';

class UserDrawing {
  final String id;
  final String userId;
  final int creationDate;
  final List<List<Map<String, dynamic>>> data;

  String? username;

  UserDrawing({
    required this.id,
    required this.userId,
    required this.creationDate,
    required this.data,
    this.username,
  });

  String get svgCode {
    final svgBuffer = StringBuffer(
        '<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200">');
    for (int y = 0; y < data.length; y++) {
      for (int x = 0; x < data[y].length; x++) {
        final pixel = data[y][x];
        svgBuffer.write('<rect x="${x * 6}" y="${y * 6}" width="6" height="6" '
            'fill="rgb(${pixel['r']}, ${pixel['g']}, ${pixel['b']})"/>');
      }
    }
    svgBuffer.write('</svg>');
    return svgBuffer.toString();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PixCellZService _service = PixCellZService();
  final AuthService _authService = AuthService();

  List<UserDrawing> _allDrawings = [];
  List<UserDrawing> _filteredDrawings = [];

  bool isLoading = true;
  String errorMessage = "";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllDrawings();
  }

  Future<void> _fetchAllDrawings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = "";
      });

      final token = await SharedPreferencesManager.getSessionToken();
      if (token == null || token.isEmpty) {
        throw "Token utilisateur non disponible";
      }

      final responseList = await _service.fetchAllPixCellZ(token);

      final converted = responseList.map<UserDrawing>((drawing) {
        return UserDrawing(
          id: drawing['_id'],
          userId: drawing['userId'],
          creationDate: drawing['creationDate'],
          data: List<List<Map<String, dynamic>>>.from(drawing['data'].map(
              (row) => List<Map<String, dynamic>>.from(
                  row.map((pixel) => Map<String, dynamic>.from(pixel))))),
        );
      }).toList();

      for (final d in converted) {
        try {
          final username = await _authService.fetchUsername(token, d.userId);
          d.username = username;
        } catch (err) {
          debugPrint(
              "Impossible de récupérer username pour userId='${d.userId}': $err");
        }
      }

      setState(() {
        _allDrawings = converted;
        _filteredDrawings = converted;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterDrawings(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredDrawings = _allDrawings;
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = _allDrawings.where((drawing) {
      final nameToCheck = drawing.username ?? drawing.userId;
      return nameToCheck.toLowerCase().contains(lowerQuery);
    }).toList();

    setState(() {
      _filteredDrawings = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PixCellZAppBar(title: "PixCellZ"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/pixcellz_creation');
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildSearchBar(),
            const SizedBox(height: 8),
            Text(
              "Galerie de Pixel Art",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                      ? Center(child: Text(errorMessage))
                      : _buildGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Rechercher un username",
                hintText: "Tapez par ex. 'johnDoe'",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => _filterDrawings(value),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _filterDrawings(_searchController.text),
            child: const Text("Rechercher"),
          )
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredDrawings.length,
      itemBuilder: (context, index) {
        final drawing = _filteredDrawings[index];
        return _buildPixelArtCard(drawing);
      },
    );
  }

  Widget _buildPixelArtCard(UserDrawing drawing) {
    final formattedDate = DateFormat('dd MMMM yyyy', 'fr_FR')
        .format(DateTime.fromMillisecondsSinceEpoch(drawing.creationDate));

    return InkWell(
      onTap: () async {
        if (drawing.userId == (await SharedPreferencesManager.getUser())) {
          Navigator.pushNamed(
            context,
            '/pixcellz_modification',
            arguments: drawing,
          );
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PixCellZPage(drawing: drawing)));
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: SvgPicture.string(
                  drawing.svgCode,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Créé le $formattedDate",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Par ${drawing.username ?? drawing.userId}",
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
