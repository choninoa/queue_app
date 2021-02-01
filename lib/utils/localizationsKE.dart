import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LocalizationsKE {
  LocalizationsKE(this.locale);

  final Locale locale;

  static LocalizationsKE of(BuildContext context) {
    return Localizations.of<LocalizationsKE>(context, LocalizationsKE);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'reservaciones': 'Reservations',
      'tiendas': ' stores near you',
      'distancia': 'Distance: ',
      'disponibles': 'Available: ',
      "personas": "People",
      "reservar": "Booking",
      "reservarahora": "Book now",
      "abierto": "Open from: ",
      "to": "to",
      'informacion': 'Personal Info',
      'general': 'General',
      'perfil': 'Profile',
      'privacidad': 'Privacy',
      'cambiarcontrasena': 'Change password',
      'contrasena': 'Password',
      'usuario': 'Username',
      'aceptar': 'Accept',
      'cancelar': 'Cancel',
      'salir': 'Are you sure you want to go out?',
      'reservationsuccess':
          'A reservation has been successfully made for the day ',
      'error': 'Something went wrong.',
      'errordate': 'You must choose a valid date.',
      'todas': 'All',
      'success': 'SUCCESS!!',
      'recuerda': 'Remember',
      'recordatorioreserva': 'Reservation in ',
      'alas': 'at ',
      'todasreservaciones': 'All reservations',
      'recuperarpassword': 'Recover your password?',
      'registrarcuenta': 'Register new account',
      'entrar': 'LOG IN',
      'nombre': 'Fullname',
      'correo': 'Email',
      'telefono': 'Phone',
      'direccion': 'Address',
      'repetircontrasena': 'Repeat password',
      'registrar': "Sign up",
      'anterior': 'Previous',
      'siguiente': 'Next',
      'planificar': 'Schedule',
      'proximaentrada': "Next entry",
      'tiendacerrada': "Store close",
      'hora': "Time: ",
      'buscarestablecimiento': 'Find an establishment...',
      'mostrarruta': "Show Route",
      'navegar': "Navigate Now",
      'otroshorarios': "Other schedules",
      'usuarioenblanco': "You must enter a username.",
      'passwordenblanco': "You must enter a password.",
      'arrivaltime': "Arrival time: ",
      'timetodestination': "Time to destination: ",
      'timeforbooking': "Time for\nbooking: ",
      'booked': "Booked",
      'entry': "Entry",
      'keisfindingyou': "We are finding you",
      'themecolor': "Appearance",
      'search': "Search...",
      'go': "Go",
    },
    'es': {
      'reservaciones': 'Reservaciones',
      'tiendas': 'tiendas cercanas',
      'distancia': 'Distancia: ',
      'disponibles': 'Disponibles: ',
      "personas": "Personas",
      "reservar": "Reservar",
      "abierto": "Abierto desde: ",
      "to": "a ",
      'informacion': 'Información Personal',
      'general': 'General',
      'perfil': 'Mi Perfil',
      'privacidad': 'Privacidad',
      'cambiarcontrasena': 'Cambiar contraseña',
      'contrasena': 'Contraseña',
      'usuario': 'Usuario',
      'aceptar': 'Aceptar',
      'cancelar': 'Cancelar',
      'salir': 'Estás seguro que deseas salir?',
      'reservationsuccess':
          'Se ha realizado con éxito una reservación para el día ',
      'error': 'Ha ocurrido un error.',
      'errordate': 'Debe escoger una fecha válida',
      'todas': 'Todo',
      'success': 'EXITO!!',
      'recuerda': 'Recuerda',
      'recordatorioreserva': 'Reservación en ',
      'alas': 'a las ',
      'todasreservaciones': 'Todas las reservaciones',
      'recuperarpassword': 'Olvidaste tu contraseña?',
      'registrarcuenta': 'Registrar nueva cuenta',
      'entrar': 'ENTRAR',
      'nombre': 'Nombre y apellidos',
      'correo': 'Correo',
      'telefono': 'Teléfono',
      'direccion': 'Dirección',
      'repetircontrasena': 'Repetir la contraseña',
      'registrar': "Registrar",
      'anterior': 'Anterior',
      'siguiente': 'Siguiente',
      'planificar': 'Planificar',
      'proximaentrada': "Próxima entrada",
      'tiendacerrada': "Tienda Cerrada",
      'hora': "Horario: ",
      'buscarestablecimiento': 'Buscar establecimiento...',
      'mostrarruta': "Mostrar Ruta",
      'navegar': "Navegar ahora",
      'otroshorarios': "Otros horarios",
      'usuarioenblanco': "Debes introducir un nombre de usuario.",
      'passwordenblanco': "Debes introducir una contraseña.",
      'arrivaltime': "Hora de llegada: ",
      'timetodestination': "Tiempo en llegar: ",
      'timeforbooking': "Tiempo para\nreservar: ",
      'booked': "Reservado",
      'entry': "Entrar",
      'keisfindingyou': "Estamos localizandote",
      'themecolor': "Apariencia",
      'search': "Buscar...",
      "reservarahora": "Reservar ahora",
      'go': "Ir",
    },
    'fr': {
      'reservaciones': 'Réservations',
      'tiendas': 'commerces à proximité',
      'distancia': 'Distance: ',
      'disponibles': 'Disponible: ',
      "personas": "Personnes",
      "reservar": "Reserver",
      "abierto": "Ouvert de: ",
      "to": "à ",
      'informacion': 'Information personnelle',
      'general': 'Général',
      'perfil': 'Profil',
      'privacidad': 'Confidentialité',
      'cambiarcontrasena': 'Changer le mot de passe',
      'contrasena': 'Mot de passe',
      'usuario': 'Utilisateur',
      'aceptar': 'Accepter',
      'cancelar': 'Annuler',
      'salir': 'Êtes-vous sûr de vouloir sortir?',
      'reservationsuccess':
          'Une réservation a été effectuée avec succès pour la journée du ',
      'error': 'Un problème est survenu. ',
      'errordate': 'Vous devez choisir une date valide.',
      'todas': 'Tout',
      'success': 'SUCCÈS!!',
      'recuerda': 'Rappel',
      'recordatorioreserva': 'Réservation à ',
      'alas': 'à ',
      'todasreservaciones': 'Toutes les réservations',
      'recuperarpassword': 'Récupérer le mot de passe?',
      'registrarcuenta': 'Enregistrer un nouveau compte',
      'entrar': 'ACCÉDER',
      'nombre': 'Nom complet',
      'correo': 'Email',
      'telefono': 'Téléphone',
      'direccion': 'Adresse',
      'repetircontrasena': 'Répéter le mot de passe',
      'registrar': "S'inscrire",
      'anterior': 'Précédent',
      'siguiente': 'Suivant',
      'planificar': 'Planifier',
      'proximaentrada': "Prochaine entrée: ",
      'tiendacerrada': "Boutique fermée",
      'hora': "Programme: ",
      'buscarestablecimiento': 'Trouver un établissement...',
      'mostrarruta': "Montrer l'itinéraire",
      'navegar': "Naviguez Maintenant",
      'otroshorarios': "Autres horaires",
      'usuarioenblanco': "Vous devez entrer un nom d'utilisateur.",
      'passwordenblanco': "Vous devez entrer un mot de passe.",
      'arrivaltime': "Heure d'arrivée: ",
      'timetodestination': "Temps à destination: ",
      'timeforbooking': "L'heure de\nla réservation: ",
      'booked': "Réservée",
      'entry': "Entrée",
      'keisfindingyou': "Nous te trouvons",
      'themecolor': "Apparence",
      'search': "Chercher...",
      'reservarahora': "Réservez maintenant",
      'go': "Aller",
    },
  };

  String get go {
    return _localizedValues[locale.languageCode]['go'];
  }


  String get reservarahora {
    return _localizedValues[locale.languageCode]['reservarahora'];
  }

  String get search {
    return _localizedValues[locale.languageCode]['search'];
  }

  String get themecolor {
    return _localizedValues[locale.languageCode]['themecolor'];
  }

  String get keisfindingyou {
    return _localizedValues[locale.languageCode]['keisfindingyou'];
  }

  String get booked {
    return _localizedValues[locale.languageCode]['booked'];
  }

  String get entry {
    return _localizedValues[locale.languageCode]['entry'];
  }

  String get arrivaltime {
    return _localizedValues[locale.languageCode]['arrivaltime'];
  }

  String get timeforbooking {
    return _localizedValues[locale.languageCode]['timeforbooking'];
  }

  String get timetodestination {
    return _localizedValues[locale.languageCode]['timetodestination'];
  }

  String get navegar {
    return _localizedValues[locale.languageCode]['navegar'];
  }

  String get otroshorarios {
    return _localizedValues[locale.languageCode]['otroshorarios'];
  }

  String get usuarioenblanco {
    return _localizedValues[locale.languageCode]['usuarioenblanco'];
  }

  String get passwordenblanco {
    return _localizedValues[locale.languageCode]['passwordenblanco'];
  }

  String get mostrarruta {
    return _localizedValues[locale.languageCode]['mostrarruta'];
  }

  String get buscarestablecimiento {
    return _localizedValues[locale.languageCode]['buscarestablecimiento'];
  }

  String get tiendacerrada {
    return _localizedValues[locale.languageCode]['tiendacerrada'];
  }

  String get hora {
    return _localizedValues[locale.languageCode]['hora'];
  }

  String get planificar {
    return _localizedValues[locale.languageCode]['planificar'];
  }

  String get proximaentrada {
    return _localizedValues[locale.languageCode]['proximaentrada'];
  }

  String get anterior {
    return _localizedValues[locale.languageCode]['anterior'];
  }

  String get siguiente {
    return _localizedValues[locale.languageCode]['siguiente'];
  }

  String get registrar {
    return _localizedValues[locale.languageCode]['registrar'];
  }

  String get nombre {
    return _localizedValues[locale.languageCode]['nombre'];
  }

  String get correo {
    return _localizedValues[locale.languageCode]['correo'];
  }

  String get telefono {
    return _localizedValues[locale.languageCode]['telefono'];
  }

  String get direccion {
    return _localizedValues[locale.languageCode]['direccion'];
  }

  String get repetircontrasena {
    return _localizedValues[locale.languageCode]['repetircontrasena'];
  }

  String get entrar {
    return _localizedValues[locale.languageCode]['entrar'];
  }

  String get recuperarpassword {
    return _localizedValues[locale.languageCode]['recuperarpassword'];
  }

  String get registrarcuenta {
    return _localizedValues[locale.languageCode]['registrarcuenta'];
  }

  String get usuario {
    return _localizedValues[locale.languageCode]['usuario'];
  }

  String get contrasena {
    return _localizedValues[locale.languageCode]['contrasena'];
  }

  String get todasreservaciones {
    return _localizedValues[locale.languageCode]['todasreservaciones'];
  }

  String get recuerda {
    return _localizedValues[locale.languageCode]['recuerda'];
  }

  String get recordatorioreserva {
    return _localizedValues[locale.languageCode]['recordatorioreserva'];
  }

  String get alas {
    return _localizedValues[locale.languageCode]['alas'];
  }

  String get success {
    return _localizedValues[locale.languageCode]['success'];
  }

  String get error {
    return _localizedValues[locale.languageCode]['error'];
  }

  String get errordate {
    return _localizedValues[locale.languageCode]['errordate'];
  }

  String get todas {
    return _localizedValues[locale.languageCode]['todas'];
  }

  String get reservationsuccess {
    return _localizedValues[locale.languageCode]['reservationsuccess'];
  }

  String get salir {
    return _localizedValues[locale.languageCode]['salir'];
  }

  String get aceptar {
    return _localizedValues[locale.languageCode]['aceptar'];
  }

  String get cancelar {
    return _localizedValues[locale.languageCode]['cancelar'];
  }

  String get reservaciones {
    return _localizedValues[locale.languageCode]['reservaciones'];
  }

  String get tiendas {
    return _localizedValues[locale.languageCode]['tiendas'];
  }

  String get distancia {
    return _localizedValues[locale.languageCode]['distancia'];
  }

  String get disponibles {
    return _localizedValues[locale.languageCode]['disponibles'];
  }

  String get personas {
    return _localizedValues[locale.languageCode]['personas'];
  }

  String get reservar {
    return _localizedValues[locale.languageCode]['reservar'];
  }

  String get abierto {
    return _localizedValues[locale.languageCode]['abierto'];
  }

  String get to {
    return _localizedValues[locale.languageCode]['to'];
  }

  String get informacion {
    return _localizedValues[locale.languageCode]['informacion'];
  }

  String get general {
    return _localizedValues[locale.languageCode]['general'];
  }

  String get perfil {
    return _localizedValues[locale.languageCode]['perfil'];
  }

  String get privacidad {
    return _localizedValues[locale.languageCode]['privacidad'];
  }

  String get cambiarcontrasena {
    return _localizedValues[locale.languageCode]['cambiarcontrasena'];
  }
}

class LocalizationsKEDelegate extends LocalizationsDelegate<LocalizationsKE> {
  const LocalizationsKEDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  Future<LocalizationsKE> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<LocalizationsKE>(LocalizationsKE(locale));
  }

  @override
  bool shouldReload(LocalizationsKEDelegate old) => false;
}
