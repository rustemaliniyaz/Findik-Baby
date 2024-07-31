import Foundation
import FirebaseFirestore

struct Product: Codable {
    let tarih: Timestamp?
    let evrakNo: String?
    let kod: String?
    let adet: Int?
    let fasonFiyat: Double?
    let fasonaGidisTarihi: Timestamp?
    let fasondanGeliseTarihi: Timestamp?
    let fasondanGelenAdet: Int?
    let citcitGelenAdet: Int?
    let citcitSayisi: Int?
    let citcitTutar: Double?
    let utuFiyat: Double?
    let utuGelenAdet: Int?
    let defolu: Int?
    let eksik: Int?

    enum CodingKeys: String, CodingKey {
        case tarih = "Tarih"
        case evrakNo = "Evrak No"
        case kod = "Kod"
        case adet = "Adet"
        case fasonFiyat = "Fason Fiyat"
        case fasonaGidisTarihi = "Fasona Gidiş Tarihi"
        case fasondanGeliseTarihi = "Fasondan Geliş Tarihi"
        case fasondanGelenAdet = "Fasondan Gelen Adet"
        case citcitGelenAdet = "Çıtçıt Gelen Adet"
        case citcitSayisi = "Çıtçıt Sayısı"
        case citcitTutar = "Çıtçıt Tutar"
        case utuFiyat = "Ütü Fiyat"
        case utuGelenAdet = "Ütü Gelen Adet"
        case defolu = "Defolu"
        case eksik = "Eksik"

    }
}
