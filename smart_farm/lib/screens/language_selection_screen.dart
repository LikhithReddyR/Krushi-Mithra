import 'package:flutter/material.dart';
import 'package:smart_farm/main.dart';
import 'package:smart_farm/services/translation_service.dart';
import 'package:smart_farm/theme/app_theme.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool isStandalone;
  const LanguageSelectionScreen({super.key, this.isStandalone = false});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<String> _languages = ['English', 'हिंदी', 'ಕನ್ನಡ'];

  void _onLanguageSelected(String lang) {
    TranslationService.currentLanguage.value = lang;
  }

  void _continue() {
    if (widget.isStandalone) {
      Navigator.pop(context);
    } else {
      // Go to MainScreen after onboarding/login is complete
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    }
  }

  // ...existing code...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA), // Match login theme
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Image.asset('assets/images/logo.png', width: 80, height: 80),
              const SizedBox(height: 24),
              ValueListenableBuilder<String>(
                valueListenable: TranslationService.currentLanguage,
                builder: (context, currentLang, _) {
                  String title = 'Choose Your Language';
                  String subtitle = 'Select a language to use throughout the app.';
                  String btnText = 'Continue';

                  if (currentLang == 'हिंदी') {
                    title = 'अपनी भाषा चुनें';
                    subtitle = 'ऐप में उपयोग करने के लिए एक भाषा चुनें।';
                    btnText = 'जारी रखें';
                  } else if (currentLang == 'ಕನ್ನಡ') {
                    title = 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';
                    subtitle = 'ಅಪ್ಲಿಕೇಶನ್‌ನಾದ್ಯಂತ ಬಳಸಲು ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ.';
                    btnText = 'ಮುಂದುವರಿಸಿ';
                  }

                  return Column(
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D3D3D),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              Expanded(
                child: ListView.separated(
                  itemCount: _languages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    return ValueListenableBuilder<String>(
                      valueListenable: TranslationService.currentLanguage,
                      builder: (context, currentLang, _) {
                        final isSelected = currentLang == lang;
                        return GestureDetector(
                          onTap: () => _onLanguageSelected(lang),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lang,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Colors.white, size: 24)
                                else
                                  const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ValueListenableBuilder<String>(
                valueListenable: TranslationService.currentLanguage,
                builder: (context, currentLang, _) {
                  String btnText = 'Continue';
                  if (currentLang == 'हिंदी') btnText = 'जारी रखें';
                  if (currentLang == 'ಕನ್ನಡ') btnText = 'ಮುಂದುವರಿಸಿ';

                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        btnText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
