import 'package:flutter/material.dart';

class TranslationService {
  static final ValueNotifier<String> currentLanguage = ValueNotifier<String>('English');

  static const Map<String, Map<String, String>> _translations = {
    'English': {
      // Nav & Common
      'home': 'Home', 'weather': 'Weather', 'scan': 'Scan', 'shop': 'Shop', 'profile': 'Profile',
      'language_changed': 'Language changed to', 'search': 'Search app features...', 'loading': 'Loading...',
      'error': 'Error', 'no_results': 'No results found', 'retry': 'Retry', 'cancel': 'Cancel',
      'market_prices': 'Market Prices',
      'marketplace': 'Market Place',
      'markets': 'Markets',
      'seeds': 'Seeds',
      'my_crops': 'My Crops',
      'add_crop': 'Add Planted Crop',
      'crop_name': 'Crop Name',
      'acreage': 'Acreage (Acres)',
      'planting_date': 'Planting Date',
      'no_crops_planted': 'You haven’t added any crops yet.',
      'harvested': 'Harvested',
      'growing': 'Growing',
      'save_crop': 'Save Crop',
      'father_name': 'Father\'s Name',
      
      // AI Prompt Instruction
      'ai_language_instruction': 'Please respond in English.',

      // Soil Moisture Predictor
      'soil_moisture_predictor': 'Soil Moisture Predictor', 'check_soil_condition': 'Check your soil condition instantly',
      'enter_data_moisture': 'Enter data and get quick moisture status with recommendations.',
      'input_data': 'Input Data', 'upload_capture_soil': 'Upload / Capture Soil Image',
      'no_image_selected': 'No image selected yet. Use Upload to add a soil sample image.',
      'enter_location': 'Enter location (e.g., Bengaluru)', 'auto_detect': 'Auto-detect',
      'temperature_c': 'Temperature (°C)', 'humidity_pct': 'Humidity (%)', 'rainfall_mm': 'Rainfall (mm)', 'soil_type': 'Soil Type',
      'checking': 'Checking...', 'check_moisture': 'Check Moisture', 'result': 'Result', 'soil_moisture_level': 'Soil Moisture Level',
      'unknown': 'Unknown', 'no_prediction_yet': 'No prediction yet', 'estimated_moisture': 'Estimated Moisture', 'recommendation': 'Recommendation',
      'use_button_advice': 'Use the button above to compute soil moisture and get simple advice.',
      'tip_accurate_results': 'Tip: For more accurate results, enter current field values and use the soil image preview as reference.',
      'ai_insight': 'AI Visual Analysis',

      // Shop
      'shop_title': 'Pesticide', 'tab_fungicide': 'FUNGICIDE', 'tab_insecticides': 'INSECTICIDES', 'tab_herbicide': 'HERBICIDE', 'tab_bio': 'BIO PESTICIDES', 'you_save': 'You save', 'added_to_cart': 'added to cart', 'likes': 'Likes',

      // Home
      'current_weather': 'Current Weather', 'sunny_clear': 'Sunny, Clear Skies', 'no_rain_alert': 'No rain alert for today', 'moisture': 'MOISTURE', 'healthy_level': 'Healthy Level', 'scan_crop': 'Scan Crop', 'ai_analysis_desc': 'AI analysis for health\nand pests', 'sell_crops': 'Sell Crops', 'hire_machinery': 'Hire Machinery', 'check_prices': 'Check Market Prices', 'quick_actions': 'Quick Actions',
      
      // Weather
      'weather_title': 'Weather Forecast', 'current_location': 'CURRENT LOCATION', 'humidity': 'HUMIDITY', 'wind': 'WIND', 'rainfall': 'RAINFALL', 'rainfall_warning': 'Rainfall Warning', 'soil_moisture_label': 'SOIL MOISTURE', 'uv_index': 'UV INDEX', 'air_quality': 'AIR QUALITY', 'next_5_days': 'Next 5 Days', 'see_full_report': 'See full report',
      'wind_speed': 'WIND SPEED', 'feels_like': 'Feels like', 'forecast_not_available': 'Forecast not available', 'smart_farming_suggestions': 'SMART FARMING SUGGESTIONS',
      'safe_spraying': 'Safe for Spraying', 'avoid_spraying': 'Avoid Spraying', 'good_planting': 'Good for Planting', 'delay_planting': 'Delay Planting',
      'low': 'LOW', 'moderate': 'MODERATE', 'high': 'HIGH', 'very_high': 'VERY HIGH', 'calm': 'CALM', 'fresh': 'FRESH', 'strong': 'STRONG', 'optimal': 'OPTIMAL',
      
      // Scanner & History
      'point_at_leaf': 'POINT AT THE LEAF TO SCAN', 'ai_scanner': 'AI Scanner', 'analyzing_leaf': 'Analyzing leaf with AI...', 'click_to_scan': 'Click to Scan', 'import_from_gallery': 'Import from Gallery', 'analysis_result': 'Analysis Result', 'close': 'Close',
      'scan_history': 'Scan History', 'no_scans_yet': 'No scans yet. Start scanning your plants!', 'login_to_see_history': 'Please log in to see history.',

      // Notifications
      'notifications': 'Notifications', 'no_notifications': 'No notifications yet', 'login_to_see_notifications': 'Please log in to view notifications', 'just_now': 'Just now', 'days_ago': 'days ago', 'hours_ago': 'hours ago', 'mins_ago': 'mins ago',

      // Profile
      'total_sales': 'Total Sales', 'major_crops': 'Major Crops', 'save_profile': 'Save Profile', 'edit_profile': 'Edit Profile', 'recent_sales': 'Recent Sales', 'view_all': 'View All', 'completed': 'COMPLETED', 'rental_history': 'Rental History', 'log_out': 'Log Out',
      'select_profile_picture': 'Select Profile Picture', 'full_name': 'Full Name', 'location': 'Location', 'e.g._wheat_rice': 'e.g. Wheat, Rice', 'profile_updated_successfully': 'Profile updated successfully!',
      'change_language': 'Change Language',

      // Shop
      'browse_categories': 'Browse Categories', 'machinery_booking': 'Machinery Booking', 'tools_booking': 'Tools Booking', 'seeds_booking': 'Seeds Booking', 'pesticides_booking': 'Pesticides Booking',

      // Rent / Sell
      'available_now': 'AVAILABLE NOW', 'professional_machinery': 'Professional Grade Machinery', 'all_equipment': 'All Equipment', 'tractors': 'Tractors', 'tillage': 'Tillage', 'per_hour': '/HOUR', 'book_now': 'Book Now', 'call_owner': 'Call Owner', 'booking_coming_soon': 'Booking flow coming soon!',
      'mandi_prices_title': 'Mandi Prices &\nMarketplace', 'mandi_prices_subtitle': 'Find the best rates for your harvest across\nregional markets.', 'nearby': 'Nearby', 'best_price': 'Best Price', 'verified': 'VERIFIED', 'per_quintal': 'PER QUINTAL', 'sell': 'Sell', 'market_analysis': 'Market Analysis', 'more_filters': 'More',
      'search_crops_hint': 'Search crops (e.g., Wheat, Rice)...', 'post_your_crop': 'Post Your Crop', 'market_analysis_desc': 'Wheat prices have increased by 4% in the last 7 days. This might be the best time to list your stock.',
      'post_crop_coming_soon': 'Post crop flow coming soon!', 'sell_flow_coming_soon': 'Sell flow coming soon!', 'call_feature_coming_soon': 'Call feature coming soon!',

      // Booking Specific
      'book': 'Book', 'booking': 'Booking', 'your_details': 'Your Details', 'mobile_number': 'Mobile Number', 'farm_address': 'Farm Address',
      'hours_required': 'Number of Hours Required', 'booking_date': 'Booking Date', 'tap_select_date': 'Tap to select date',
      'submit_booking': 'Submit Booking', 'booking_confirmed': 'Booking Confirmed!', 'machine_booked_success': 'Machinery booked successfully.\nIt will reach your farm soon.',
      'machine': 'Machine', 'name': 'Name', 'date': 'Date', 'sms_sent': 'SMS Sent: "Your machinery booking is confirmed and is on the way."', 'back_to_shop': 'Back to Shop',
      'enter_name': 'Enter your name', 'enter_valid_mobile': 'Enter valid mobile number', 'enter_address': 'Enter your address', 'enter_hours': 'Enter hours needed',

      // Cart, Checkout & Orders
      'my_cart': 'My Cart', 'cart_empty': 'Your cart is empty', 'total': 'Total', 'checkout': 'Checkout',
      'delivery_information': 'Delivery Information', 'email_address': 'Email Address', 'full_delivery_address': 'Full Delivery Address',
      'payment_method': 'Payment Method', 'cash_on_delivery': 'Cash on Delivery', 'credit_debit_card': 'Credit/Debit Card',
      'total_amount': 'Total Amount:', 'place_order': 'Place Order', 'order_successful': 'Order Successful!',
      'order_success_msg': 'Your order has been placed successfully and will be delivered soon.', 'cart_is_empty': 'Your cart is empty.',
      'error_placing_order': 'Error placing order:', 'my_orders': 'My Orders', 'login_to_view_orders': 'Please log in to view your orders.',
    },
    'हिंदी': {
      'home': 'होम', 'weather': 'मौसम', 'scan': 'स्कैन', 'shop': 'दुकान', 'profile': 'प्रोफ़ाइल',
      'language_changed': 'भाषा बदल कर हो गई है', 'search': 'ऐप सुविधाएं खोजें...', 'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि', 'no_results': 'कोई परिणाम नहीं मिला', 'retry': 'पुनः प्रयास करें', 'cancel': 'रद्द करें',
      'seeds': 'बीज',

      'ai_language_instruction': 'कृपया हिंदी में उत्तर दें।',

      'soil_moisture_predictor': 'मिट्टी की नमी भविष्यवक्ता', 'check_soil_condition': 'अपनी मिट्टी की स्थिति तुरंत जांचें',
      'enter_data_moisture': 'डेटा दर्ज करें और सुझावों के साथ त्वरित नमी स्थिति प्राप्त करें।',
      'input_data': 'इनपुट डेटा', 'upload_capture_soil': 'मिट्टी की छवि अपलोड/कैप्चर करें',
      'no_image_selected': 'अभी तक कोई छवि नहीं चुनी गई है। अपलोड का उपयोग करें।',
      'enter_location': 'स्थान दर्ज करें (उदा. बेंगलुरु)', 'auto_detect': 'स्वतः-पता लगाएं',
      'temperature_c': 'तापमान (°C)', 'humidity_pct': 'नमी (%)', 'rainfall_mm': 'वर्षा (मिमी)', 'soil_type': 'मिट्टी का प्रकार',
      'checking': 'जांच कर रहा है...', 'check_moisture': 'नमी जांचें', 'result': 'परिणाम', 'soil_moisture_level': 'मिट्टी की नमी का स्तर',
      'unknown': 'अज्ञात', 'no_prediction_yet': 'अभी कोई भविष्यवाणी नहीं', 'estimated_moisture': 'अनुमानित नमी', 'recommendation': 'सिफारिश',
      'use_button_advice': 'मिट्टी की नमी की गणना और सरल सलाह के लिए ऊपर दिए गए बटन का उपयोग करें।',
      'tip_accurate_results': 'सुझाव: अधिक सटीक परिणामों के लिए, वर्तमान फ़ील्ड मान दर्ज करें।',
      'ai_insight': 'एआई दृश्य विश्लेषण',

      'shop_title': 'कीटनाशक', 'tab_fungicide': 'कवकनाशी', 'tab_insecticides': 'कीटनाशकों', 'tab_herbicide': 'शाकनाशी', 'tab_bio': 'जैव कीटनाशक', 'you_save': 'आपकी बचत', 'added_to_cart': 'कार्ट में जोड़ा गया', 'likes': 'पसंद',
      
      'current_weather': 'वर्तमान मौसम', 'sunny_clear': 'साफ और धूप', 'no_rain_alert': 'आज बारिश की कोई चेतावनी नहीं', 'moisture': 'नमी', 'healthy_level': 'स्वस्थ स्तर', 'scan_crop': 'फसल स्कैन करें', 'ai_analysis_desc': 'स्वास्थ्य और कीटों का एआई विश्लेषण', 'sell_crops': 'फसलें बेचें', 'hire_machinery': 'मशीनरी किराए पर लें', 'check_prices': 'बाजार भाव जांचें', 'quick_actions': 'त्वरित कार्रवाई',
      
      'weather_title': 'मौसम पूर्वानुमान', 'current_location': 'वर्तमान स्थान', 'humidity': 'नमी', 'wind': 'हवा', 'rainfall': 'वर्षा', 'rainfall_warning': 'वर्षा की चेतावनी', 'soil_moisture_label': 'मिट्टी की नमी', 'uv_index': 'यूवी सूचकांक', 'air_quality': 'वायु गुणवत्ता', 'next_5_days': 'अगले 5 दिन', 'see_full_report': 'पूरी रिपोर्ट देखें',
      'wind_speed': 'हवा की गति', 'feels_like': 'महसूस होता है', 'forecast_not_available': 'पूर्वानुमान उपलब्ध नहीं है', 'smart_farming_suggestions': 'स्मार्ट खेती सुझाव',
      'safe_spraying': 'छिड़काव के लिए सुरक्षित', 'avoid_spraying': 'छिड़काव से बचें', 'good_planting': 'बुवाई के लिए अच्छा', 'delay_planting': 'बुवाई में देरी करें',
      'low': 'कम', 'moderate': 'मध्यम', 'high': 'उच्च', 'very_high': 'बहुत उच्च', 'calm': 'शांत', 'fresh': 'ताज़ा', 'strong': 'तेज़', 'optimal': 'इष्टतम',
      
      'point_at_leaf': 'स्कैन करने के लिए पत्ती की ओर इशारा करें', 'ai_scanner': 'एआई स्कैनर', 'analyzing_leaf': 'एआई पत्ती का विश्लेषण कर रहा है...', 'click_to_scan': 'स्कैन करने के लिए क्लिक करें', 'import_from_gallery': 'गैलरी से आयात करें', 'analysis_result': 'विश्लेषण परिणाम', 'close': 'बंद करें',
      'scan_history': 'स्कैन इतिहास', 'no_scans_yet': 'अभी कोई स्कैन नहीं है। अपने पौधों को स्कैन करना शुरू करें!', 'login_to_see_history': 'इतिहास देखने के लिए कृपया लॉग इन करें।',

      'notifications': 'सूचनाएं', 'no_notifications': 'अभी कोई सूचना नहीं है', 'login_to_see_notifications': 'सूचनाएं देखने के लिए कृपया लॉग इन करें', 'just_now': 'अभी-अभी', 'days_ago': 'दिन पहले', 'hours_ago': 'घंटे पहले', 'mins_ago': 'मिनट पहले',

      'total_sales': 'कुल बिक्री', 'major_crops': 'प्रमुख फसलें', 'save_profile': 'प्रोफ़ाइल सहेजें', 'edit_profile': 'प्रोफ़ाइल संपादित करें', 'recent_sales': 'हाल की बिक्री', 'view_all': 'सभी देखें', 'completed': 'पूर्ण', 'rental_history': 'किराये का इतिहास', 'log_out': 'लॉग आउट',
      'select_profile_picture': 'प्रोफ़ाइल चित्र चुनें', 'full_name': 'पूरा नाम', 'location': 'स्थान', 'e.g._wheat_rice': 'उदा. गेहूं, चावल', 'profile_updated_successfully': 'प्रोफ़ाइल सफलतापूर्वक अद्यतन की गई!',
      'change_language': 'भाषा बदलें',

      'browse_categories': 'श्रेणियाँ ब्राउज़ करें', 'machinery_booking': 'मशीनरी बुकिंग', 'tools_booking': 'उपकरण बुकिंग', 'seeds_booking': 'बीज बुकिंग', 'pesticides_booking': 'कीटनाशक बुकिंग',

      'available_now': 'अब उपलब्ध', 'professional_machinery': 'पेशेवर मशीनरी', 'all_equipment': 'सभी उपकरण', 'tractors': 'ट्रैक्टर', 'tillage': 'जुताई', 'per_hour': '/घंटा', 'book_now': 'अभी बुक करें', 'call_owner': 'मालिक को कॉल करें', 'booking_coming_soon': 'बुकिंग प्रवाह जल्द ही आ रहा है!',
      'mandi_prices_title': 'मंडी भाव और बाज़ार', 'mandi_prices_subtitle': 'क्षेत्रीय बाजारों में अपनी फसल के लिए सर्वोत्तम दरें खोजें।', 'nearby': 'आस-पास', 'best_price': 'सर्वोत्तम मूल्य', 'verified': 'सत्यापित', 'per_quintal': 'प्रति क्विंटल', 'sell': 'बेचें', 'market_analysis': 'बाज़ार विश्लेषण', 'more_filters': 'अधिक',
      'search_crops_hint': 'फसलें खोजें (उदा., गेहूं, चावल)...', 'post_your_crop': 'अपनी फसल पोस्ट करें', 'market_analysis_desc': 'गेहूं की कीमतों में पिछले 7 दिनों में 4% की वृद्धि हुई है। अपना स्टॉक सूचीबद्ध करने का यह सबसे अच्छा समय हो सकता है।',
      'post_crop_coming_soon': 'फसल पोस्ट करने का विकल्प जल्द ही आ रहा है!', 'sell_flow_coming_soon': 'बिक्री प्रक्रिया जल्द ही आ रही है!', 'call_feature_coming_soon': 'कॉल सुविधा जल्द ही आ रही है!',

      'book': 'बुक करें', 'booking': 'बुकिंग', 'your_details': 'आपका विवरण', 'mobile_number': 'मोबाइल नंबर', 'farm_address': 'खेत का पता',
      'hours_required': 'आवश्यक घंटों की संख्या', 'booking_date': 'बुकिंग की तिथि', 'tap_select_date': 'तिथि चुनने के लिए टैप करें',
      'submit_booking': 'बुकिंग जमा करें', 'booking_confirmed': 'बुकिंग की पुष्टि!', 'machine_booked_success': 'मशीनरी सफलतापूर्वक बुक की गई।\nयह जल्द ही आपके खेत तक पहुंच जाएगी।',
      'machine': 'मशीन', 'name': 'नाम', 'date': 'तारीख', 'sms_sent': 'एसएमएस भेजा गया: "आपकी मशीनरी बुकिंग की पुष्टि हो गई है।"', 'back_to_shop': 'वापस दुकान पर जाएं',
      'enter_name': 'अपना नाम दर्ज करें', 'enter_valid_mobile': 'वैध मोबाइल नंबर दर्ज करें', 'enter_address': 'अपना पता दर्ज करें', 'enter_hours': 'आवश्यक घंटे दर्ज करें',

      'my_cart': 'मेरा कार्ट', 'cart_empty': 'आपका कार्ट खाली है', 'total': 'कुल', 'checkout': 'चेकआउट',
      'delivery_information': 'वितरण जानकारी', 'email_address': 'ईमेल पता', 'full_delivery_address': 'पूरा वितरण पता',
      'payment_method': 'भुगतान विधि', 'cash_on_delivery': 'कैश ऑन डिलीवरी', 'credit_debit_card': 'क्रेडिट/डेबिट कार्ड',
      'total_amount': 'कुल राशि:', 'place_order': 'ऑर्डर दें', 'order_successful': 'ऑर्डर सफल!',
      'order_success_msg': 'आपका ऑर्डर सफलतापूर्वक दे दिया गया है और जल्द ही वितरित किया जाएगा।', 'cart_is_empty': 'आपका कार्ट खाली है।',
      'error_placing_order': 'ऑर्डर देने में त्रुटि:', 'my_orders': 'मेरे ऑर्डर', 'login_to_view_orders': 'अपने ऑर्डर देखने के लिए कृपया लॉग इन करें।',
      'my_crops': 'मेरी फसलें',
      'add_crop': 'लगाई गई फसल जोड़ें',
      'crop_name': 'फसल का नाम',
      'acreage': 'रकबा (एकड़)',
      'planting_date': 'बुवाई की तारीख',
      'no_crops_planted': 'आपने अभी तक कोई फसल नहीं जोड़ी है।',
      'harvested': 'काट ली गई',
      'growing': 'बढ़ रही है',
      'save_crop': 'फसल सहेजें',
      'father_name': 'पिता का नाम',
      'no_orders_found': 'कोई ऑर्डर नहीं मिला।', 'order_hash': 'ऑर्डर #', 'status': 'स्थिति:', 'items': 'आइटम:',
    },
    'ಕನ್ನಡ': {
      'home': 'ಮುಖಪುಟ', 'weather': 'ಹವಾಮಾನ', 'scan': 'ಸ್ಕ್ಯಾನ್', 'shop': 'ಅಂಗಡಿ', 'profile': 'ಪ್ರೊಫೈಲ್',
      'language_changed': 'ಭಾಷೆ ಬದಲಾಯಿಸಲಾಗಿದೆ', 'search': 'ಅಪ್ಲಿಕೇಶನ್ ವೈಶಿಷ್ಟ್ಯಗಳನ್ನು ಹುಡುಕಿ...', 'loading': 'ಲೋಡ್ ಆಗುತ್ತಿದೆ...',
      'error': 'ದೋಷ', 'no_results': 'ಯಾವುದೇ ಫಲಿತಾಂಶಗಳಿಲ್ಲ', 'retry': 'ಮರುಪ್ರಯತ್ನಿಸಿ', 'cancel': 'ರದ್ದುಗೊಳಿಸಿ',
      'seeds': 'ಬೀಜಗಳು',

      'ai_language_instruction': 'ದಯವಿಟ್ಟು ಕನ್ನಡದಲ್ಲಿ ಪ್ರತಿಕ್ರಿಯಿಸಿ.',

      'soil_moisture_predictor': 'ಮಣ್ಣಿನ ತೇವಾಂಶ ಭವಿಷ್ಯಸೂಚಕ', 'check_soil_condition': 'ನಿಮ್ಮ ಮಣ್ಣಿನ ಸ್ಥಿತಿಯನ್ನು ತಕ್ಷಣ ಪರಿಶೀಲಿಸಿ',
      'enter_data_moisture': 'ಡೇಟಾವನ್ನು ನಮೂದಿಸಿ ಮತ್ತು ಶಿಫಾರಸುಗಳೊಂದಿಗೆ ತ್ವರಿತ ತೇವಾಂಶ ಸ್ಥಿತಿಯನ್ನು ಪಡೆಯಿರಿ.',
      'input_data': 'ಇನ್ಪುಟ್ ಡೇಟಾ', 'upload_capture_soil': 'ಮಣ್ಣಿನ ಚಿತ್ರವನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ/ಸೆರೆಹಿಡಿಯಿರಿ',
      'no_image_selected': 'ಇನ್ನೂ कुनै ಚಿತ್ರವನ್ನು ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ. ಅಪ್‌ಲೋಡ್ ಬಳಸಿ.',
      'enter_location': 'ಸ್ಥಳವನ್ನು ನಮೂದಿಸಿ (ಉದಾ. ಬೆಂಗಳೂರು)', 'auto_detect': 'ಸ್ವಯಂ ಪತ್ತೆಹಚ್ಚಿ',
      'temperature_c': 'ತಾಪಮಾನ (°C)', 'humidity_pct': 'ಆರ್ದ್ರತೆ (%)', 'rainfall_mm': 'ಮಳೆ (ಮಿಮೀ)', 'soil_type': 'ಮಣ್ಣಿನ ಪ್ರಕಾರ',
      'checking': 'ಪರಿಶೀಲಿಸಲಾಗುತ್ತಿದೆ...', 'check_moisture': 'ತೇವಾಂಶವನ್ನು ಪರಿಶೀಲಿಸಿ', 'result': 'ಫಲಿತಾಂಶ', 'soil_moisture_level': 'ಮಣ್ಣಿನ ತೇವಾಂಶ ಮಟ್ಟ',
      'unknown': 'ಗೊತ್ತಿಲ್ಲ', 'no_prediction_yet': 'ಇನ್ನೂ कुनै ಮುನ್ಸೂಚನೆ ಇಲ್ಲ', 'estimated_moisture': 'ಅಂದಾಜು ತೇವಾಂಶ', 'recommendation': 'ಶಿಫಾರಸು',
      'use_button_advice': 'ಮಣ್ಣಿನ ತೇವಾಂಶವನ್ನು ಪಡೆಯಲು ಮೇಲಿನ ಬಟನ್ ಬಳಸಿ.',
      'tip_accurate_results': 'ಸಲಹೆ: ಹೆಚ್ಚು ನಿಖರವಾದ ಫಲಿತಾಂಶಗಳಿಗಾಗಿ, ಪ್ರಸ್ತುತ ಮೌಲ್ಯಗಳನ್ನು ನಮೂದಿಸಿ.',
      'ai_insight': 'AI ದೃಶ್ಯ ವಿಶ್ಲೇಷಣೆ',

      'shop_title': 'ಕೀಟನಾಶಕ', 'tab_fungicide': 'ಶಿಲೀಂಧ್ರನಾಶಕ', 'tab_insecticides': 'ಕೀಟನಾಶಕಗಳು', 'tab_herbicide': 'ಕಳೆನಾಶಕ', 'tab_bio': 'ಜೈವಿಕ ಕೀಟನಾಶಕಗಳು', 'you_save': 'ನೀವು ಉಳಿಸುತ್ತೀರಿ', 'added_to_cart': 'ಕಾರ್ಟ್‌ಗೆ ಸೇರಿಸಲಾಗಿದೆ', 'likes': 'ಇಷ್ಟಗಳು',
      
      'current_weather': 'ಪ್ರಸ್ತುತ ಹವಾಮಾನ', 'sunny_clear': 'ಬಿಸಿಲು ಮತ್ತು ಸ್ಪಷ್ಟ', 'no_rain_alert': 'ಇಂದು ಮಳೆಯ ಎಚ್ಚರಿಕೆ ಇಲ್ಲ', 'moisture': 'ತೇವಾಂಶ', 'healthy_level': 'ಆರೋಗ್ಯಕರ ಮಟ್ಟ', 'scan_crop': 'ಬೆಳೆಯನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ', 'ai_analysis_desc': 'ಆರೋಗ್ಯ ಮತ್ತು ಕೀಟಗಳ AI ವಿಶ್ಲೇಷಣೆ', 'sell_crops': 'ಬೆಳೆಗಳನ್ನು ಮಾರಿ', 'hire_machinery': 'ಯಂತ್ರೋಪಕರಣಗಳನ್ನು ಬಾಡಿಗೆಗೆ ಪಡೆಯಿರಿ', 'check_prices': 'ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳನ್ನು ಹತ್ತಿರ', 'quick_actions': 'ತ್ವರಿತ ಕ್ರಿಯೆಗಳು',
      
      'weather_title': 'ಹವಾಮಾನ ಮುನ್ಸೂಚನೆ', 'current_location': 'ಪ್ರಸ್ತುತ ಸ್ಥಳ', 'humidity': 'ಆರ್ದ್ರತೆ', 'wind': 'ಗಾಳಿ', 'rainfall': 'ಮಳೆ', 'rainfall_warning': 'ಮಳೆಯ ಎಚ್ಚರಿಕೆ', 'soil_moisture_label': 'ಮಣ್ಣಿನ ತೇವಾಂಶ', 'uv_index': 'ಯುವಿ ಸೂಚಿ', 'air_quality': 'ವಾಯು ಗುಣಮಟ್ಟ', 'next_5_days': 'ಮುಂದಿನ 5 ದಿನಗಳು', 'see_full_report': 'ಸಂಪೂರ್ಣ ವರದಿ ನೋಡಿ',
      'wind_speed': 'ಗಾಳಿಯ ವೇಗ', 'feels_like': 'ಅನಿಸುತ್ತದೆ', 'forecast_not_available': 'ಮುನ್ಸೂಚನೆ ಲಭ್ಯವಿಲ್ಲ', 'smart_farming_suggestions': 'ಸ್ಮಾರ್ಟ್ ಕೃಷಿ ಸಲಹೆಗಳು',
      'safe_spraying': 'ಸಿಂಪಡಣೆಗೆ ಸುರಕ್ಷಿತ', 'avoid_spraying': 'ಸಿಂಪಡಣೆ ತಪ್ಪಿಸಿ', 'good_planting': 'ನಾಟಿಗೆ ಒಳ್ಳೆಯದು', 'delay_planting': 'ನಾಟಿಯನ್ನು ವಿಳಂಬಗೊಳಿಸಿ',
      'low': 'ಕಡಿಮೆ', 'moderate': 'ಮಧ್ಯಮ', 'high': 'ಹೆಚ್ಚು', 'very_high': 'ತುಂಬಾ ಹೆಚ್ಚು', 'calm': 'ಶಾಂತ', 'fresh': 'ತಾಜಾ', 'strong': 'ಪ್ರಬಲ', 'optimal': 'ಸೂಕ್ತ',
      
      'point_at_leaf': 'ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಎಲೆಯ ಕಡೆಗೆ ಪಾಯಿಂಟ್ ಮಾಡಿ', 'ai_scanner': 'AI ಸ್ಕ್ಯಾನರ್', 'analyzing_leaf': 'AI ನಿಂದ ಎಲೆ ವಿಶ್ಲೇಷಿಸಲಾಗುತ್ತಿದೆ...', 'click_to_scan': 'ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಕ್ಲಿಕ್ ಮಾಡಿ', 'import_from_gallery': 'ಗ್ಯಾಲರಿಯಿಂದ ಆಮದು ಮಾಡಿ', 'analysis_result': 'ವಿಶ್ಲೇಷಣೆ ಫಲಿತಾಂಶ', 'close': 'ಮುಚ್ಚಿ',
      'scan_history': 'ಸ್ಕ್ಯಾನ್ ಇತಿಹಾಸ', 'no_scans_yet': 'ಇನ್ನೂ ಯಾವುದೇ ಸ್ಕ್ಯಾನ್‌ಗಳಿಲ್ಲ. ನಿಮ್ಮ ಸಸ್ಯಗಳನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಪ್ರಾರಂಭಿಸಿ!', 'login_to_see_history': 'ಇತಿಹಾಸವನ್ನು ನೋಡಲು ದಯವಿಟ್ಟು ಲಾಗ್ ಇನ್ ಮಾಡಿ.',

      'notifications': 'ಅಧಿಸೂಚನೆಗಳು', 'no_notifications': 'ಯಾವುದೇ ಅಧಿಸೂಚನೆಗಳಿಲ್ಲ', 'login_to_see_notifications': 'ಅಧಿಸೂಚನೆಗಳನ್ನು ವೀಕ್ಷಿಸಲು ದಯವಿಟ್ಟು ಲಾಗ್ ಇನ್ ಮಾಡಿ', 'just_now': 'ಈಗಷ್ಟೇ', 'days_ago': 'ದಿನಗಳ ಹಿಂದೆ', 'hours_ago': 'ಗಂಟೆಗಳ ಹಿಂದೆ', 'mins_ago': 'ನಿಮಿಷಗಳ ಹಿಂದೆ',

      'total_sales': 'ಒಟ್ಟು ಮಾರಾಟ', 'major_crops': 'ಪ್ರಮುಖ ಬೆಳೆಗಳು', 'save_profile': 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಿ', 'edit_profile': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ', 'recent_sales': 'ಇತ್ತೀಚಿನ ಮಾರಾಟಗಳು', 'view_all': 'ಎಲ್ಲವನ್ನೂ ವೀಕ್ಷಿಸಿ', 'completed': 'ಪೂರ್ಣಗೊಂಡಿದೆ', 'rental_history': 'ಬಾಡಿಗೆ ಇತಿಹಾಸ', 'log_out': 'ಲಾಗ್ ಔಟ್',
      'select_profile_picture': 'ಪ್ರೊಫೈಲ್ ಚಿತ್ರವನ್ನು ಆಯ್ಕೆಮಾಡಿ', 'full_name': 'ಪೂರ್ಣ ಹೆಸರು', 'location': 'ಸ್ಥಳ', 'e.g._wheat_rice': 'ಉದಾ. ಗೋಧಿ, ಅಕ್ಕಿ', 'profile_updated_successfully': 'ಪ್ರೊಫೈಲ್ ಅನ್ನು ಯಶಸ್ವಿಯಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ!',
      'change_language': 'ಭಾಷೆ ಬದಲಾಯಿಸಿ',

      'browse_categories': 'ವರ್ಗಗಳನ್ನು ಬ್ರೌಸ್ ಮಾಡಿ', 'machinery_booking': 'ಯಂತ್ರೋಪಕರಣಗಳ ಬುಕಿಂಗ್', 'tools_booking': 'ಪರಿಕರಗಳ ಬುಕಿಂಗ್', 'seeds_booking': 'ಬೀಜಗಳ ಬುಕಿಂಗ್', 'pesticides_booking': 'ಕೀಟನಾಶಕಗಳ ಬುಕಿಂಗ್',

      'available_now': 'ಈಗ ಲಭ್ಯವಿದೆ', 'professional_machinery': 'ವೃತ್ತಿಪರ ಯಂತ್ರೋಪಕರಣಗಳು', 'all_equipment': 'ಎಲ್ಲಾ ಉಪಕರಣಗಳು', 'tractors': 'ಟ್ರಾಕ್ಟರುಗಳು', 'tillage': 'ಉಳುಮೆ', 'per_hour': '/ಗಂಟೆ', 'book_now': 'ಈಗ ಬುಕ್ ಮಾಡಿ', 'call_owner': 'ಮಾಲೀಕರಿಗೆ ಕರೆ ಮಾಡಿ', 'booking_coming_soon': 'ಬುಕಿಂಗ್ ಹರಿವು ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ!',
      'mandi_prices_title': 'ಮಾರುಕಟ್ಟೆ ಬೆಲೆಗಳು ಮತ್ತು ಮಾರುಕಟ್ಟೆ', 'mandi_prices_subtitle': 'ನಿಮ್ಮ ಫಸಲಿಗೆ ಉತ್ತಮ ದರಗಳನ್ನು ಹುಡುಕಿ.', 'nearby': 'ಹತ್ತಿರದ', 'best_price': 'ಉತ್ತಮ ಬೆಲೆ', 'verified': 'ಪರಿಶೀಲಿಸಲಾಗಿದೆ', 'per_quintal': 'ಪ್ರತಿ ಕ್ವಿಂಟಾಲ್\u200cಗೆ', 'sell': 'ಮಾರು', 'market_analysis': 'ಮಾರುಕಟ್ಟೆ ವಿಶ್ಲೇಷಣೆ', 'more_filters': 'ಇನ್ನಷ್ಟು',
      'search_crops_hint': 'ಬೆಳೆಗಳನ್ನು ಹುಡುಕಿ (ಉದಾ., ಗೋಧಿ, ಅಕ್ಕಿ)...', 'post_your_crop': 'ನಿಮ್ಮ ಬೆಳೆಯನ್ನು ಪೋಸ್ಟ್ ಮಾಡಿ', 'market_analysis_desc': 'ಕಳೆದ 7 ದಿನಗಳಲ್ಲಿ ಗೋಧಿ ಬೆಲೆ 4% ರಷ್ಟು ಹೆಚ್ಚಾಗಿದೆ. ಇದು ನಿಮ್ಮ ಸ್ಟಾಕ್ ಪಟ್ಟಿ ಮಾಡಲು ಉತ್ತಮ ಸಮಯ.',
      'post_crop_coming_soon': 'ಬೆಳೆ ಪೋಸ್ಟ್ ಮಾಡುವ ಆಯ್ಕೆ ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ!', 'sell_flow_coming_soon': 'ಮಾರಾಟ ಪ್ರಕ್ರಿಯೆ ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ!', 'call_feature_coming_soon': 'ಕರೆ ವೈಶಿಷ್ಟ್ಯವು ಶೀಘ್ರದಲ್ಲೇ ಬರಲಿದೆ!',

      'book': 'ಬುಕ್ ಮಾಡಿ', 'booking': 'ಬುಕಿಂಗ್', 'your_details': 'ನಿಮ್ಮ ವಿವರಗಳು', 'mobile_number': 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ', 'farm_address': 'ಕೃಷಿ ವಿಳಾಸ',
      'hours_required': 'ಅಗತ್ಯವಿರುವ ಗಂಟೆಗಳು', 'booking_date': 'ಬುಕಿಂಗ್ ದಿನಾಂಕ', 'tap_select_date': 'ದಿನಾಂಕ ಆಯ್ಕೆ ಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
      'submit_booking': 'ಬುಕಿಂಗ್ ಸಲ್ಲಿಸಿ', 'booking_confirmed': 'ಬುಕಿಂಗ್ ದೃಢೀಕರಿಸಲಾಗಿದೆ!', 'machine_booked_success': 'ಯಂತ್ರೋಪಕರಣಗಳನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಬುಕ್ ಮಾಡಲಾಗಿದೆ.\nಅದು ಶೀಘ್ರದಲ್ಲೇ ನಿಮ್ಮ ಜಮೀನನ್ನು ತಲುಪುತ್ತದೆ.',
      'machine': 'ಯಂತ್ರ', 'name': 'ಹೆಸರು', 'date': 'ದಿನಾಂಕ', 'sms_sent': 'SMS ಕಳುಹಿಸಲಾಗಿದೆ: "ನಿಮ್ಮ ಯಂತ್ರೋಪಕರಣಗಳ ಬುಕಿಂಗ್ ದೃಢೀಕರಿಸಲಾಗಿದೆ."', 'back_to_shop': 'ಅಂಗಡಿಗೆ ಹಿಂತಿರುಗಿ',
      'enter_name': 'ನಿಮ್ಮ ಹೆಸರನ್ನು ನಮೂದಿಸಿ', 'enter_valid_mobile': 'ಮಾನ್ಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ', 'enter_address': 'ನಿಮ್ಮ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ', 'enter_hours': 'ಅಗತ್ಯವಿರುವ ಗಂಟೆಗಳನ್ನು ನಮೂದಿಸಿ',

      'my_cart': 'ನನ್ನ ಕಾರ್ಟ್', 'cart_empty': 'ನಿಮ್ಮ ಕಾರ್ಟ್ ಖಾಲಿಯಾಗಿದೆ', 'total': 'ಒಟ್ಟು', 'checkout': 'ಚೆಕ್ಔಟ್',
      'delivery_information': 'ವಿತರಣಾ ಮಾಹಿತಿ', 'email_address': 'ಇಮೇಲ್ ವಿಳಾಸ', 'full_delivery_address': 'ಪೂರ್ಣ ವಿತರಣಾ ವಿಳಾಸ',
      'payment_method': 'ಪಾವತಿ ವಿಧಾನ', 'cash_on_delivery': 'ವಿತರಣೆಯ ಸಮಯದಲ್ಲಿ ನಗದು', 'credit_debit_card': 'ಕ್ರೆಡಿಟ್/ಡೆಬಿಟ್ ಕಾರ್ಡ್',
      'total_amount': 'ಒಟ್ಟು ಮೊತ್ತ:', 'place_order': 'ಆರ್ಡರ್ ಮಾಡಿ', 'order_successful': 'ಆರ್ಡರ್ ಯಶಸ್ವಿಯಾಗಿದೆ!',
      'order_success_msg': 'ನಿಮ್ಮ ಆರ್ಡರ್ ಯಶಸ್ವಿಯಾಗಿದೆ ಮತ್ತು ಶೀಘ್ರದಲ್ಲೇ ವಿತರಿಸಲಾಗುವುದು.', 'cart_is_empty': 'ನಿಮ್ಮ ಕಾರ್ಟ್ ಖಾಲಿಯಾಗಿದೆ.',
      'error_placing_order': 'ಆರ್ಡರ್ ಮಾಡುವುದರಲ್ಲಿ ದೋಷ:', 'my_orders': 'ನನ್ನ ಆರ್ಡರ್\u200cಗಳು', 'login_to_view_orders': 'ನಿಮ್ಮ ಆರ್ಡರ್\u200cಗಳನ್ನು ವೀಕ್ಷಿಸಲು ದಯವಿಟ್ಟು ಲಾಗ್ ಇನ್ ಮಾಡಿ.',
      'my_crops': 'ನನ್ನ ಬೆಳೆಗಳು',
      'add_crop': 'ಬೆಳೆಯನ್ನು ಸೇರಿಸಿ',
      'crop_name': 'ಬೆಳೆಯ ಹೆಸರು',
      'acreage': 'ಎಕರೆ',
      'planting_date': 'ನಾಟಿ ಮಾಡಿದ ದಿನಾಂಕ',
      'no_crops_planted': 'ನೀವು ಇನ್ನೂ ಯಾವುದೇ ಬೆಳೆಗಳನ್ನು ಸೇರಿಸಿಲ್ಲ.',
      'harvested': 'ಕೊಯ್ಲು ಮಾಡಲಾಗಿದೆ',
      'growing': 'ಬೆಳೆಯುತ್ತಿದೆ',
      'save_crop': 'ಬೆಳೆಯನ್ನು ಉಳಿಸಿ',
      'father_name': 'ತಂದೆಯ ಹೆಸರು',
      'no_orders_found': 'ಯಾವುದೇ ಆರ್ಡರ್\u200cಗಳಿಲ್ಲ.', 'order_hash': 'ಆರ್ಡರ್ #', 'status': 'ಸ್ಥಿತಿ:', 'items': 'ವಸ್ತುಗಳು:',
    },
  };

  static String translate(String key) {
    final lang = currentLanguage.value;
    if (_translations.containsKey(lang) && _translations[lang]!.containsKey(key)) {
      return _translations[lang]![key]!;
    }
    // Fallback to English if language or key not found
    return _translations['English']?[key] ?? key;
  }
}
