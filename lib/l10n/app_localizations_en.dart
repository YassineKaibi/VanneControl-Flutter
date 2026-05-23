// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'VanneControl';

  @override
  String get appSubtitle => 'Easily manage your valves remotely.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get loginTitle => 'Login';

  @override
  String get emailHint => 'Email address';

  @override
  String get passwordHint => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Log In';

  @override
  String get noAccount => 'Don\'t have an account? Sign up now';

  @override
  String get loginError => 'Login failed. Please check your credentials.';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get loggingIn => 'Logging in...';

  @override
  String get registering => 'Registering...';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get registerTitle => 'User Registration';

  @override
  String get firstNameHint => 'First name';

  @override
  String get lastNameHint => 'Last name';

  @override
  String get phoneHint => 'Phone';

  @override
  String get confirmPasswordHint => 'Confirm password';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get haveAccount => 'Already have an account? Log in';

  @override
  String get registrationSuccess => 'Registration successful!';

  @override
  String get registrationError => 'Registration failed. Please try again.';

  @override
  String get errorFirstNameRequired => 'First name is required';

  @override
  String get errorFirstNameTooShort =>
      'First name is too short (min. 2 characters)';

  @override
  String get errorLastNameRequired => 'Last name is required';

  @override
  String get errorLastNameTooShort =>
      'Last name is too short (min. 2 characters)';

  @override
  String get errorEmailRequired => 'Email is required';

  @override
  String get errorEmailInvalid => 'Invalid email format';

  @override
  String get errorPhoneRequired => 'Phone number is required';

  @override
  String get errorPhoneInvalid => 'Invalid phone number (min. 8 digits)';

  @override
  String get errorPasswordRequired => 'Password is required';

  @override
  String get errorPasswordTooShort =>
      'Password is too short (min. 6 characters)';

  @override
  String get errorConfirmPasswordRequired => 'Confirmation required';

  @override
  String get errorPasswordsNotMatch => 'Passwords do not match';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get welcome => 'Welcome to';

  @override
  String get controlPanel => 'Control Panel';

  @override
  String get activeValves => 'Active Valves';

  @override
  String get controlModules => 'Control Modules';

  @override
  String get valveManagement => 'Valve Management';

  @override
  String get valveManagementDescription => 'Full valve management';

  @override
  String get valveOperationHistory => 'Valve Operation History';

  @override
  String get valveOperationHistoryDescription =>
      'Detailed valve activation logs';

  @override
  String get usageStatistics => 'Usage Statistics';

  @override
  String get usageStatisticsDescription => 'Detailed valve usage reports';

  @override
  String get alertsAndNotifications => 'Alerts & Notifications';

  @override
  String get alertsAndNotificationsDescription =>
      'Review system telemetry and alerts';

  @override
  String get history => 'History';

  @override
  String get statistics => 'Statistics';

  @override
  String get profile => 'Profile';

  @override
  String get valve => 'Valve';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get noActiveValves => 'No active valves';

  @override
  String get valveManagementTitle => 'Valve Management';

  @override
  String get controlValves => 'Control Your Valves';

  @override
  String get valveStateChanged => 'Valve state changed successfully';

  @override
  String get valveStateError => 'Failed to change valve state';

  @override
  String get confirmAction => 'Confirm Action';

  @override
  String get confirmOpen => 'Do you want to open this valve?';

  @override
  String get confirmClose => 'Do you want to close this valve?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancel';

  @override
  String get open => 'Open';

  @override
  String get closeValve => 'Close';

  @override
  String get opened => 'Opened';

  @override
  String get closed => 'Closed';

  @override
  String get historyTitle => 'Valve Operation History';

  @override
  String get filterHistory => 'Filter History';

  @override
  String get selectValves => 'Select Valves';

  @override
  String get actionType => 'Action Type:';

  @override
  String get openings => 'Openings';

  @override
  String get closings => 'Closings';

  @override
  String get period => 'Period:';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get clearFilters => 'Clear';

  @override
  String get applyFilters => 'Apply';

  @override
  String get noHistory => 'No history found';

  @override
  String get noHistoryDescription => 'Valve operation history will appear here';

  @override
  String get loading => 'Loading...';

  @override
  String get statisticsTitle => 'Usage Statistics';

  @override
  String get exportPdf => 'PDF';

  @override
  String get overview => 'Overview';

  @override
  String get totalValves => 'Total Valves';

  @override
  String get activeNow => 'Active Now';

  @override
  String get inactiveValves => 'Inactive';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get activationTimeline => 'Activation Timeline';

  @override
  String get valveSelection => 'Valve Selection';

  @override
  String get selectValvesChart => 'Select valves to visualize';

  @override
  String get noData => 'No data available';

  @override
  String get exportSuccess => 'PDF exported successfully';

  @override
  String get exportError => 'Failed to export PDF';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get location => 'Location';

  @override
  String get system => 'System';

  @override
  String get numberOfControlledValves => 'Number of Controlled Valves';

  @override
  String valvesToManage(int count) {
    return '$count valves to manage';
  }

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get appVersion => 'App Version';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get back => 'Back';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get timingPlan => 'Timing Plan';

  @override
  String get timingPlanDescription => 'Manage valve schedules';

  @override
  String get noSchedules => 'No schedules yet';

  @override
  String get tapAddSchedule => 'Tap Add to create your first schedule';

  @override
  String get scheduleName => 'Schedule Name';

  @override
  String get selectValve => 'Select Valve';

  @override
  String get repeat => 'Repeat';

  @override
  String get once => 'Once';

  @override
  String get everyday => 'Everyday';

  @override
  String get weekdays => 'Weekdays';

  @override
  String get weekends => 'Weekends';

  @override
  String get custom => 'Custom';

  @override
  String get timedOn => 'ON';

  @override
  String get timedOff => 'OFF';

  @override
  String get scheduleSaved => 'Schedule saved successfully';

  @override
  String get scheduleDeleted => 'Schedule deleted';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String get deleteScheduleConfirm =>
      'Are you sure you want to delete this schedule?';

  @override
  String get todoImplement => 'TODO: implement';

  @override
  String get chartPlaceholder => 'Chart placeholder';

  @override
  String get all => 'All';

  @override
  String get activated => 'Activated';

  @override
  String get deactivated => 'Deactivated';

  @override
  String get totalEvents => 'Total Events';

  @override
  String get schedulingTitle => 'Scheduling';

  @override
  String resultCount(int shown, int total) {
    return '$shown result(s) out of $total';
  }

  @override
  String get by => 'By:';

  @override
  String get changeProfilePhoto => 'Change Profile Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get valveSettings => 'Valve Settings';

  @override
  String get profileSaved => 'Profile saved successfully';

  @override
  String get numberOfValves => 'Number of Valves (1-8)';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connectionStatus => 'Connection Status';

  @override
  String get pistonStatus => 'Piston Status';

  @override
  String get pistonOpen => 'Piston Open';

  @override
  String get pistonClosed => 'Piston Closed';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get sinceBeginning => 'Since beginning';

  @override
  String get period7Days => 'Last 7 days';

  @override
  String get period30Days => 'Last 30 days';

  @override
  String get connectionError =>
      'Unable to reach server. Please check your connection.';

  @override
  String get useCurrentLocation => 'Use current location';

  @override
  String get locationPermissionDenied => 'Location permission denied';

  @override
  String get locationError => 'Unable to get location. Please try again.';

  @override
  String get navigateTo => 'Navigate to site';
}
