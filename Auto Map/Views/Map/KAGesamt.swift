
// KHModel.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let kHModel = try? newJSONDecoder().decode(KHModel.self, from: jsonData)

import Foundation

// MARK: - KHModel
struct KHModel: Codable {
    var kaGesamt: [KAGesamt]
    
    enum CodingKeys: String, CodingKey {
        case kaGesamt = "KA gesamt"
    }
}

// KAGesamt.swift

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let kAGesamt = try? newJSONDecoder().decode(KAGesamt.self, from: jsonData)

import Foundation
import MapKit
import SwiftUI


// MARK: - KAGesamt
struct KAGesamt: Codable {
    var kaNr: String
    var bundesland: Bundesland
    var bezirk: String
    var versorgungszone: Versorgungszone
    var versorgungsregion: String
    var versorgungssektor: Versorgungssektor
    var versorgungsbereich, bezeichnung: String
    var öffentlichkeitsrecht: Öffentlichkeitsrecht
    var gemeinnützigkeit: Gemeinnützigkeit
    var fondszugehörigkeit: Fondszugehörigkeit
    var typGemKAKuG: TypGemKAKuG
    var adresse: String
    var telefon, fax: String?
    var homepage: String?
    var ärztlicherLeiter, pflegedienstleiter: String?
    var verwaltungsdirektor: String
    var bettenanzahl: String?
    var anzahlGeöffneterStandorteSieheAuchRegisterblattStandorteAkutversorgung: String
    var großgeräte: String?
    var trägerNr, trägerBezeichnung, trägerAdresse: String
    var trägerTelefon, trägerFax: String?
    var trägerHomepage: String?
    var intensivbereiche: String?
    
    enum CodingKeys: String, CodingKey {
        case kaNr = "KA-Nr"
        case bundesland = "Bundesland"
        case bezirk = "Bezirk"
        case versorgungszone = "Versorgungszone"
        case versorgungsregion = "Versorgungsregion"
        case versorgungssektor = "Versorgungssektor"
        case versorgungsbereich = "Versorgungsbereich"
        case bezeichnung = "Bezeichnung"
        case öffentlichkeitsrecht = "Öffentlichkeitsrecht"
        case gemeinnützigkeit = "Gemeinnützigkeit"
        case fondszugehörigkeit = "Fondszugehörigkeit"
        case typGemKAKuG = "Typ gem. KAKuG"
        case adresse = "Adresse"
        case telefon = "Telefon"
        case fax = "Fax"
        case homepage = "Homepage"
        case ärztlicherLeiter = "Ärztlicher Leiter"
        case pflegedienstleiter = "Pflegedienstleiter"
        case verwaltungsdirektor = "Verwaltungsdirektor"
        case bettenanzahl = "Bettenanzahl"
        case anzahlGeöffneterStandorteSieheAuchRegisterblattStandorteAkutversorgung = "Anzahl geöffneter Standorte (siehe auch Registerblatt 'Standorte Akutversorgung')"
        case großgeräte = "Großgeräte"
        case trägerNr = "Träger-Nr."
        case trägerBezeichnung = "Träger Bezeichnung"
        case trägerAdresse = "Träger Adresse"
        case trägerTelefon = "Träger Telefon"
        case trägerFax = "Träger Fax"
        case trägerHomepage = "Träger Homepage"
        case intensivbereiche = "Intensivbereiche"
    }
}

extension KAGesamt {
    func coordinates()  {
        let geocoder = CLGeocoder()
        let address = self.adresse
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                return
            }
        }
    }
}

// Bundesland.swift

import Foundation

enum Bundesland: String, Codable {
    case burgenland = "Burgenland"
    case kärnten = "Kärnten"
    case niederösterreich = "Niederösterreich"
    case oberösterreich = "Oberösterreich"
    case salzburg = "Salzburg"
    case steiermark = "Steiermark"
    case tirol = "Tirol"
    case vorarlberg = "Vorarlberg"
    case wien = "Wien"
}

// Fondszugehörigkeit.swift

import Foundation

enum Fondszugehörigkeit: String, Codable {
    case landesfonds = "Landesfonds"
    case prikraf = "PRIKRAF"
    case sonstige = "Sonstige"
}

// Gemeinnützigkeit.swift

import Foundation

enum Gemeinnützigkeit: String, Codable {
    case gemeinnützig = "gemeinnützig"
    case nichtGemeinnützig = "nicht gemeinnützig"
}

// TypGemKAKuG.swift

import Foundation

enum TypGemKAKuG: String, Codable {
    case pflegeanstaltFürChronischKranke = "Pflegeanstalt für chronisch Kranke"
    case sanatorium = "Sanatorium"
    case schwerpunktKA = "Schwerpunkt-KA"
    case sonderKA = "Sonder-KA"
    case standardKA = "Standard-KA"
    case zentralKA = "Zentral-KA"
}

// Versorgungssektor.swift

import Foundation

enum Versorgungssektor: String, Codable {
    case akutversorgung = "Akutversorgung"
    case genesungPrävention = "Genesung/Prävention"
    case langzeitversorgung = "Langzeitversorgung"
    case rehabilitation = "Rehabilitation"
}

// Versorgungszone.swift

import Foundation

enum Versorgungszone: String, Codable {
    case nord = "Nord"
    case ost = "Ost"
    case süd = "Süd"
    case west = "West"
}

// Öffentlichkeitsrecht.swift

import Foundation

enum Öffentlichkeitsrecht: String, Codable {
    case mitÖffentlichkeitsrecht = "mit Öffentlichkeitsrecht"
    case ohneÖffentlichkeitsrecht = "ohne Öffentlichkeitsrecht"
}

// JSONSchemaSupport.swift

import Foundation
