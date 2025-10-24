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
  /// In fr, this message translates to:
  /// **'Routy'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans Routy'**
  String get welcome;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Routy'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des Ventes et Livraisons'**
  String get loginSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @databaseLabel.
  ///
  /// In fr, this message translates to:
  /// **'Base de données'**
  String get databaseLabel;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @usernameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre nom d\'utilisateur'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre mot de passe'**
  String get passwordRequired;

  /// No description provided for @databaseRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une base de données'**
  String get databaseRequired;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get loginError;

  /// No description provided for @invalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants invalides'**
  String get invalidCredentials;

  /// No description provided for @networkError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur réseau'**
  String get networkError;

  /// No description provided for @pleaseWait.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez patienter'**
  String get pleaseWait;

  /// No description provided for @enterCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Entrez vos identifiants'**
  String get enterCredentials;

  /// No description provided for @selectDatabase.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez la base de données'**
  String get selectDatabase;

  /// No description provided for @loginSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion'**
  String get loginFailed;

  /// No description provided for @connectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get connectionError;

  /// No description provided for @serverError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur du serveur'**
  String get serverError;

  /// No description provided for @tryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get tryAgain;

  /// No description provided for @checkConnection.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre connexion Internet'**
  String get checkConnection;

  /// No description provided for @dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get dashboard;

  /// No description provided for @welcome_back.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour'**
  String get welcome_back;

  /// No description provided for @ready_to_achieve.
  ///
  /// In fr, this message translates to:
  /// **'Prêt à atteindre vos objectifs commerciaux ?'**
  String get ready_to_achieve;

  /// No description provided for @whats_happening_today.
  ///
  /// In fr, this message translates to:
  /// **'Voici ce qui se passe aujourd\'hui'**
  String get whats_happening_today;

  /// No description provided for @today_reports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports d\'aujourd\'hui'**
  String get today_reports;

  /// No description provided for @view_all.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get view_all;

  /// No description provided for @target.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get target;

  /// No description provided for @progress.
  ///
  /// In fr, this message translates to:
  /// **'Progrès'**
  String get progress;

  /// No description provided for @quick_actions.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get quick_actions;

  /// No description provided for @products.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get products;

  /// No description provided for @customers.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get customers;

  /// No description provided for @sales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes'**
  String get sales;

  /// No description provided for @reports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get reports;

  /// No description provided for @expenses.
  ///
  /// In fr, this message translates to:
  /// **'Dépenses'**
  String get expenses;

  /// No description provided for @pos.
  ///
  /// In fr, this message translates to:
  /// **'Point de vente'**
  String get pos;

  /// No description provided for @purchase.
  ///
  /// In fr, this message translates to:
  /// **'Achats'**
  String get purchase;

  /// No description provided for @warehouse.
  ///
  /// In fr, this message translates to:
  /// **'Entrepôt'**
  String get warehouse;

  /// No description provided for @recent_activity.
  ///
  /// In fr, this message translates to:
  /// **'Activité récente'**
  String get recent_activity;

  /// No description provided for @new_sale_created.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle vente créée'**
  String get new_sale_created;

  /// No description provided for @new_customer_added.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau client ajouté'**
  String get new_customer_added;

  /// No description provided for @product_updated.
  ///
  /// In fr, this message translates to:
  /// **'Produit mis à jour'**
  String get product_updated;

  /// No description provided for @business_insights.
  ///
  /// In fr, this message translates to:
  /// **'Insights commerciaux'**
  String get business_insights;

  /// No description provided for @performance_overview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu des performances'**
  String get performance_overview;

  /// No description provided for @track_business_growth.
  ///
  /// In fr, this message translates to:
  /// **'Suivez la croissance de votre entreprise avec des analyses avancées et des insights en temps réel'**
  String get track_business_growth;

  /// No description provided for @monitor_sales_performance.
  ///
  /// In fr, this message translates to:
  /// **'Surveillez les performances de vos ventes et les métriques commerciales'**
  String get monitor_sales_performance;

  /// No description provided for @view_analytics.
  ///
  /// In fr, this message translates to:
  /// **'Voir les analyses'**
  String get view_analytics;

  /// No description provided for @confirm_exit.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la sortie'**
  String get confirm_exit;

  /// No description provided for @exit_confirmation.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir quitter l\'application ?'**
  String get exit_confirmation;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In fr, this message translates to:
  /// **'Sortir'**
  String get exit;

  /// No description provided for @confirm_logout.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer la déconnexion'**
  String get confirm_logout;

  /// No description provided for @logout_confirmation.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get logout_confirmation;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @logout_error.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite lors de la déconnexion'**
  String get logout_error;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @username.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get username;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @database.
  ///
  /// In fr, this message translates to:
  /// **'Base de données'**
  String get database;

  /// No description provided for @login_button.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login_button;

  /// No description provided for @remember_me.
  ///
  /// In fr, this message translates to:
  /// **'Se souvenir de moi'**
  String get remember_me;

  /// No description provided for @forgot_password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get forgot_password;

  /// No description provided for @login_error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get login_error;

  /// No description provided for @invalid_credentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants invalides'**
  String get invalid_credentials;

  /// No description provided for @network_error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur réseau'**
  String get network_error;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @please_wait.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez patienter'**
  String get please_wait;

  /// No description provided for @enter_credentials.
  ///
  /// In fr, this message translates to:
  /// **'Entrez vos identifiants'**
  String get enter_credentials;

  /// No description provided for @select_database.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez la base de données'**
  String get select_database;

  /// No description provided for @login_success.
  ///
  /// In fr, this message translates to:
  /// **'Connexion réussie'**
  String get login_success;

  /// No description provided for @login_failed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la connexion'**
  String get login_failed;

  /// No description provided for @connection_error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get connection_error;

  /// No description provided for @server_error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur du serveur'**
  String get server_error;

  /// No description provided for @try_again.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get try_again;

  /// No description provided for @check_connection.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre connexion Internet'**
  String get check_connection;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacy;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get about;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In fr, this message translates to:
  /// **'Préférences'**
  String get preferences;

  /// No description provided for @light_theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème clair'**
  String get light_theme;

  /// No description provided for @dark_theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème sombre'**
  String get dark_theme;

  /// No description provided for @system_theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème système'**
  String get system_theme;

  /// No description provided for @professional_theme.
  ///
  /// In fr, this message translates to:
  /// **'Thème professionnel'**
  String get professional_theme;

  /// No description provided for @arabic.
  ///
  /// In fr, this message translates to:
  /// **'Arabe'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @english.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In fr, this message translates to:
  /// **'Espagnol'**
  String get spanish;

  /// No description provided for @enable_notifications.
  ///
  /// In fr, this message translates to:
  /// **'Activer les notifications'**
  String get enable_notifications;

  /// No description provided for @push_notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications push'**
  String get push_notifications;

  /// No description provided for @email_notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications par e-mail'**
  String get email_notifications;

  /// No description provided for @location_services.
  ///
  /// In fr, this message translates to:
  /// **'Services de localisation'**
  String get location_services;

  /// No description provided for @auto_sync.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation automatique'**
  String get auto_sync;

  /// No description provided for @font_size.
  ///
  /// In fr, this message translates to:
  /// **'Taille de police'**
  String get font_size;

  /// No description provided for @small.
  ///
  /// In fr, this message translates to:
  /// **'Petit'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In fr, this message translates to:
  /// **'Grand'**
  String get large;

  /// No description provided for @delete_account.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get delete_account;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @build.
  ///
  /// In fr, this message translates to:
  /// **'Build'**
  String get build;

  /// No description provided for @developer.
  ///
  /// In fr, this message translates to:
  /// **'Développeur'**
  String get developer;

  /// No description provided for @support.
  ///
  /// In fr, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @terms.
  ///
  /// In fr, this message translates to:
  /// **'Conditions'**
  String get terms;

  /// No description provided for @privacy_policy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacy_policy;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @reset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reset;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @success.
  ///
  /// In fr, this message translates to:
  /// **'Succès'**
  String get success;

  /// No description provided for @settings_saved.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres enregistrés'**
  String get settings_saved;

  /// No description provided for @settings_reset.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres réinitialisés'**
  String get settings_reset;

  /// No description provided for @partners.
  ///
  /// In fr, this message translates to:
  /// **'Partenaires'**
  String get partners;

  /// No description provided for @partners_list.
  ///
  /// In fr, this message translates to:
  /// **'Liste des partenaires'**
  String get partners_list;

  /// No description provided for @add_partner.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un partenaire'**
  String get add_partner;

  /// No description provided for @search_partner.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un partenaire...'**
  String get search_partner;

  /// No description provided for @all_partners.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get all_partners;

  /// No description provided for @customers_only.
  ///
  /// In fr, this message translates to:
  /// **'Clients'**
  String get customers_only;

  /// No description provided for @suppliers_only.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseurs'**
  String get suppliers_only;

  /// No description provided for @both_types.
  ///
  /// In fr, this message translates to:
  /// **'Les deux'**
  String get both_types;

  /// No description provided for @total_partners.
  ///
  /// In fr, this message translates to:
  /// **'Total partenaires'**
  String get total_partners;

  /// No description provided for @total_customers.
  ///
  /// In fr, this message translates to:
  /// **'Total clients'**
  String get total_customers;

  /// No description provided for @total_suppliers.
  ///
  /// In fr, this message translates to:
  /// **'Total fournisseurs'**
  String get total_suppliers;

  /// No description provided for @no_partners.
  ///
  /// In fr, this message translates to:
  /// **'Aucun partenaire'**
  String get no_partners;

  /// No description provided for @no_results.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat trouvé'**
  String get no_results;

  /// No description provided for @try_different_search.
  ///
  /// In fr, this message translates to:
  /// **'Essayez une recherche différente'**
  String get try_different_search;

  /// No description provided for @start_adding.
  ///
  /// In fr, this message translates to:
  /// **'Commencez à ajouter des partenaires'**
  String get start_adding;

  /// No description provided for @customer.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get customer;

  /// No description provided for @supplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get supplier;

  /// No description provided for @both.
  ///
  /// In fr, this message translates to:
  /// **'Les deux'**
  String get both;

  /// No description provided for @partner_details.
  ///
  /// In fr, this message translates to:
  /// **'Détails du partenaire'**
  String get partner_details;

  /// No description provided for @export_partners.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get export_partners;

  /// No description provided for @import_partners.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get import_partners;

  /// No description provided for @coming_soon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible...'**
  String get coming_soon;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// No description provided for @error_loading.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get error_loading;

  /// No description provided for @has_debt.
  ///
  /// In fr, this message translates to:
  /// **'Crédit impayé'**
  String get has_debt;

  /// No description provided for @no_debt.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dette'**
  String get no_debt;

  /// No description provided for @debt_amount.
  ///
  /// In fr, this message translates to:
  /// **'Montant de la dette'**
  String get debt_amount;

  /// No description provided for @credit_amount.
  ///
  /// In fr, this message translates to:
  /// **'Solde créditeur'**
  String get credit_amount;

  /// No description provided for @map.
  ///
  /// In fr, this message translates to:
  /// **'Carte'**
  String get map;

  /// No description provided for @my_location.
  ///
  /// In fr, this message translates to:
  /// **'Ma position'**
  String get my_location;

  /// No description provided for @partners_refreshed.
  ///
  /// In fr, this message translates to:
  /// **'Partenaires actualisés'**
  String get partners_refreshed;

  /// No description provided for @navigate.
  ///
  /// In fr, this message translates to:
  /// **'Naviguer'**
  String get navigate;

  /// No description provided for @contact.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @mobile.
  ///
  /// In fr, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address;

  /// No description provided for @full_address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse complète'**
  String get full_address;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @country.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get country;

  /// No description provided for @zip.
  ///
  /// In fr, this message translates to:
  /// **'Code postal'**
  String get zip;

  /// No description provided for @financial.
  ///
  /// In fr, this message translates to:
  /// **'Financier'**
  String get financial;

  /// No description provided for @total_balance.
  ///
  /// In fr, this message translates to:
  /// **'Solde total'**
  String get total_balance;

  /// No description provided for @credit_limit.
  ///
  /// In fr, this message translates to:
  /// **'Limite de crédit'**
  String get credit_limit;

  /// No description provided for @usage.
  ///
  /// In fr, this message translates to:
  /// **'Utilisation'**
  String get usage;

  /// No description provided for @additional_info.
  ///
  /// In fr, this message translates to:
  /// **'Informations supplémentaires'**
  String get additional_info;

  /// No description provided for @vat.
  ///
  /// In fr, this message translates to:
  /// **'TVA'**
  String get vat;

  /// No description provided for @active.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get active;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @call.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get call;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @sales_trend.
  ///
  /// In fr, this message translates to:
  /// **'Tendance des ventes'**
  String get sales_trend;

  /// No description provided for @last_7_days.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours'**
  String get last_7_days;

  /// No description provided for @no_data_available.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée disponible'**
  String get no_data_available;

  /// No description provided for @today_sales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes aujourd\'hui'**
  String get today_sales;

  /// No description provided for @week_sales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes de la semaine'**
  String get week_sales;

  /// No description provided for @month_sales.
  ///
  /// In fr, this message translates to:
  /// **'Ventes du mois'**
  String get month_sales;

  /// No description provided for @orders.
  ///
  /// In fr, this message translates to:
  /// **'commandes'**
  String get orders;

  /// No description provided for @of_target.
  ///
  /// In fr, this message translates to:
  /// **'de l\'objectif'**
  String get of_target;

  /// No description provided for @loading_dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Chargement du tableau de bord...'**
  String get loading_dashboard;

  /// No description provided for @refresh_dashboard.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser le tableau de bord'**
  String get refresh_dashboard;

  /// No description provided for @filter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// No description provided for @apply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get apply;

  /// No description provided for @sort_by.
  ///
  /// In fr, this message translates to:
  /// **'Trier par'**
  String get sort_by;

  /// No description provided for @error_occurred.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite'**
  String get error_occurred;

  /// No description provided for @error_loading_data.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement des données'**
  String get error_loading_data;

  /// No description provided for @no_data_found.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée trouvée'**
  String get no_data_found;

  /// No description provided for @no_items_found.
  ///
  /// In fr, this message translates to:
  /// **'Aucun élément trouvé'**
  String get no_items_found;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @draft.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get draft;

  /// No description provided for @pending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In fr, this message translates to:
  /// **'Confirmé'**
  String get confirmed;

  /// No description provided for @in_progress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get in_progress;

  /// No description provided for @completed.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get completed;

  /// No description provided for @delivered.
  ///
  /// In fr, this message translates to:
  /// **'Livré'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get cancelled;

  /// No description provided for @paid.
  ///
  /// In fr, this message translates to:
  /// **'Payé'**
  String get paid;

  /// No description provided for @unpaid.
  ///
  /// In fr, this message translates to:
  /// **'Impayé'**
  String get unpaid;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @sales_orders.
  ///
  /// In fr, this message translates to:
  /// **'Commandes de vente'**
  String get sales_orders;

  /// No description provided for @search_sales_orders.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher les commandes'**
  String get search_sales_orders;

  /// No description provided for @status.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// No description provided for @new_sale.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle vente'**
  String get new_sale;

  /// No description provided for @items.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get items;

  /// No description provided for @view.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get view;

  /// No description provided for @sale_order.
  ///
  /// In fr, this message translates to:
  /// **'Commande de vente'**
  String get sale_order;

  /// No description provided for @order_info.
  ///
  /// In fr, this message translates to:
  /// **'Informations de commande'**
  String get order_info;

  /// No description provided for @total_amount.
  ///
  /// In fr, this message translates to:
  /// **'Montant total'**
  String get total_amount;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @print.
  ///
  /// In fr, this message translates to:
  /// **'Imprimer'**
  String get print;
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
