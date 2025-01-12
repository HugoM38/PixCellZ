import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pixcellz/services/pixcellz_service.dart';
import 'package:pixcellz/ui/widgets/pixcellz_appbar.dart';
import 'package:pixcellz/utils/shared_prefs_manager.dart';
import 'package:provider/provider.dart';
import 'package:pixcellz/ui/pixcellz_modification/pixel_art_viewmodel_modification.dart';
import 'package:pixcellz/ui/widgets/pixel_grid_modifier.dart';

class PixCellZModificationPage extends StatefulWidget {
  final List<List<Map<String, dynamic>>> pixelData;
  final String pixCellZId;

  const PixCellZModificationPage({
    Key? key,
    required this.pixelData,
    required this.pixCellZId,
  }) : super(key: key);

  @override
  State<PixCellZModificationPage> createState() =>
      _PixCellZModificationPageState();
}

class _PixCellZModificationPageState extends State<PixCellZModificationPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PixelArtViewModelModification.fromData(widget.pixelData),
      child: Scaffold(
        appBar: PixCellZAppBar(
          title: "Modifier le Pixel Art",
          actions: [
            Consumer<PixelArtViewModelModification>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () async {
                    String? token =
                        await SharedPreferencesManager.getSessionToken();
                    Map<String, dynamic> jsonData =
                        viewModel.getPixelArtJsonString();

                    PixCellZService()
                        .updatePixCellZ(widget.pixCellZId, token!, jsonData)
                        .then((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pixel Art modifié avec succès'),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }).catchError((error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de la modification'),
                          ),
                        );
                      }
                    });
                  },
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Expanded(
                child: Center(
                  child: PixelGridModifier(),
                ),
              ),
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: Colors.black87,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Appui Court: sélectionner | Appui Long: modifier/supprimer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: _buildColorPalette(),
              ),
              SizedBox(
                height: 50,
                child: _buildColorPickerButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    return Consumer<PixelArtViewModelModification>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: viewModel.palette.length,
                  itemBuilder: (context, index) {
                    final color = viewModel.palette[index];
                    final isSelected = viewModel.selectedColor == color;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => viewModel.setSelectedColor(color),
                        onLongPress: () =>
                            _showColorEditor(context, viewModel, index, color),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () => _showAddColorDialog(context, viewModel),
                  tooltip: 'Ajouter une couleur',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorEditor(
    BuildContext context,
    PixelArtViewModelModification viewModel,
    int index,
    Color initialColor,
  ) {
    Color selectedColor = initialColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la couleur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorPicker(
                pickerColor: initialColor,
                onColorChanged: (color) => selectedColor = color,
                pickerAreaHeightPercent: 0.8,
                enableAlpha: false,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      viewModel.removeColor(index);
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Supprimer'),
                  ),
                  TextButton(
                    onPressed: () {
                      viewModel.updateColor(index, selectedColor);
                     
                      if (viewModel.selectedColor == initialColor) {
                        viewModel.setSelectedColor(selectedColor);
                      }
                      Navigator.of(context).pop();
                    },
                    child: const Text('Modifier'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddColorDialog(
      BuildContext context, PixelArtViewModelModification viewModel) {
    Color selectedColor = Colors.red;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une couleur'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) => selectedColor = color,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              viewModel.addColor(selectedColor);
              Navigator.of(context).pop();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPickerButton() {
    return Consumer<PixelArtViewModelModification>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () => _showColorPicker(context, viewModel),
              child: const Text(
                'Couleur personnalisée',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showColorPicker(BuildContext context, PixelArtViewModelModification viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: viewModel.selectedColor,
            onColorChanged: (color) => viewModel.setSelectedColor(color),
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
