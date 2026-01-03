import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/wallet_provider.dart';
import '../theme/app_theme.dart';
import 'wallet_connect_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: AppTheme.deepBackground,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          // Wallet Manager Section
          _buildWalletSection(context),
          SizedBox(height: 24),
          
          Text(
            'Appearance',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceGlass,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                  _buildModernThemeOption(
                    context,
                    'Dark Mode',
                    Icons.dark_mode_rounded,
                    ThemeMode.dark,
                    themeProvider,
                  ),
                  Divider(height: 1, color: Colors.white10),
                   _buildModernThemeOption(
                    context,
                    'Light Mode',
                    Icons.light_mode_rounded,
                    ThemeMode.light,
                    themeProvider,
                  ),
                  Divider(height: 1, color: Colors.white10),
                  _buildModernThemeOption(
                    context,
                    'System Default',
                    Icons.brightness_auto_rounded,
                    ThemeMode.system,
                    themeProvider,
                  ),
              ],
            ),
          ),
          
          SizedBox(height: 32),
          
          // App Info Section
          Text(
            'About',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceGlass,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                 _buildInfoTile('App Version', '1.0.0', Icons.info_outline),
                 Divider(height: 1, color: Colors.white10),
                 _buildInfoTile('Claim Range', '20 meters', Icons.radar),
                 Divider(height: 1, color: Colors.white10),
                 _buildInfoTile('Total Locations', '15 locations', Icons.map),
              ],
            ),
          ),
          SizedBox(height: 40),
          Center(
             child: Text('Made with ❤️ in India', style: TextStyle(color: Colors.white38)),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWalletSection(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple.withOpacity(0.2), AppTheme.surfaceGlass],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               Icon(Icons.account_balance_wallet, color: Colors.white),
               SizedBox(width: 12),
               Text('Wallet Status', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
             ],
           ),
           SizedBox(height: 16),
           if (walletProvider.isConnected) ...[
             Container(
               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               decoration: BoxDecoration(
                 color: Colors.green.withOpacity(0.2),
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.green.withOpacity(0.3)),
               ),
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                    SizedBox(width: 8),
                   Text('Connected', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                 ],
               ),
             ),
             SizedBox(height: 12),
             Text(
                walletProvider.displayAddress,
                style: TextStyle(color: Colors.white70, fontFamily: 'monospace'),
             ),
             SizedBox(height: 20),
             SizedBox(
               width: double.infinity,
               child: OutlinedButton(
                 onPressed: () async {
                    // Logic to disconnect
                     await walletProvider.disconnectWallet();
                 },
                 style: OutlinedButton.styleFrom(
                   foregroundColor: Colors.redAccent,
                   side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                 ),
                 child: Text('Disconnect Wallet'),
               ),
             ),
           ] else ...[
             Text(
               'Connect your wallet to start collecting NFTs.',
               style: TextStyle(color: Colors.white70),
             ),
             SizedBox(height: 20),
             SizedBox(
               width: double.infinity,
               child: ElevatedButton(
                 onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletConnectScreen(),
                      ),
                    );
                 },
                 style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
                 child: Text('Connect Wallet'),
               ),
             ),
           ],
        ],
      ),
    );
  }

  Widget _buildModernThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    ThemeMode mode,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return InkWell(
      onTap: () => themeProvider.setThemeMode(mode),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryPurple : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: AppTheme.accentCyan),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
