import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'custom_drawer.dart';
import 'theme_manager.dart';

class DrawerTestScreen extends StatefulWidget {
  const DrawerTestScreen({super.key});

  @override
  State<DrawerTestScreen> createState() => _DrawerTestScreenState();
}

class _DrawerTestScreenState extends State<DrawerTestScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      // The drawer we just refactored with Glassmorphism
      drawer: const CustomDrawer(),
      
      // Professional AppBar matching your 'Sirat al Mustaqeem' theme
      appBar: AppBar(
        title: Text(
          'UI Testing Lab', 
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF059669), // Emerald Green
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Subtle gradient to make the test screen look "pro"
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF059669).withOpacity(0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Symbolic icon for your AI Islamic App
            const Icon(
              Icons.auto_awesome, 
              size: 80, 
              color: Color(0xFF059669),
            ),
            const SizedBox(height: 24),
            Text(
              'Drawer & Theme Test',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineSmall?.color,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Verify the Glassmorphic Drawer and Dark Mode transitions here.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            
            // Re-styled Button for Opening Drawer
            _buildTestButton(
              label: 'View Refactored Drawer',
              icon: Icons.menu_open,
              color: const Color(0xFF059669),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            
            const SizedBox(height: 16),
            
            // Re-styled Button for Theme Toggle
            _buildTestButton(
              label: 'Toggle Visual Theme',
              icon: Icons.color_lens_outlined,
              color: const Color(0xFF0F766E),
              onPressed: () => ThemeManager().toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to keep code clean and buttons consistent
  Widget _buildTestButton({
    required String label, 
    required IconData icon, 
    required Color color, 
    required VoidCallback onPressed
  }) {
    return SizedBox(
      width: 280,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
      ),
    );
  }
}