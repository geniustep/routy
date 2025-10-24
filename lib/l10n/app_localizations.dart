import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Routy'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Routy'**
  String get welcome;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Routy'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sales and Delivery Management'**
  String get loginSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @databaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get databaseLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @databaseRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a database'**
  String get databaseRequired;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @enterCredentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials'**
  String get enterCredentials;

  /// No description provided for @selectDatabase.
  ///
  /// In en, this message translates to:
  /// **'Select database'**
  String get selectDatabase;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get checkConnection;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcome_back;

  /// No description provided for @ready_to_achieve.
  ///
  /// In en, this message translates to:
  /// **'Ready to achieve your business goals?'**
  String get ready_to_achieve;

  /// No description provided for @whats_happening_today.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s happening today'**
  String get whats_happening_today;

  /// No description provided for @today_reports.
  ///
  /// In en, this message translates to:
  /// **'Today Reports'**
  String get today_reports;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'POS'**
  String get pos;

  /// No description provided for @purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouse;

  /// No description provided for @recent_activity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recent_activity;

  /// No description provided for @new_sale_created.
  ///
  /// In en, this message translates to:
  /// **'New Sale Created'**
  String get new_sale_created;

  /// No description provided for @new_customer_added.
  ///
  /// In en, this message translates to:
  /// **'New Customer Added'**
  String get new_customer_added;

  /// No description provided for @product_updated.
  ///
  /// In en, this message translates to:
  /// **'Product Updated'**
  String get product_updated;

  /// No description provided for @business_insights.
  ///
  /// In en, this message translates to:
  /// **'Business Insights'**
  String get business_insights;

  /// No description provided for @performance_overview.
  ///
  /// In en, this message translates to:
  /// **'Performance Overview'**
  String get performance_overview;

  /// No description provided for @track_business_growth.
  ///
  /// In en, this message translates to:
  /// **'Track your business growth with advanced analytics and real-time insights'**
  String get track_business_growth;

  /// No description provided for @monitor_sales_performance.
  ///
  /// In en, this message translates to:
  /// **'Monitor your sales performance and business metrics'**
  String get monitor_sales_performance;

  /// No description provided for @view_analytics.
  ///
  /// In en, this message translates to:
  /// **'View Analytics'**
  String get view_analytics;

  /// No description provided for @confirm_exit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Exit'**
  String get confirm_exit;

  /// No description provided for @exit_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the application?'**
  String get exit_confirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirm_logout;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logout_confirmation;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @logout_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during logout'**
  String get logout_error;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @database.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_button;

  /// No description provided for @remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get remember_me;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @login_error.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get login_error;

  /// No description provided for @invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalid_credentials;

  /// No description provided for @network_error.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get network_error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get please_wait;

  /// No description provided for @enter_credentials.
  ///
  /// In en, this message translates to:
  /// **'Enter your credentials'**
  String get enter_credentials;

  /// No description provided for @select_database.
  ///
  /// In en, this message translates to:
  /// **'Select database'**
  String get select_database;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get login_success;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get login_failed;

  /// No description provided for @connection_error.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connection_error;

  /// No description provided for @server_error.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get server_error;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get try_again;

  /// No description provided for @check_connection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection'**
  String get check_connection;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @light_theme.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get light_theme;

  /// No description provided for @dark_theme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get dark_theme;

  /// No description provided for @system_theme.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get system_theme;

  /// No description provided for @professional_theme.
  ///
  /// In en, this message translates to:
  /// **'Professional theme'**
  String get professional_theme;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @enable_notifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enable_notifications;

  /// No description provided for @push_notifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get push_notifications;

  /// No description provided for @email_notifications.
  ///
  /// In en, this message translates to:
  /// **'Email notifications'**
  String get email_notifications;

  /// No description provided for @location_services.
  ///
  /// In en, this message translates to:
  /// **'Location services'**
  String get location_services;

  /// No description provided for @auto_sync.
  ///
  /// In en, this message translates to:
  /// **'Auto sync'**
  String get auto_sync;

  /// No description provided for @font_size.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get font_size;

  /// No description provided for @small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get delete_account;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @build.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy_policy;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @settings_saved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settings_saved;

  /// No description provided for @settings_reset.
  ///
  /// In en, this message translates to:
  /// **'Settings reset'**
  String get settings_reset;

  /// No description provided for @partners.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get partners;

  /// No description provided for @partners_list.
  ///
  /// In en, this message translates to:
  /// **'Partners List'**
  String get partners_list;

  /// No description provided for @add_partner.
  ///
  /// In en, this message translates to:
  /// **'Add Partner'**
  String get add_partner;

  /// No description provided for @search_partner.
  ///
  /// In en, this message translates to:
  /// **'Search partner...'**
  String get search_partner;

  /// No description provided for @all_partners.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all_partners;

  /// No description provided for @customers_only.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers_only;

  /// No description provided for @suppliers_only.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers_only;

  /// No description provided for @both_types.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both_types;

  /// No description provided for @total_partners.
  ///
  /// In en, this message translates to:
  /// **'Total partners'**
  String get total_partners;

  /// No description provided for @total_customers.
  ///
  /// In en, this message translates to:
  /// **'Total customers'**
  String get total_customers;

  /// No description provided for @total_suppliers.
  ///
  /// In en, this message translates to:
  /// **'Total suppliers'**
  String get total_suppliers;

  /// No description provided for @no_partners.
  ///
  /// In en, this message translates to:
  /// **'No partners'**
  String get no_partners;

  /// No description provided for @no_results.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get no_results;

  /// No description provided for @try_different_search.
  ///
  /// In en, this message translates to:
  /// **'Try a different search'**
  String get try_different_search;

  /// No description provided for @start_adding.
  ///
  /// In en, this message translates to:
  /// **'Start adding partners'**
  String get start_adding;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @both.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get both;

  /// No description provided for @partner_details.
  ///
  /// In en, this message translates to:
  /// **'Partner details'**
  String get partner_details;

  /// No description provided for @export_partners.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export_partners;

  /// No description provided for @import_partners.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import_partners;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon...'**
  String get coming_soon;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @error_loading.
  ///
  /// In en, this message translates to:
  /// **'Error loading'**
  String get error_loading;

  /// No description provided for @has_debt.
  ///
  /// In en, this message translates to:
  /// **'Has debt'**
  String get has_debt;

  /// No description provided for @no_debt.
  ///
  /// In en, this message translates to:
  /// **'No debt'**
  String get no_debt;

  /// No description provided for @debt_amount.
  ///
  /// In en, this message translates to:
  /// **'Debt Amount'**
  String get debt_amount;

  /// No description provided for @credit_amount.
  ///
  /// In en, this message translates to:
  /// **'Credit Balance'**
  String get credit_amount;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @my_location.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get my_location;

  /// No description provided for @partners_refreshed.
  ///
  /// In en, this message translates to:
  /// **'Partners refreshed'**
  String get partners_refreshed;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @full_address.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get full_address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @zip.
  ///
  /// In en, this message translates to:
  /// **'Zip code'**
  String get zip;

  /// No description provided for @financial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get financial;

  /// No description provided for @total_balance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get total_balance;

  /// No description provided for @credit_limit.
  ///
  /// In en, this message translates to:
  /// **'Credit limit'**
  String get credit_limit;

  /// No description provided for @usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get usage;

  /// No description provided for @additional_info.
  ///
  /// In en, this message translates to:
  /// **'Additional information'**
  String get additional_info;

  /// No description provided for @vat.
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get vat;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @sales_trend.
  ///
  /// In en, this message translates to:
  /// **'Sales Trend'**
  String get sales_trend;

  /// No description provided for @last_7_days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last_7_days;

  /// No description provided for @no_data_available.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data_available;

  /// No description provided for @today_sales.
  ///
  /// In en, this message translates to:
  /// **'Today Sales'**
  String get today_sales;

  /// No description provided for @week_sales.
  ///
  /// In en, this message translates to:
  /// **'Week Sales'**
  String get week_sales;

  /// No description provided for @month_sales.
  ///
  /// In en, this message translates to:
  /// **'Month Sales'**
  String get month_sales;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'orders'**
  String get orders;

  /// No description provided for @of_target.
  ///
  /// In en, this message translates to:
  /// **'of target'**
  String get of_target;

  /// No description provided for @loading_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Loading dashboard...'**
  String get loading_dashboard;

  /// No description provided for @refresh_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Refresh Dashboard'**
  String get refresh_dashboard;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @sort_by.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sort_by;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_occurred;

  /// No description provided for @error_loading_data.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get error_loading_data;

  /// No description provided for @no_data_found.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get no_data_found;

  /// No description provided for @no_items_found.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get no_items_found;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @in_progress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get in_progress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @sales_orders.
  ///
  /// In en, this message translates to:
  /// **'Sales Orders'**
  String get sales_orders;

  /// No description provided for @search_sales_orders.
  ///
  /// In en, this message translates to:
  /// **'Search Sales Orders'**
  String get search_sales_orders;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @new_sale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get new_sale;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @sale_order.
  ///
  /// In en, this message translates to:
  /// **'Sale Order'**
  String get sale_order;

  /// No description provided for @order_info.
  ///
  /// In en, this message translates to:
  /// **'Order Information'**
  String get order_info;

  /// No description provided for @total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get total_amount;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @save_draft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get save_draft;

  /// No description provided for @add_product.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get add_product;

  /// No description provided for @scan_barcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scan_barcode;

  /// No description provided for @order_summary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get order_summary;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @create_order.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get create_order;

  /// No description provided for @order_details.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get order_details;

  /// No description provided for @select_customer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get select_customer;

  /// No description provided for @please_select_customer.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer'**
  String get please_select_customer;

  /// No description provided for @price_list.
  ///
  /// In en, this message translates to:
  /// **'Price List'**
  String get price_list;

  /// No description provided for @select_price_list.
  ///
  /// In en, this message translates to:
  /// **'Select Price List'**
  String get select_price_list;

  /// No description provided for @please_select_price_list.
  ///
  /// In en, this message translates to:
  /// **'Please select a price list'**
  String get please_select_price_list;

  /// No description provided for @payment_terms.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get payment_terms;

  /// No description provided for @select_payment_terms.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Terms'**
  String get select_payment_terms;

  /// No description provided for @please_select_payment_terms.
  ///
  /// In en, this message translates to:
  /// **'Please select payment terms'**
  String get please_select_payment_terms;

  /// No description provided for @set_delivery_date.
  ///
  /// In en, this message translates to:
  /// **'Set Delivery Date'**
  String get set_delivery_date;

  /// No description provided for @delivery_date.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get delivery_date;

  /// No description provided for @select_delivery_date.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Date'**
  String get select_delivery_date;

  /// No description provided for @please_select_delivery_date.
  ///
  /// In en, this message translates to:
  /// **'Please select delivery date'**
  String get please_select_delivery_date;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @please_enter_quantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter quantity'**
  String get please_enter_quantity;

  /// No description provided for @please_enter_valid_quantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid quantity'**
  String get please_enter_valid_quantity;

  /// No description provided for @please_enter_price.
  ///
  /// In en, this message translates to:
  /// **'Please enter price'**
  String get please_enter_price;

  /// No description provided for @please_enter_valid_price.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid price'**
  String get please_enter_valid_price;

  /// No description provided for @please_enter_discount.
  ///
  /// In en, this message translates to:
  /// **'Please enter discount'**
  String get please_enter_discount;

  /// No description provided for @please_enter_valid_discount.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid discount'**
  String get please_enter_valid_discount;

  /// No description provided for @no_products_added.
  ///
  /// In en, this message translates to:
  /// **'No products added'**
  String get no_products_added;

  /// No description provided for @add_products_to_order.
  ///
  /// In en, this message translates to:
  /// **'Add products to order'**
  String get add_products_to_order;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @add_products_tips.
  ///
  /// In en, this message translates to:
  /// **'Tips for adding products'**
  String get add_products_tips;

  /// No description provided for @draft_has_changes.
  ///
  /// In en, this message translates to:
  /// **'Draft has changes'**
  String get draft_has_changes;

  /// No description provided for @draft_saved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draft_saved;

  /// No description provided for @delete_draft.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get delete_draft;

  /// No description provided for @select_product.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get select_product;

  /// No description provided for @search_products.
  ///
  /// In en, this message translates to:
  /// **'Search Products'**
  String get search_products;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @all_categories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get all_categories;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @all_types.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get all_types;

  /// No description provided for @no_products_found.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get no_products_found;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @add_to_order.
  ///
  /// In en, this message translates to:
  /// **'Add to Order'**
  String get add_to_order;

  /// No description provided for @enter_quantity.
  ///
  /// In en, this message translates to:
  /// **'Enter Quantity'**
  String get enter_quantity;

  /// No description provided for @enter_price.
  ///
  /// In en, this message translates to:
  /// **'Enter Price'**
  String get enter_price;

  /// No description provided for @enter_discount.
  ///
  /// In en, this message translates to:
  /// **'Enter Discount'**
  String get enter_discount;

  /// No description provided for @update_order.
  ///
  /// In en, this message translates to:
  /// **'Update Order'**
  String get update_order;

  /// No description provided for @unsaved_changes.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsaved_changes;

  /// No description provided for @order_number.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get order_number;

  /// No description provided for @no_products.
  ///
  /// In en, this message translates to:
  /// **'No Products'**
  String get no_products;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @customer_info.
  ///
  /// In en, this message translates to:
  /// **'Customer Info'**
  String get customer_info;

  /// No description provided for @customer_name.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customer_name;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @draft_sales.
  ///
  /// In en, this message translates to:
  /// **'Draft Sales'**
  String get draft_sales;

  /// No description provided for @clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clear_all;

  /// No description provided for @search_drafts.
  ///
  /// In en, this message translates to:
  /// **'Search Drafts'**
  String get search_drafts;

  /// No description provided for @no_drafts_found.
  ///
  /// In en, this message translates to:
  /// **'No drafts found'**
  String get no_drafts_found;

  /// No description provided for @no_drafts.
  ///
  /// In en, this message translates to:
  /// **'No drafts'**
  String get no_drafts;

  /// No description provided for @create_new_order.
  ///
  /// In en, this message translates to:
  /// **'Create New Order'**
  String get create_new_order;

  /// No description provided for @continue_editing.
  ///
  /// In en, this message translates to:
  /// **'Continue Editing'**
  String get continue_editing;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @salesperson.
  ///
  /// In en, this message translates to:
  /// **'Salesperson'**
  String get salesperson;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
