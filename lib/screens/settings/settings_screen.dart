import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Store Settings
  String _storeName = 'GroceryFlow Store';
  String _storeDescription = 'Your neighborhood grocery store';
  String _storePhone = '+998901234567';
  String _storeEmail = 'info@groceryflow.com';
  String _storeAddress = 'Asaka, Uzbekistan';
  
  // Delivery Settings
  double _deliveryFee = 5000.0;
  double _minimumOrderAmount = 10000.0;
  int _deliveryRadius = 10; // km
  int _estimatedDeliveryTime = 30; // minutes
  
  // Notification Settings
  bool _orderNotifications = true;
  bool _marketingNotifications = true;
  bool _systemNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  
  // Security Settings
  bool _twoFactorAuth = false;
  bool _loginAlerts = true;
  int _sessionTimeout = 30; // minutes
  
  // Currency Settings
  String _currency = 'сум';
  String _currencySymbol = 'сум';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Settings',
              style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your store settings and preferences',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Store Information Section
            SettingsSection(
              title: 'Store Information',
              icon: Icons.store,
              children: [
                SettingsTile(
                  title: 'Store Name',
                  subtitle: _storeName,
                  icon: Icons.business,
                  onTap: () => _showEditDialog('Store Name', _storeName, (value) {
                    setState(() => _storeName = value);
                  }),
                ),
                SettingsTile(
                  title: 'Store Description',
                  subtitle: _storeDescription,
                  icon: Icons.description,
                  onTap: () => _showEditDialog('Store Description', _storeDescription, (value) {
                    setState(() => _storeDescription = value);
                  }),
                ),
                SettingsTile(
                  title: 'Store Phone',
                  subtitle: _storePhone,
                  icon: Icons.phone,
                  onTap: () => _showEditDialog('Store Phone', _storePhone, (value) {
                    setState(() => _storePhone = value);
                  }),
                ),
                SettingsTile(
                  title: 'Store Email',
                  subtitle: _storeEmail,
                  icon: Icons.email,
                  onTap: () => _showEditDialog('Store Email', _storeEmail, (value) {
                    setState(() => _storeEmail = value);
                  }),
                ),
                SettingsTile(
                  title: 'Store Address',
                  subtitle: _storeAddress,
                  icon: Icons.location_on,
                  onTap: () => _showEditDialog('Store Address', _storeAddress, (value) {
                    setState(() => _storeAddress = value);
                  }),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Delivery Settings Section
            SettingsSection(
              title: 'Delivery Settings',
              icon: Icons.delivery_dining,
              children: [
                SettingsTile(
                  title: 'Delivery Fee',
                  subtitle: '${_deliveryFee.toStringAsFixed(0)} $_currencySymbol',
                  icon: Icons.money,
                  onTap: () => _showNumberEditDialog('Delivery Fee', _deliveryFee, (value) {
                    setState(() => _deliveryFee = value);
                  }),
                ),
                SettingsTile(
                  title: 'Minimum Order Amount',
                  subtitle: '${_minimumOrderAmount.toStringAsFixed(0)} $_currencySymbol',
                  icon: Icons.shopping_cart,
                  onTap: () => _showNumberEditDialog('Minimum Order Amount', _minimumOrderAmount, (value) {
                    setState(() => _minimumOrderAmount = value);
                  }),
                ),
                SettingsTile(
                  title: 'Delivery Radius',
                  subtitle: '$_deliveryRadius km',
                  icon: Icons.location_searching,
                  onTap: () => _showNumberEditDialog('Delivery Radius (km)', _deliveryRadius.toDouble(), (value) {
                    setState(() => _deliveryRadius = value.toInt());
                  }),
                ),
                SettingsTile(
                  title: 'Estimated Delivery Time',
                  subtitle: '$_estimatedDeliveryTime minutes',
                  icon: Icons.timer,
                  onTap: () => _showNumberEditDialog('Estimated Delivery Time (minutes)', _estimatedDeliveryTime.toDouble(), (value) {
                    setState(() => _estimatedDeliveryTime = value.toInt());
                  }),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notification Settings Section
            SettingsSection(
              title: 'Notifications',
              icon: Icons.notifications,
              children: [
                SettingsTile(
                  title: 'Order Notifications',
                  subtitle: 'Get notified about new orders',
                  icon: Icons.shopping_bag,
                  trailing: Switch(
                    value: _orderNotifications,
                    onChanged: (value) {
                      setState(() => _orderNotifications = value);
                    },
                  ),
                ),
                SettingsTile(
                  title: 'Marketing Notifications',
                  subtitle: 'Receive promotional updates',
                  icon: Icons.campaign,
                  trailing: Switch(
                    value: _marketingNotifications,
                    onChanged: (value) {
                      setState(() => _marketingNotifications = value);
                    },
                  ),
                ),
                SettingsTile(
                  title: 'System Notifications',
                  subtitle: 'Important system updates',
                  icon: Icons.system_update,
                  trailing: Switch(
                    value: _systemNotifications,
                    onChanged: (value) {
                      setState(() => _systemNotifications = value);
                    },
                  ),
                ),
                SettingsTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive notifications via email',
                  icon: Icons.email,
                  trailing: Switch(
                    value: _emailNotifications,
                    onChanged: (value) {
                      setState(() => _emailNotifications = value);
                    },
                  ),
                ),
                SettingsTile(
                  title: 'SMS Notifications',
                  subtitle: 'Receive notifications via SMS',
                  icon: Icons.sms,
                  trailing: Switch(
                    value: _smsNotifications,
                    onChanged: (value) {
                      setState(() => _smsNotifications = value);
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Security Settings Section
            SettingsSection(
              title: 'Security',
              icon: Icons.security,
              children: [
                SettingsTile(
                  title: 'Two-Factor Authentication',
                  subtitle: 'Add an extra layer of security',
                  icon: Icons.verified_user,
                  trailing: Switch(
                    value: _twoFactorAuth,
                    onChanged: (value) {
                      setState(() => _twoFactorAuth = value);
                    },
                  ),
                ),
                SettingsTile(
                  title: 'Login Alerts',
                  subtitle: 'Get notified of new login attempts',
                  icon: Icons.login,
                  trailing: Switch(
                    value: _loginAlerts,
                    onChanged: (value) {
                      setState(() => _loginAlerts = value);
                    },
                  ),
                ),
                SettingsTile(
                  title: 'Session Timeout',
                  subtitle: '$_sessionTimeout minutes of inactivity',
                  icon: Icons.timer_off,
                  onTap: () => _showNumberEditDialog('Session Timeout (minutes)', _sessionTimeout.toDouble(), (value) {
                    setState(() => _sessionTimeout = value.toInt());
                  }),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Currency Settings Section
            SettingsSection(
              title: 'Currency & Localization',
              icon: Icons.attach_money,
              children: [
                SettingsTile(
                  title: 'Currency',
                  subtitle: _currency,
                  icon: Icons.currency_exchange,
                  onTap: () => _showCurrencyDialog(),
                ),
                SettingsTile(
                  title: 'Currency Symbol',
                  subtitle: _currencySymbol,
                  icon: Icons.attach_money,
                  onTap: () => _showEditDialog('Currency Symbol', _currencySymbol, (value) {
                    setState(() => _currencySymbol = value);
                  }),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Settings',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNumberEditDialog(String title, double currentValue, Function(double) onSave) {
    final controller = TextEditingController(text: currentValue.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: title,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text) ?? currentValue;
              onSave(value);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog() {
    final currencies = ['сум', 'USD', 'EUR', 'RUB'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return ListTile(
              title: Text(currency),
              leading: Radio<String>(
                value: currency,
                groupValue: _currency,
                onChanged: (value) {
                  setState(() {
                    _currency = value!;
                    _currencySymbol = currency;
                  });
                  Navigator.of(context).pop();
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Here you would typically save the settings to a backend service
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
