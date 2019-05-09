package assets.texts {
import managers.installer;

public class alerts extends Object {

    /**
     * install Alerts
     */
    alerts["LAUNCH"] = {
    message: "LANCEMENT EN COURS ... ",
        title: "VEUILLEZ PATIENTER"
    };

    alerts["INSTALL_FAILED"] = {
        message: "L'APPLICATION NÉCESSITE UNE CONNEXION INTERNET LORS DE SON PREMIER LANCEMENT.",
        title: "INITIALISATION ANNULÉE",
        //closeButtonTitle: "Quitter"
        closeButtonTitle: "Réesayer"
    };

    alerts["OFFLINE_CONNECTION"] = {
        message: "LANCER QUAND MÊME ?",
        title: "APPLICATION EN MODE OFFLINE",
        closeButtonTitle: "OK"
    };

    alerts["FIRST_LAUNCH"] = {
        message: "L'APPLICATION SE LANCE POUR LA 1ÈRE FOIS",
        title: "INITIALISATION ",
        closeButtonTitle: "INSTALLER"
        //closeButtonTitle: "Réesayer"
    };

    alerts["DDL"] = {
        message: "NEW PRESENTATION : ",
        title: "DOWNLOADING NEW CONTENT"
        //closeButtonTitle: "Quitter"
        //closeButtonTitle: "Réesayer"
    };

    alerts["EXTRACT"] = {
        message: "FOR : ",
        title: "EXTRACTING CONTENT"
        //closeButtonTitle: "Quitter"
        //closeButtonTitle: "Réesayer"
    };


    alerts["CHECK_UPDATE"] = {
        message: "EFFECTUER LA DETECTION DE MISE À JOUR ?",
        title: "MISE À JOURS ",
        closeButtonTitle: "OUI",
        cancelButtonTitle: "NON"
    };

    alerts["UPDATE"] = {
        message: "EFFECTUER LA MISE À JOUR ?",
        title: "MISE À JOURS DISPONIBLE",
        closeButtonTitle: "OUI",
        cancelButtonTitle: "NON"
    };


    /**
     * Authentifications Alerts
     */
    alerts["IOError_AUTH"] = {
        message: "erreur requête login",
        title: "AUTH REQUEST IOERROREVENT",
        closeButtonTitle: "OK"
    };

    alerts["MISSING_LOGIN"] = {
        message: "CHAMP LOGIN MANQUANT.",
        title: "LOGIN MANQUANT",
        closeButtonTitle: "OK"
    };
    alerts["MISSING_PASSWORD"] = {
        message: "CHAMP MOT DE PASSE MANQUANT.",
        title: "MOT DE PASSE MANQUANT",
        closeButtonTitle: "OK"
    };
    alerts["AUTH_FAILED"] = {
        message: "MAUVAIS LOGIN OU MOT DE PASSE.",
        title: "ERREURE D'AUTHENTIFICATION"
        //closeButtonTitle: "OK"
    };


    alerts["IOError_DB"] = {
        message: "erreur requête database ",
        title: "DB REQUEST IOERROREVENT",
        closeButtonTitle: "OK"
    };

    alerts["MAIL_INCORRECT"] = {
        message: "l'adresse mail renseignée est incorrecte",
        title: "E-MAIL INCORRECT",
        closeButtonTitle: "OK"
        //closeButtonTitle: "Réesayer"
    };

    /**
     * Synchronisation Alerts
     */
    alerts["SYNC_ALERT"] = {
        message: "LA SYNCHRONISATION SUPPRIMERA VOS PRÉCÉDENTES...\nVOUS NE POURREZ PLUS LES CONSULTER",
        title: "SYNCHRONISATION",
        closeButtonTitle: "OK",
        cancelButtonTitle: "ANNULER"
    };
    alerts["SYNC_IN"] = {
        message: "SYNCHRONISATION EN COUS\nVEUILLEZ PATIENTER.",
        title: "SYNCHRONISATION"
    };
    alerts["SYNC_OUT"] = {
        message: "SYNCHRONISATION TERMINÉE.",
        title: "SYNCHRONISATION",
        closeButtonTitle: "OK"
    };

    alerts["SESSION_CHECK"] = {
        message: "",
        title: "VÉRIFICATION EN COURS"
    };
}
}
