import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const supportedLanguageCodes = ['en', 'hi'];

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      "crop_list_title": "My Crops",
        "crop_list_filter_stage_title": "Filter by Stage",
        "crop_list_filter_all": "All",
        "crop_list_empty_title": "No crops found",
        "crop_list_empty_subtitle_all": "Add your first crop to get started",
        "crop_list_empty_subtitle_stage": "No crops in {stage} stage",
        "crop_list_add_button": "Add Crop",
        "crop_list_card_sown_prefix": "Sown:",
        "crop_list_card_update_stage": "Update Stage",
        "crop_list_card_report_loss": "Report Loss",
        "crop_list_update_dialog_title": "Update {cropName} Stage",
        "crop_list_update_stage_success": "{cropName} stage updated to {stage}",

        "unit_acres": "acres",

        "crop_stage_sowing": "Sowing",
        "crop_stage_vegetative": "Vegetative",
        "crop_stage_flowering": "Flowering",
        "crop_stage_fruiting": "Fruiting",
        "crop_stage_harvest": "Harvest",

        // "common_cancel": "Cancel"
      'common_cancel': 'Cancel',

      // 'unit_acres': 'acres',

      'crop_detail_title': 'Crop Details',
      'crop_detail_not_found': 'Crop not found',
      'crop_detail_no_image': 'No image available',

      'crop_detail_basic_info_title': 'Basic Information',
      'crop_detail_basic_info_crop_type': 'Crop Type',
      'crop_detail_basic_info_area': 'Area',
      'crop_detail_basic_info_sowing_date': 'Sowing Date',
      'crop_detail_basic_info_current_stage': 'Current Stage',
      'crop_detail_basic_info_days_since': 'Days Since Sowing',

      'crop_detail_stage_title': 'Crop Stage Progress',
      'crop_detail_stage_current': 'Current Stage',

      'crop_detail_location_title': 'Location Information',
      'crop_detail_location_address': 'Address',
      'crop_detail_location_latitude': 'Latitude',
      'crop_detail_location_longitude': 'Longitude',
      'crop_detail_location_view_on_map': 'View on Map',
      'crop_detail_location_opening_map': 'Opening map...',

      'crop_detail_update_stage_button': 'Update Stage',
      'crop_detail_report_loss_button': 'Report Loss',

      // 'crop_stage_sowing': 'Sowing',
      // 'crop_stage_vegetative': 'Vegetative',
      // 'crop_stage_flowering': 'Flowering',
      // 'crop_stage_fruiting': 'Fruiting',
      // 'crop_stage_harvest': 'Harvest',

      'crop_detail_update_stage_title': 'Update {cropName} Stage',
      'crop_detail_update_stage_success': '{cropName} stage updated to {stage}',

      'crop_detail_weekly_title': 'Weekly Crop Images',
      'crop_detail_weekly_upload_button': 'Upload Weekly Image',
      'crop_detail_weekly_empty_title': 'No weekly images yet',
      'crop_detail_weekly_empty_subtitle':
          'Upload weekly images to monitor crop health',

      'crop_detail_weekly_status_healthy': 'Healthy',
      'crop_detail_weekly_status_issue': 'Issue Detected',
      'crop_detail_weekly_status_analyzing': 'Analyzing...',

      'crop_detail_upload_success_healthy':
          'Image uploaded! Crop is healthy.',
      'crop_detail_upload_success_issue':
          'Image uploaded! Issue detected: {diseaseType}',
      'crop_detail_upload_unknown_disease': 'Unknown',
      'crop_detail_upload_error': 'Error uploading image',

      'common_save': 'Save',
      // 'unit_acres': 'acres',

      'add_crop_title': 'Add New Crop',
      'add_crop_select_plot_label': 'Select Plot',
      'add_crop_select_plot_hint': 'Select the plot for this crop',
      'add_crop_select_plot_error': 'Please select a plot',
      'add_crop_no_plots_text': 'No plots registered. Please register a plot first.',
      'add_crop_register_plot_button': 'Register Plot',

      'add_crop_image_label': 'Crop Image',
      'add_crop_image_hint': 'Tap to add crop image',

      'add_crop_name_label': 'Crop Name',
      'add_crop_name_hint': 'e.g., Rice Field 1',
      'add_crop_name_error': 'Please enter crop name',

      'add_crop_type_label': 'Crop Type',
      'add_crop_sowing_date_label': 'Sowing Date',

      'add_crop_area_label': 'Area (acres)',
      'add_crop_area_hint': 'e.g., 2.5',
      'add_crop_area_suffix': 'acres',
      'add_crop_area_error_empty': 'Please enter area',
      'add_crop_area_error_invalid': 'Please enter a valid number',

      'add_crop_location_label': 'Location',
      'add_crop_farm_address_label': 'Farm Address',
      'add_crop_farm_address_hint': 'Enter your farm address',
      'add_crop_farm_address_error': 'Please enter farm address',

      'add_crop_getting_location': 'Getting...',
      'add_crop_get_location_button': 'Get Current Location',
      'add_crop_location_prefix': 'Location:',

      'add_crop_camera_permission_error': 'Camera permission is required to take a photo',
      'add_crop_camera_open_error': 'Failed to open camera',

      'add_crop_location_service_disabled': 'Location services are disabled.',
      'add_crop_location_permission_denied': 'Location permissions are denied',
      'add_crop_location_permission_denied_forever': 'Location permissions are permanently denied',
      'add_crop_location_error': 'Error getting location',

      'add_crop_submit_button': 'Add Crop',
      'add_crop_submit_success': 'Crop added successfully!',
      'add_crop_submit_missing_plot': 'Please select a plot',
      'add_crop_submit_missing_location': 'Please get your current location',

      // crop types
      'crop_type_rice': 'Rice',
      'crop_type_wheat': 'Wheat',
      'crop_type_maize': 'Maize',
      'crop_type_cotton': 'Cotton',
      'crop_type_sugarcane': 'Sugarcane',
      'crop_type_potato': 'Potato',
      'crop_type_tomato': 'Tomato',
      'crop_type_onion': 'Onion',
      'crop_type_chili': 'Chili',
      'crop_type_other': 'Other',

      'claims_title': 'My Claims',
      'claims_filter_by_status': 'Filter by Status',
      'claims_filter_all': 'All',

      'claims_empty_title': 'No claims found',
      'claims_empty_filtered_prefix': 'No claims with',
      'claims_empty_filtered_suffix': 'status',
      'claims_empty_sub_all': 'Report crop loss to file a claim',
      'claims_report_loss_button': 'Report Loss',

      'claims_loss_label_suffix': '% loss',
      'claims_disaster_prefix': 'Disaster:',
      'claims_approved_amount_prefix': 'Approved Amount:',
      'claims_crop_prefix': 'Crop:',

      'unknown_crop': 'Unknown Crop',

      // status labels
      'status_under_review': 'Under Review',
      'status_verified': 'Verified',
      'status_approved': 'Approved',
      'status_paid': 'Paid',
      'status_rejected': 'Rejected',

      // disaster labels (same as add-claim screen)
      'disaster_flood': 'Flood',
      'disaster_drought': 'Drought',
      'disaster_pest_attack': 'Pest Attack',
      'disaster_disease': 'Disease',
      'disaster_hailstorm': 'Hailstorm',
      'disaster_cyclone': 'Cyclone',
      'disaster_fire': 'Fire',
      'disaster_other': 'Other',

      'claim_title': 'Report Crop Loss',

      'claim_description_label': 'Description',
      'claim_description_hint': 'Describe the damage and its impact',
      'claim_error_description_required': 'Please enter description',

      'claim_est_loss_label': 'Estimated Loss (%)',
      'claim_est_loss_hint': 'e.g., 50',
      'claim_error_est_loss_required': 'Please enter estimated loss',
      'claim_error_est_loss_range': 'Please enter a valid percentage (0-100)',

      'claim_est_value_label': 'Estimated Value Loss (₹)',
      'claim_est_value_hint': 'e.g., 50000',
      'claim_error_est_value_required': 'Please enter estimated value loss',
      'claim_error_est_value_invalid': 'Please enter a valid amount',

      'claim_submit_details': 'Submit Claim Details',
      'claim_details_submitted': 'Claim Submitted',

      'claim_select_crop_title': 'Select Crop',
      'claim_select_crop_hint': 'Select the affected crop',
      'claim_error_crop_required': 'Please select a crop',
      'claim_error_crop_required_snack': 'Please select a crop',

      'claim_disaster_type_title': 'Disaster Type',
      'claim_disaster_date_title': 'Disaster Date',

      'claim_evidence_title': 'Damage Evidence (Photos)',
      'claim_evidence_info_before':
          'First submit claim details, then upload damage photos.',
      'claim_evidence_info_after':
          'Upload photos showing the damage to your crops.',
      'claim_add_photos_button': 'Add Photos',
      'claim_upload_evidence_button': 'Upload Damage Evidence',

      // snack + status
      'claim_registered_next_upload':
          'Claim registered! Now upload damage evidence.',
      'claim_registered_no_id':
          'Claim registered (id not fetched, but registered).',
      'claim_error_register_failed': 'Failed to register claim',
      'claim_error_no_claimid': 'Please submit claim details first',
      'claim_error_no_images': 'Please add at least one image',
      'claim_evidence_upload_success': 'Evidence uploaded successfully!',
      'claim_evidence_upload_failed': 'Failed to upload evidence',

      // disaster type names
      // 'disaster_flood': 'Flood',
      // 'disaster_drought': 'Drought',
      // 'disaster_pest_attack': 'Pest Attack',
      // 'disaster_disease': 'Disease',
      // 'disaster_hailstorm': 'Hailstorm',
      // 'disaster_cyclone': 'Cyclone',
      // 'disaster_fire': 'Fire',
      // 'disaster_other': 'Other',

      // bottom nav
      'nav_home': 'Home',
      'nav_crops': 'Crops',
      'nav_claims': 'Claims',
      'nav_insights': 'Insights',
      'nav_profile': 'Profile',

      // units
      // 'unit_acres': 'acres',

      // home dashboard
      'home_dashboard_title': 'Farmer Dashboard',
      'home_welcome_back': 'Welcome back,',
      'home_farmer_fallback': 'Farmer',
      'home_welcome_subtitle': 'Manage your crops and track your farming journey',

      'home_total_crops': 'Total Crops',
      'home_total_area': 'Total Area',

      'home_recent_crops': 'Recent Crops',
      'home_view_all': 'View All',
      'home_no_crops_title': 'No crops yet',
      'home_no_crops_subtitle': 'Add your first crop to get started',
      'home_register_plot_button': 'Register Plot',

      'home_weather_alert_title': 'Weather Alert',

      'home_quick_actions_title': 'Quick Actions',
      'home_action_register_plot': 'Register Plot',
      'home_action_report_loss': 'Report Loss',

      // Insights / weather
      'insights_title': 'Insights',
      'ins_current_coords': 'Current coords:',
      'ins_loc_service_off': 'Location service is OFF. Please enable GPS.',
      'ins_loc_perm_denied': 'Location permission denied. Cannot fetch weather.',
      'ins_loc_perm_denied_forever':
          'Location permission permanently denied. Enable from settings.',
      'ins_err_fetch_weather': 'Error fetching weather',

      'ins_no_weather': 'No weather data available',
      'ins_weather_title': 'Weather Details',
      'ins_unknown_location': 'Unknown location',
      'ins_weather_humidity': 'Humidity',
      'ins_weather_wind': 'Wind',
      'ins_weather_updated': 'Updated',

      'ins_humidity_chart_title': 'Humidity (%)',
      'ins_temp_chart_title': 'Temperature (°C)',
      'ins_upcoming_weather': 'Upcoming Weather',

      // ML section
      'ins_no_ml_title': 'No ML Predictions Yet',
      'ins_no_ml_subtitle':
          'Upload weekly crop images to get ML-based health predictions and care suggestions',
      'ins_ml_section_title': 'Crop Health Predictions & Care Suggestions',

      'ins_crop_healthy': 'Crop is Healthy',
      'ins_issue_detected': 'Issue Detected',
      'ins_unknown_disease': 'Unknown',
      'ins_disease_label': 'Disease',
      'ins_care_recommendations': 'Care Recommendations',
      'ins_image_captured': 'Image captured:',



      'plot_register_title': 'Register Plot',

      'plot_details_title': 'Plot Details',
      'plot_name_label': 'Plot Name',
      'plot_name_hint': 'e.g., Main Farm Plot',
      'plot_name_error': 'Please enter plot name',
      'plot_area_label': 'Area (acres)',
      'plot_area_hint': 'e.g., 2.5',
      'plot_area_suffix': 'acres',
      'plot_area_error_empty': 'Please enter area',
      'plot_area_error_invalid': 'Please enter a valid number',

      'plot_reg_date_label': 'Registration Date',

      'plot_location_title': 'Location Details',
      'plot_location_subtitle':
          'GPS will auto-fill village, district, state and country.',
      'plot_location_getting': 'Getting location...',
      'plot_location_button': 'Use Current Location',
      'plot_latitude': 'Latitude',
      'plot_longitude': 'Longitude',
      'plot_village_label': 'Village / Locality',
      'plot_village_error': 'Please enter village/locality',
      'plot_district_label': 'District',
      'plot_district_error': 'Please enter district',
      'plot_state_label': 'State',
      'plot_state_error': 'Please enter state',
      'plot_country_label': 'Country',
      'plot_country_error': 'Please enter country',
      'plot_pincode_label': 'Pincode (optional)',
      'plot_address_label': 'Full Address',
      'plot_address_hint': 'Auto-filled from GPS, you can edit',
      'plot_address_error': 'Please enter plot address',
      'plot_location_captured': 'Location captured:',

      'plot_image_section_title': 'Plot Image / Land Document',
      'plot_image_msg_before':
          'First submit plot details, then you can upload an image.',
      'plot_image_msg_after': 'Now you can upload plot image.',
      'plot_image_type_label': 'Image Type',
      'plot_image_type_error': 'Please select image type',
      'plot_select_image_button': 'Select Image',

      'plot_submit_details_button': 'Submit Plot Details',
      'plot_details_submitted': 'Plot Details Submitted',
      'plot_upload_image_button': 'Upload Plot Image',

      'plot_err_use_location': 'Please use current location',
      'plot_registered_msg': 'Plot registered! Now upload plot image.',
      'plot_register_failed': 'Failed to register plot',
      'plot_err_submit_details_first': 'Please submit plot details first',
      'plot_err_select_image': 'Please select an image',
      'plot_upload_success': 'Plot image uploaded successfully!',
      'plot_upload_failed': 'Failed to upload image',

      'err_location_services_disabled': 'Location services are disabled',
      'err_location_permission_denied': 'Location permission denied',
      'err_location_permission_denied_forever':
          'Location permission permanently denied',
      'err_getting_location': 'Error getting location',
      'err_not_authenticated': 'Not authenticated',

      'unknown_error': 'Unknown error',

      'profile_title': 'Profile',
      'profile_user_not_found': 'User not found',
      'profile_info_title': 'Profile Information',
      'profile_name': 'Name',
      'profile_email': 'Email',
      'profile_phone': 'Phone',
      'profile_address': 'Address',
      'profile_member_since': 'Member Since',

      'profile_settings': 'Settings',
      'profile_notifications': 'Notifications',
      'profile_notifications_sub': 'Manage notification preferences',
      'profile_privacy': 'Privacy',
      'profile_privacy_sub': 'Manage your privacy settings',
      'profile_help': 'Help & Support',
      'profile_help_sub': 'Get help and contact support',
      'profile_about': 'About',
      'profile_about_sub': 'App version and information',
      'profile_about_desc': 'A comprehensive farming app for crop management and disaster reporting.',

      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'app_title': 'Farmer App',
      'login_subtitle': 'Manage your crops and track your farming journey',
      'login_phone_label': 'Phone Number',
      'login_phone_hint': 'Enter your phone number',
      'login_password_label': 'Password',
      'login_password_hint': 'Enter your password',
      'login_button': 'Login',
      'login_no_account': "Don't have an account? ",
      'login_signup': 'Sign Up',
      'login_demo_title': 'Demo Credentials',
      'login_demo_body': 'Phone: your registered number\nPassword: your password',
      // Auth / Signup
      'signup_title': 'Create Account',
      'signup_subtitle': 'Create your account to start managing your crops',
      'signup_full_name': 'Full Name',
      'signup_full_name_hint': 'Enter your full name',
      'signup_email': 'Email (optional)',
      'signup_email_hint': 'Enter your email (optional)',
      'signup_phone': 'Phone Number',
      'signup_phone_hint': 'Enter your phone number',
      'signup_address': 'Farm Address',
      'signup_address_hint': 'Enter your farm address',
      'signup_password': 'Password',
      'signup_password_hint': 'Enter your password',
      'signup_confirm_password': 'Confirm Password',
      'signup_confirm_password_hint': 'Confirm your password',
      'signup_button': 'Create Account',
      'signup_already': 'Already have an account? ',
      'signup_login': 'Login',

      // Validation messages
      'val_enter_name': 'Please enter your name',
      'val_enter_phone': 'Please enter your phone number',
      'val_enter_address': 'Please enter your address',
      'val_enter_password': 'Please enter your password',
      'val_password_length': 'Password must be at least 6 characters',
      'val_confirm_password': 'Please confirm your password',
      'val_password_mismatch': 'Passwords do not match',
      'val_email_invalid': 'Please enter a valid email',
    },
    'hi': {
      "crop_list_title": "मेरी फसलें",
      "crop_list_filter_stage_title": "स्टेज के अनुसार फ़िल्टर करें",
      "crop_list_filter_all": "सभी",
      "crop_list_empty_title": "कोई फसल नहीं मिली",
      "crop_list_empty_subtitle_all": "शुरू करने के लिए अपनी पहली फसल जोड़ें",
      "crop_list_empty_subtitle_stage": "{stage} स्टेज में कोई फसल नहीं",
      "crop_list_add_button": "फसल जोड़ें",
      "crop_list_card_sown_prefix": "बोआई:",
      "crop_list_card_update_stage": "स्टेज अपडेट करें",
      "crop_list_card_report_loss": "नुकसान रिपोर्ट करें",
      "crop_list_update_dialog_title": "{cropName} की स्टेज अपडेट करें",
      "crop_list_update_stage_success": "{cropName} की स्टेज {stage} कर दी गई है",

      "unit_acres": "एकड़",

      "crop_stage_sowing": "बोआई",
      "crop_stage_vegetative": "वेजिटेटिव",
      "crop_stage_flowering": "फूल आने की स्टेज",
      "crop_stage_fruiting": "फल बनने की स्टेज",
      "crop_stage_harvest": "कटाई",

      "common_cancel": "रद्द करें",
      // 'common_cancel': 'रद्द करें',

      // 'unit_acres': 'एकड़',

      'crop_detail_title': 'फसल विवरण',
      'crop_detail_not_found': 'फसल नहीं मिली',
      'crop_detail_no_image': 'कोई फोटो उपलब्ध नहीं',

      'crop_detail_basic_info_title': 'मूल जानकारी',
      'crop_detail_basic_info_crop_type': 'फसल का प्रकार',
      'crop_detail_basic_info_area': 'क्षेत्रफल',
      'crop_detail_basic_info_sowing_date': 'बोवाई की तारीख',
      'crop_detail_basic_info_current_stage': 'वर्तमान चरण',
      'crop_detail_basic_info_days_since': 'बोवाई के बाद के दिन',

      'crop_detail_stage_title': 'फसल वृद्धि चरण',
      'crop_detail_stage_current': 'वर्तमान चरण',

      'crop_detail_location_title': 'स्थान संबंधी जानकारी',
      'crop_detail_location_address': 'पता',
      'crop_detail_location_latitude': 'अक्षांश',
      'crop_detail_location_longitude': 'देशांतर',
      'crop_detail_location_view_on_map': 'मैप पर देखें',
      'crop_detail_location_opening_map': 'मैप खोल रहे हैं...',

      'crop_detail_update_stage_button': 'चरण अपडेट करें',
      'crop_detail_report_loss_button': 'नुकसान रिपोर्ट करें',

      // 'crop_stage_sowing': 'बोवाई',
      // 'crop_stage_vegetative': 'वेजिटेटिव',
      // 'crop_stage_flowering': 'फूल आने का चरण',
      // 'crop_stage_fruiting': 'फल बनने का चरण',
      // 'crop_stage_harvest': 'कटाई',

      'crop_detail_update_stage_title': '{cropName} का चरण बदलें',
      'crop_detail_update_stage_success': '{cropName} का चरण {stage} कर दिया गया है',

      'crop_detail_weekly_title': 'साप्ताहिक फसल फोटो',
      'crop_detail_weekly_upload_button': 'साप्ताहिक फोटो अपलोड करें',
      'crop_detail_weekly_empty_title': 'अभी तक कोई साप्ताहिक फोटो नहीं',
      'crop_detail_weekly_empty_subtitle':
          'फसल की सेहत मॉनिटर करने के लिए हर हफ्ते फोटो अपलोड करें',

      'crop_detail_weekly_status_healthy': 'फसल स्वस्थ है',
      'crop_detail_weekly_status_issue': 'समस्या पाई गई',
      'crop_detail_weekly_status_analyzing': 'विश्लेषण हो रहा है...',

      'crop_detail_upload_success_healthy':
          'इमेज अपलोड हो गई! फसल स्वस्थ है।',
      'crop_detail_upload_success_issue':
          'इमेज अपलोड हो गई! समस्या: {diseaseType}',
      'crop_detail_upload_unknown_disease': 'अज्ञात',
      'crop_detail_upload_error': 'इमेज अपलोड करते समय समस्या आई',

      'common_save': 'सेव करें',
      // 'unit_acres': 'एकड़',

      'add_crop_title': 'नई फसल जोड़ें',
      'add_crop_select_plot_label': 'प्लॉट चुनें',
      'add_crop_select_plot_hint': 'इस फसल के लिए प्लॉट चुनें',
      'add_crop_select_plot_error': 'कृपया एक प्लॉट चुनें',
      'add_crop_no_plots_text': 'कोई प्लॉट रजिस्टर नहीं है। पहले प्लॉट रजिस्टर करें।',
      'add_crop_register_plot_button': 'प्लॉट रजिस्टर करें',

      'add_crop_image_label': 'फसल की फोटो',
      'add_crop_image_hint': 'फसल की फोटो जोड़ने के लिए टैप करें',

      'add_crop_name_label': 'फसल का नाम',
      'add_crop_name_hint': 'जैसे, धान खेत 1',
      'add_crop_name_error': 'कृपया फसल का नाम दर्ज करें',

      'add_crop_type_label': 'फसल का प्रकार',
      'add_crop_sowing_date_label': 'बोवाई की तारीख',

      'add_crop_area_label': 'क्षेत्रफल (एकड़)',
      'add_crop_area_hint': 'जैसे, 2.5',
      'add_crop_area_suffix': 'एकड़',
      'add_crop_area_error_empty': 'कृपया क्षेत्रफल दर्ज करें',
      'add_crop_area_error_invalid': 'कृपया सही संख्या दर्ज करें',

      'add_crop_location_label': 'स्थान',
      'add_crop_farm_address_label': 'खेत का पता',
      'add_crop_farm_address_hint': 'अपने खेत का पता दर्ज करें',
      'add_crop_farm_address_error': 'कृपया खेत का पता दर्ज करें',

      'add_crop_getting_location': 'लोकेशन ले रहे हैं...',
      'add_crop_get_location_button': 'वर्तमान लोकेशन लें',
      'add_crop_location_prefix': 'स्थान:',

      'add_crop_camera_permission_error': 'फोटो लेने के लिए कैमरा परमिशन ज़रूरी है',
      'add_crop_camera_open_error': 'कैमरा खोलने में दिक्कत हुई',

      'add_crop_location_service_disabled': 'लोकेशन सर्विस बंद है।',
      'add_crop_location_permission_denied': 'लोकेशन परमिशन मना कर दी गई है',
      'add_crop_location_permission_denied_forever': 'लोकेशन परमिशन हमेशा के लिए मना कर दी गई है',
      'add_crop_location_error': 'लोकेशन लेने में दिक्कत हुई',

      'add_crop_submit_button': 'फसल जोड़ें',
      'add_crop_submit_success': 'फसल सफलतापूर्वक जोड़ दी गई!',
      'add_crop_submit_missing_plot': 'कृपया एक प्लॉट चुनें',
      'add_crop_submit_missing_location': 'कृपया अपनी वर्तमान लोकेशन लें',

      // crop types
      'crop_type_rice': 'धान',
      'crop_type_wheat': 'गेहूं',
      'crop_type_maize': 'मक्का',
      'crop_type_cotton': 'कपास',
      'crop_type_sugarcane': 'गन्ना',
      'crop_type_potato': 'आलू',
      'crop_type_tomato': 'टमाटर',
      'crop_type_onion': 'प्याज़',
      'crop_type_chili': 'मिर्च',
      'crop_type_other': 'अन्य',

      'claims_title': 'मेरे क्लेम',
      'claims_filter_by_status': 'स्थिति के आधार पर छाँटें',
      'claims_filter_all': 'सभी',

      'claims_empty_title': 'कोई क्लेम नहीं मिला',
      'claims_empty_filtered_prefix': 'इस स्थिति वाला कोई क्लेम नहीं मिला:',
      'claims_empty_filtered_suffix': '',
      'claims_empty_sub_all': 'फसल नुकसान रिपोर्ट करके नया क्लेम दर्ज करें',
      'claims_report_loss_button': 'नुकसान रिपोर्ट करें',

      'claims_loss_label_suffix': '% नुकसान',
      'claims_disaster_prefix': 'आपदा:',
      'claims_approved_amount_prefix': 'मंज़ूर राशि:',
      'claims_crop_prefix': 'फसल:',

      'unknown_crop': 'अज्ञात फसल',

      // status labels
      'status_under_review': 'समीक्षा में',
      'status_verified': 'सत्यापित',
      'status_approved': 'स्वीकृत',
      'status_paid': 'भुगतान हो चुका',
      'status_rejected': 'अस्वीकृत',

      // disaster labels (same as pehle)
      'disaster_flood': 'बाढ़',
      'disaster_drought': 'सूखा',
      'disaster_pest_attack': 'कीट प्रकोप',
      'disaster_disease': 'रोग',
      'disaster_hailstorm': 'ओलावृष्टि',
      'disaster_cyclone': 'चक्रवात',
      'disaster_fire': 'आग',
      'disaster_other': 'अन्य',

      'claim_title': 'फसल नुकसान रिपोर्ट करें',

      'claim_description_label': 'विवरण',
      'claim_description_hint': 'नुकसान और उसके प्रभाव के बारे में बताइए',
      'claim_error_description_required': 'कृपया विवरण लिखें',

      'claim_est_loss_label': 'अनुमानित नुकसान (%)',
      'claim_est_loss_hint': 'जैसे 50',
      'claim_error_est_loss_required': 'कृपया अनुमानित प्रतिशत नुकसान लिखें',
      'claim_error_est_loss_range':
          'कृपया 0 से 100 के बीच सही प्रतिशत दर्ज करें',

      'claim_est_value_label': 'अनुमानित आर्थिक नुकसान (₹)',
      'claim_est_value_hint': 'जैसे 50000',
      'claim_error_est_value_required':
          'कृपया अनुमानित आर्थिक नुकसान लिखें',
      'claim_error_est_value_invalid': 'कृपया सही रकम दर्ज करें',

      'claim_submit_details': 'क्लेम विवरण सबमिट करें',
      'claim_details_submitted': 'क्लेम सबमिट हो गया',

      'claim_select_crop_title': 'फसल चुनें',
      'claim_select_crop_hint': 'जिस फसल को नुकसान हुआ है उसे चुनें',
      'claim_error_crop_required': 'कृपया फसल चुनें',
      'claim_error_crop_required_snack': 'कृपया फसल चुनें',

      'claim_disaster_type_title': 'आपदा का प्रकार',
      'claim_disaster_date_title': 'आपदा की तारीख',

      'claim_evidence_title': 'नुकसान के सबूत (फोटो)',
      'claim_evidence_info_before':
          'पहले क्लेम विवरण सबमिट करें, फिर नुकसान की फोटो अपलोड करें।',
      'claim_evidence_info_after':
          'फसल के नुकसान को दिखाने वाली फोटो अपलोड करें।',
      'claim_add_photos_button': 'फोटो जोड़ें',
      'claim_upload_evidence_button': 'नुकसान के सबूत अपलोड करें',

      'claim_registered_next_upload':
          'क्लेम रजिस्टर हो गया! अब नुकसान के सबूत अपलोड करें।',
      'claim_registered_no_id':
          'क्लेम रजिस्टर हो गया (ID नहीं मिली, लेकिन क्लेम बन गया है)।',
      'claim_error_register_failed': 'क्लेम रजिस्टर करने में समस्या आई',
      'claim_error_no_claimid': 'कृपया पहले क्लेम विवरण सबमिट करें',
      'claim_error_no_images': 'कृपया कम से कम एक फोटो जोड़ें',
      'claim_evidence_upload_success': 'सबूत सफलतापूर्वक अपलोड हो गए!',
      'claim_evidence_upload_failed':
          'सबूत अपलोड करने में समस्या आई',

      // disaster type names
      // 'disaster_flood': 'बाढ़',
      // 'disaster_drought': 'सूखा',
      // 'disaster_pest_attack': 'कीट प्रकोप',
      // 'disaster_disease': 'रोग',
      // 'disaster_hailstorm': 'ओलावृष्टि',
      // 'disaster_cyclone': 'चक्रवात',
      // 'disaster_fire': 'आग',
      // 'disaster_other': 'अन्य',

      // bottom nav
      'nav_home': 'होम',
      'nav_crops': 'फसलें',
      'nav_claims': 'दावे',
      'nav_insights': 'इनसाइट्स',
      'nav_profile': 'प्रोफ़ाइल',

      // units
      // 'unit_acres': 'एकड़',

      // home dashboard
      'home_dashboard_title': 'किसान डैशबोर्ड',
      'home_welcome_back': 'वापस स्वागत है,',
      'home_farmer_fallback': 'किसान',
      'home_welcome_subtitle': 'अपनी फसलों को मैनेज करें और खेती की जर्नी ट्रैक करें',

      'home_total_crops': 'कुल फसलें',
      'home_total_area': 'कुल क्षेत्रफल',

      'home_recent_crops': 'हाल की फसलें',
      'home_view_all': 'सभी देखें',
      'home_no_crops_title': 'अभी कोई फसल नहीं',
      'home_no_crops_subtitle': 'शुरू करने के लिए अपनी पहली फसल जोड़ें',
      'home_register_plot_button': 'प्लॉट रजिस्टर करें',

      'home_weather_alert_title': 'मौसम अलर्ट',

      'home_quick_actions_title': 'क्विक एक्शन',
      'home_action_register_plot': 'प्लॉट रजिस्टर करें',
      'home_action_report_loss': 'नुकसान रिपोर्ट करें',


      // Insights / weather
      'insights_title': 'इनसाइट्स',
      'ins_current_coords': 'वर्तमान कोऑर्डिनेट्स:',
      'ins_loc_service_off': 'लोकेशन सर्विस बंद है। कृपया GPS ऑन करें।',
      'ins_loc_perm_denied':
          'लोकेशन परमिशन deny कर दी गई। मौसम का डेटा नहीं लिया जा सकता।',
      'ins_loc_perm_denied_forever':
          'लोकेशन परमिशन हमेशा के लिए deny कर दी गई है। सेटिंग्स से ऑन करें।',
      'ins_err_fetch_weather': 'मौसम का डेटा लेते समय त्रुटि',

      'ins_no_weather': 'मौसम का डेटा उपलब्ध नहीं है',
      'ins_weather_title': 'मौसम विवरण',
      'ins_unknown_location': 'अज्ञात स्थान',
      'ins_weather_humidity': 'आर्द्रता',
      'ins_weather_wind': 'हवा',
      'ins_weather_updated': 'अपडेट समय',

      'ins_humidity_chart_title': 'आर्द्रता (%)',
      'ins_temp_chart_title': 'तापमान (°C)',
      'ins_upcoming_weather': 'आने वाला मौसम',

      // ML section
      'ins_no_ml_title': 'अभी कोई ML प्रिडिक्शन नहीं',
      'ins_no_ml_subtitle':
          'फसल की weekly फोटो अपलोड करें ताकि ML आधारित हेल्थ प्रिडिक्शन और केयर सजेशन मिल सकें',
      'ins_ml_section_title': 'फसल स्वास्थ्य प्रिडिक्शन और केयर सजेशन',

      'ins_crop_healthy': 'फसल स्वस्थ है',
      'ins_issue_detected': 'समस्या मिली',
      'ins_unknown_disease': 'अज्ञात',
      'ins_disease_label': 'रोग',
      'ins_care_recommendations': 'देखभाल के सुझाव',
      'ins_image_captured': 'फोटो ली गई:',


      'plot_register_title': 'प्लॉट रजिस्टर करें',

      'plot_details_title': 'प्लॉट विवरण',
      'plot_name_label': 'प्लॉट का नाम',
      'plot_name_hint': 'जैसे, मुख्य खेत प्लॉट',
      'plot_name_error': 'कृपया प्लॉट का नाम दर्ज करें',
      'plot_area_label': 'क्षेत्रफल (एकड़)',
      'plot_area_hint': 'जैसे, 2.5',
      'plot_area_suffix': 'एकड़',
      'plot_area_error_empty': 'कृपया क्षेत्रफल दर्ज करें',
      'plot_area_error_invalid': 'कृपया सही संख्या दर्ज करें',

      'plot_reg_date_label': 'पंजीकरण तिथि',

      'plot_location_title': 'स्थान विवरण',
      'plot_location_subtitle':
          'GPS से गाँव, ज़िला, राज्य और देश अपने आप भर जाएगा।',
      'plot_location_getting': 'लोकेशन ले रहे हैं...',
      'plot_location_button': 'करेंट लोकेशन इस्तेमाल करें',
      'plot_latitude': 'अक्षांश (Latitude)',
      'plot_longitude': 'देशांतर (Longitude)',
      'plot_village_label': 'गाँव / locality',
      'plot_village_error': 'कृपया गाँव / locality दर्ज करें',
      'plot_district_label': 'ज़िला',
      'plot_district_error': 'कृपया ज़िला दर्ज करें',
      'plot_state_label': 'राज्य',
      'plot_state_error': 'कृपया राज्य दर्ज करें',
      'plot_country_label': 'देश',
      'plot_country_error': 'कृपया देश दर्ज करें',
      'plot_pincode_label': 'पिनकोड (optional)',
      'plot_address_label': 'पूरा पता',
      'plot_address_hint': 'GPS से भरा गया, आप बदल सकते हैं',
      'plot_address_error': 'कृपया प्लॉट का पता दर्ज करें',
      'plot_location_captured': 'लोकेशन सेव की गई:',

      'plot_image_section_title': 'प्लॉट इमेज / ज़मीन का दस्तावेज़',
      'plot_image_msg_before':
          'पहले प्लॉट की डीटेल्स सबमिट करें, फिर इमेज अपलोड कर सकते हैं।',
      'plot_image_msg_after': 'अब आप प्लॉट की इमेज अपलोड कर सकते हैं।',
      'plot_image_type_label': 'इमेज का प्रकार',
      'plot_image_type_error': 'कृपया इमेज का प्रकार चुनें',
      'plot_select_image_button': 'इमेज चुनें',

      'plot_submit_details_button': 'प्लॉट विवरण सबमिट करें',
      'plot_details_submitted': 'प्लॉट विवरण सबमिट हो चुका है',
      'plot_upload_image_button': 'प्लॉट इमेज अपलोड करें',

      'plot_err_use_location': 'कृपया current location इस्तेमाल करें',
      'plot_registered_msg': 'प्लॉट रजिस्टर हो गया! अब इमेज अपलोड करें।',
      'plot_register_failed': 'प्लॉट रजिस्टर करने में समस्या',
      'plot_err_submit_details_first': 'कृपया पहले प्लॉट विवरण सबमिट करें',
      'plot_err_select_image': 'कृपया एक इमेज चुनें',
      'plot_upload_success': 'प्लॉट की इमेज सफलतापूर्वक अपलोड हुई!',
      'plot_upload_failed': 'इमेज अपलोड करने में समस्या',

      'err_location_services_disabled': 'लोकेशन सर्विस बंद है',
      'err_location_permission_denied': 'लोकेशन परमिशन deny कर दी गई',
      'err_location_permission_denied_forever':
          'लोकेशन परमिशन हमेशा के लिए deny कर दी गई',
      'err_getting_location': 'लोकेशन लेते समय error',
      'err_not_authenticated': 'आप लॉगिन नहीं हैं',

      'unknown_error': 'अज्ञात त्रुटि',

      'profile_title': 'प्रोफ़ाइल',
      'profile_user_not_found': 'उपयोगकर्ता नहीं मिला',
      'profile_info_title': 'प्रोफ़ाइल जानकारी',
      'profile_name': 'नाम',
      'profile_email': 'ईमेल',
      'profile_phone': 'फ़ोन',
      'profile_address': 'पता',
      'profile_member_since': 'से सदस्य',

      'profile_settings': 'सेटिंग्स',
      'profile_notifications': 'सूचनाएं',
      'profile_notifications_sub': 'सूचना प्राथमिकताएं प्रबंधित करें',
      'profile_privacy': 'गोपनीयता',
      'profile_privacy_sub': 'अपनी गोपनीयता सेटिंग्स प्रबंधित करें',
      'profile_help': 'मदद और समर्थन',
      'profile_help_sub': 'मदद प्राप्त करें और समर्थन से संपर्क करें',
      'profile_about': 'ऐप के बारे में',
      'profile_about_sub': 'ऐप संस्करण और जानकारी',
      'profile_about_desc': 'फसल प्रबंधन और आपदा रिपोर्टिंग के लिए एक संपूर्ण किसान ऐप।',

      'logout': 'लॉगआउट',
      'logout_confirm': 'क्या आप वास्तव में लॉगआउट करना चाहते हैं?',
      'cancel': 'रद्द करें',


      'app_title': 'किसान ऐप',
      'login_subtitle': 'अपनी फसलों को मैनेज करें और खेती की यात्रा ट्रैक करें',
      'login_phone_label': 'फ़ोन नंबर',
      'login_phone_hint': 'अपना फ़ोन नंबर दर्ज करें',
      'login_password_label': 'पासवर्ड',
      'login_password_hint': 'अपना पासवर्ड दर्ज करें',
      'login_button': 'लॉगिन',
      'login_no_account': 'खाता नहीं है? ',
      'login_signup': 'साइन अप',
      'login_demo_title': 'डेमो विवरण',
      'login_demo_body':
          'फ़ोन: आपका रजिस्टर्ड नंबर\nपासवर्ड: आपका पासवर्ड',
      // Auth / Signup
      'signup_title': 'खाता बनाएँ',
      'signup_subtitle': 'फसल प्रबंधन शुरू करने के लिए अपना खाता बनाएँ',
      'signup_full_name': 'पूरा नाम',
      'signup_full_name_hint': 'अपना पूरा नाम दर्ज करें',
      'signup_email': 'ईमेल (वैकल्पिक)',
      'signup_email_hint': 'अपना ईमेल दर्ज करें (वैकल्पिक)',
      'signup_phone': 'फ़ोन नंबर',
      'signup_phone_hint': 'अपना फ़ोन नंबर दर्ज करें',
      'signup_address': 'खेती का पता',
      'signup_address_hint': 'अपनी खेती का पता दर्ज करें',
      'signup_password': 'पासवर्ड',
      'signup_password_hint': 'अपना पासवर्ड दर्ज करें',
      'signup_confirm_password': 'पासवर्ड की पुष्टि करें',
      'signup_confirm_password_hint': 'अपना पासवर्ड फिर से दर्ज करें',
      'signup_button': 'खाता बनाएँ',
      'signup_already': 'पहले से खाता है? ',
      'signup_login': 'लॉगिन',

      // Validation messages
      'val_enter_name': 'कृपया अपना नाम दर्ज करें',
      'val_enter_phone': 'कृपया अपना फ़ोन नंबर दर्ज करें',
      'val_enter_address': 'कृपया अपना पता दर्ज करें',
      'val_enter_password': 'कृपया पासवर्ड दर्ज करें',
      'val_password_length': 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए',
      'val_confirm_password': 'कृपया पासवर्ड की पुष्टि करें',
      'val_password_mismatch': 'पासवर्ड मेल नहीं खा रहे',
      'val_email_invalid': 'कृपया सही ईमेल दर्ज करें',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLanguageCodes.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}