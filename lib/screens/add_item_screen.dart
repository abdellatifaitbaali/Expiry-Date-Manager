import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../utils/constants.dart';
import 'scanner_screen.dart';

class AddItemScreen extends StatefulWidget {
  final Item? editItem;
  const AddItemScreen({super.key, this.editItem});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = 'food';
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  int _quantity = 1;
  String? _barcode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      _isEditing = true;
      _nameController.text = widget.editItem!.name;
      _notesController.text = widget.editItem!.notes ?? '';
      _category = widget.editItem!.category;
      _expiryDate = widget.editItem!.expiryDate;
      _quantity = widget.editItem!.quantity;
      _barcode = widget.editItem!.barcode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Item' : 'Add Item',
          style: const TextStyle(
            color: AppConstants.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scan barcode button
              _buildScanButton(),
              const SizedBox(height: 20),

              // Item name
              _buildLabel('Item Name'),
              const SizedBox(height: 8),
              _buildNameField(),
              const SizedBox(height: 20),

              // Category
              _buildLabel('Category'),
              const SizedBox(height: 8),
              _buildCategorySelector(),
              const SizedBox(height: 20),

              // Expiry date
              _buildLabel('Expiry Date'),
              const SizedBox(height: 8),
              _buildDatePicker(),
              const SizedBox(height: 20),

              // Quantity
              _buildLabel('Quantity'),
              const SizedBox(height: 8),
              _buildQuantityStepper(),
              const SizedBox(height: 20),

              // Notes
              _buildLabel('Notes (optional)'),
              const SizedBox(height: 8),
              _buildNotesField(),
              const SizedBox(height: 32),

              // Save button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppConstants.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: _scanBarcode,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppConstants.primaryColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              color: AppConstants.secondaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              _barcode != null ? 'Barcode: $_barcode' : 'Scan Barcode',
              style: TextStyle(
                color: _barcode != null
                    ? AppConstants.textPrimary
                    : AppConstants.secondaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: AppConstants.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'e.g. Yogurt, Aspirin, Sunscreen...',
        hintStyle:
            TextStyle(color: AppConstants.textSecondary.withValues(alpha: 0.4)),
        filled: true,
        fillColor: AppConstants.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.secondaryColor, width: 1.5),
        ),
        prefixIcon:
            const Icon(Icons.edit_rounded, color: AppConstants.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an item name';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['food', 'medicine', 'cosmetics', 'other'];
    return Row(
      children: categories.map((cat) {
        final isSelected = _category == cat;
        final icon = AppConstants.categoryIcons[cat]!;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _category = cat),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.primaryColor.withValues(alpha: 0.2)
                    : AppConstants.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppConstants.secondaryColor
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? AppConstants.secondaryColor
                        : AppConstants.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat[0].toUpperCase() + cat.substring(1),
                    style: TextStyle(
                      color: isSelected
                          ? AppConstants.secondaryColor
                          : AppConstants.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                color: AppConstants.textSecondary),
            const SizedBox(width: 12),
            Text(
              '${_expiryDate.day}/${_expiryDate.month}/${_expiryDate.year}',
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppConstants.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.numbers_rounded, color: AppConstants.textSecondary),
          const SizedBox(width: 12),
          const Text(
            'Quantity',
            style: TextStyle(color: AppConstants.textSecondary, fontSize: 15),
          ),
          const Spacer(),
          IconButton(
            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: AppConstants.textSecondary,
            disabledColor: AppConstants.textSecondary.withValues(alpha: 0.3),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_quantity',
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppConstants.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      style: const TextStyle(color: AppConstants.textPrimary),
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Any additional notes...',
        hintStyle:
            TextStyle(color: AppConstants.textSecondary.withValues(alpha: 0.4)),
        filled: true,
        fillColor: AppConstants.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppConstants.secondaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _saveItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: AppConstants.primaryColor.withValues(alpha: 0.4),
        ),
        child: Text(
          _isEditing ? 'Update Item' : 'Save Item',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppConstants.secondaryColor,
              onPrimary: Colors.white,
              surface: AppConstants.cardColor,
              onSurface: AppConstants.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
    if (result != null) {
      setState(() {
        _barcode = result;
      });
      // Auto-fill name if possible (placeholder for Open Food Facts API)
      if (_nameController.text.isEmpty) {
        _nameController.text = 'Scanned Item ($result)';
      }
    }
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ItemProvider>();

    if (_isEditing) {
      final updated = widget.editItem!;
      updated.name = _nameController.text.trim();
      updated.category = _category;
      updated.expiryDate = _expiryDate;
      updated.quantity = _quantity;
      updated.notes = _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null;
      updated.barcode = _barcode;
      provider.updateItem(updated);
    } else {
      provider.addItem(
        name: _nameController.text.trim(),
        category: _category,
        expiryDate: _expiryDate,
        barcode: _barcode,
        quantity: _quantity,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );
    }

    Navigator.pop(context, true);
  }
}
