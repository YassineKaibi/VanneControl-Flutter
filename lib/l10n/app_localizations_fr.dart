// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'VanneControl';

  @override
  String get appSubtitle => 'Gérez facilement vos vannes à distance.';

  @override
  String get getStarted => 'Commencer';

  @override
  String get loginTitle => 'Connexion';

  @override
  String get emailHint => 'Adresse e-mail';

  @override
  String get passwordHint => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get noAccount => 'Vous n\'avez pas de compte ? Inscrivez-vous';

  @override
  String get loginError => 'Échec de la connexion. Vérifiez vos identifiants.';

  @override
  String get loginSuccess => 'Connexion réussie !';

  @override
  String get loggingIn => 'Connexion en cours...';

  @override
  String get registering => 'Inscription en cours...';

  @override
  String get emailRequired => 'L\'email est requis';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get firstNameHint => 'Prénom';

  @override
  String get lastNameHint => 'Nom';

  @override
  String get phoneHint => 'Téléphone';

  @override
  String get confirmPasswordHint => 'Confirmer le mot de passe';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get haveAccount => 'Vous avez déjà un compte ? Connectez-vous';

  @override
  String get registrationSuccess => 'Inscription réussie !';

  @override
  String get registrationError => 'Échec de l\'inscription. Réessayez.';

  @override
  String get errorFirstNameRequired => 'Le prénom est requis';

  @override
  String get errorFirstNameTooShort => 'Prénom trop court (min. 2 caractères)';

  @override
  String get errorLastNameRequired => 'Le nom est requis';

  @override
  String get errorLastNameTooShort => 'Nom trop court (min. 2 caractères)';

  @override
  String get errorEmailRequired => 'L\'email est requis';

  @override
  String get errorEmailInvalid => 'Format d\'email invalide';

  @override
  String get errorPhoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get errorPhoneInvalid =>
      'Numéro de téléphone invalide (min. 8 chiffres)';

  @override
  String get errorPasswordRequired => 'Le mot de passe est requis';

  @override
  String get errorPasswordTooShort =>
      'Mot de passe trop court (min. 6 caractères)';

  @override
  String get errorConfirmPasswordRequired => 'Confirmation requise';

  @override
  String get errorPasswordsNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get welcome => 'Bienvenue sur';

  @override
  String get controlPanel => 'Panneau de contrôle';

  @override
  String get activeValves => 'Vannes actives';

  @override
  String get controlModules => 'Modules de contrôle';

  @override
  String get valveManagement => 'Gestion des vannes';

  @override
  String get valveManagementDescription => 'Gestion complète des vannes';

  @override
  String get valveOperationHistory => 'Historique des opérations';

  @override
  String get valveOperationHistoryDescription =>
      'Journaux détaillés d\'activation';

  @override
  String get usageStatistics => 'Statistiques d\'utilisation';

  @override
  String get usageStatisticsDescription => 'Rapports d\'utilisation détaillés';

  @override
  String get alertsAndNotifications => 'Alertes et notifications';

  @override
  String get alertsAndNotificationsDescription =>
      'Consulter la télémétrie et alertes';

  @override
  String get history => 'Historique';

  @override
  String get statistics => 'Statistiques';

  @override
  String get profile => 'Profil';

  @override
  String get valve => 'Vanne';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get noActiveValves => 'Aucune vanne active';

  @override
  String get valveManagementTitle => 'Gestion des vannes';

  @override
  String get controlValves => 'Contrôlez vos vannes';

  @override
  String get valveStateChanged => 'État de la vanne modifié avec succès';

  @override
  String get valveStateError =>
      'Échec de la modification de l\'état de la vanne';

  @override
  String get confirmAction => 'Confirmer l\'action';

  @override
  String get confirmOpen => 'Voulez-vous ouvrir cette vanne ?';

  @override
  String get confirmClose => 'Voulez-vous fermer cette vanne ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get cancel => 'Annuler';

  @override
  String get open => 'Ouvrir';

  @override
  String get closeValve => 'Fermer';

  @override
  String get opened => 'Ouverte';

  @override
  String get closed => 'Fermée';

  @override
  String get historyTitle => 'Historique des opérations';

  @override
  String get filterHistory => 'Filtrer l\'historique';

  @override
  String get selectValves => 'Sélectionner les vannes';

  @override
  String get actionType => 'Type d\'action :';

  @override
  String get openings => 'Ouvertures';

  @override
  String get closings => 'Fermetures';

  @override
  String get period => 'Période :';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get clearFilters => 'Effacer';

  @override
  String get applyFilters => 'Appliquer';

  @override
  String get noHistory => 'Aucun historique trouvé';

  @override
  String get noHistoryDescription =>
      'L\'historique des opérations de vannes apparaîtra ici';

  @override
  String get loading => 'Chargement...';

  @override
  String get statisticsTitle => 'Statistiques d\'utilisation';

  @override
  String get exportPdf => 'PDF';

  @override
  String get overview => 'Aperçu';

  @override
  String get totalValves => 'Total des vannes';

  @override
  String get activeNow => 'Actives maintenant';

  @override
  String get inactiveValves => 'Inactives';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get activationTimeline => 'Chronologie d\'activation';

  @override
  String get valveSelection => 'Sélection de vanne';

  @override
  String get selectValvesChart => 'Sélectionner les vannes à visualiser';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get exportSuccess => 'PDF exporté avec succès';

  @override
  String get exportError => 'Échec de l\'exportation du PDF';

  @override
  String get profileTitle => 'Mon Profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Téléphone';

  @override
  String get location => 'Localisation';

  @override
  String get system => 'Système';

  @override
  String get numberOfControlledValves => 'Nombre de vannes contrôlées';

  @override
  String valvesToManage(int count) {
    return '$count vannes à gérer';
  }

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get language => 'Langue';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get languageChanged => 'Langue modifiée avec succès';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get about => 'À propos';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsConditions => 'Conditions générales';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get back => 'Retour';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get timingPlan => 'Plan de programmation';

  @override
  String get timingPlanDescription => 'Gérer les horaires des vannes';

  @override
  String get noSchedules => 'Aucune programmation';

  @override
  String get tapAddSchedule =>
      'Appuyez sur Ajouter pour créer votre première programmation';

  @override
  String get scheduleName => 'Nom de la programmation';

  @override
  String get selectValve => 'Sélectionner une vanne';

  @override
  String get repeat => 'Répétition';

  @override
  String get once => 'Une fois';

  @override
  String get everyday => 'Tous les jours';

  @override
  String get weekdays => 'Jours de semaine';

  @override
  String get weekends => 'Week-ends';

  @override
  String get custom => 'Personnalisé';

  @override
  String get timedOn => 'ON';

  @override
  String get timedOff => 'OFF';

  @override
  String get scheduleSaved => 'Programmation enregistrée';

  @override
  String get scheduleDeleted => 'Programmation supprimée';

  @override
  String get deleteSchedule => 'Supprimer la programmation';

  @override
  String get deleteScheduleConfirm =>
      'Êtes-vous sûr de vouloir supprimer cette programmation ?';

  @override
  String get todoImplement => 'TODO: implémenter';

  @override
  String get chartPlaceholder => 'Espace réservé au graphique';

  @override
  String get all => 'Tout';

  @override
  String get activated => 'Activé';

  @override
  String get deactivated => 'Désactivé';

  @override
  String get totalEvents => 'Total des événements';

  @override
  String get schedulingTitle => 'Programmation';

  @override
  String resultCount(int shown, int total) {
    return '$shown résultat(s) sur $total';
  }

  @override
  String get by => 'Par :';

  @override
  String get changeProfilePhoto => 'Changer la photo de profil';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get removePhoto => 'Supprimer la photo';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get contactInformation => 'Coordonnées';

  @override
  String get valveSettings => 'Paramètres des vannes';

  @override
  String get profileSaved => 'Profil enregistré avec succès';

  @override
  String get numberOfValves => 'Nombre de vannes (1-8)';

  @override
  String get connected => 'Connecté';

  @override
  String get disconnected => 'Déconnecté';

  @override
  String get connectionStatus => 'État de la connexion';

  @override
  String get pistonStatus => 'État du piston';

  @override
  String get pistonOpen => 'Piston ouvert';

  @override
  String get pistonClosed => 'Piston fermé';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get sinceBeginning => 'Depuis le début';

  @override
  String get period7Days => '7 derniers jours';

  @override
  String get period30Days => '30 derniers jours';

  @override
  String get connectionError =>
      'Impossible de contacter le serveur. Vérifiez votre connexion.';

  @override
  String get useCurrentLocation => 'Utiliser la position actuelle';

  @override
  String get locationPermissionDenied => 'Permission de localisation refusée';

  @override
  String get locationError => 'Impossible d\'obtenir la position. Réessayez.';

  @override
  String get navigateTo => 'Naviguer vers le chantier';
}
