

import Foundation
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

struct DataManager {
    let uuid = UUID().uuidString
    static let storage = Storage.storage()
    static let storageReference = storage.reference()
    static let mediaFolder = storageReference.child("media")
    static let imageReference = mediaFolder.child("productImages")
    static let firestoreDatabase = Firestore.firestore()
    
    static var documentName = String()
    static var productCode = String()
    static var productData = [String:Any]()
    static var messageText = String()
    static var firestoreReference : DocumentReference? = nil
    static var checkmarkStates = [String: Bool]()
    static var checkmarkStatesForFilters = [String: Bool]()
    static var productKey = [String]()
    static var keywordValues: [String: String] = [:]
    static var filterValues: [String: (filter1: String, filter2: String)] = [:]
    
    static func saveFilterValues(for option: String, filter1: String, filter2: String) {
        filterValues[option] = (filter1, filter2)
    }
    static let elements = [
        "Ürün Fotoğrafı", "Tarih", "Evrak No", "Kod", "Adet", "Açıklama",
        "Aksesuar", "Baskı", "Ense Baskı", "Fason Dikiş", "Operasyon",
        "Fason Fiyat", "Fasona Gidiş Tarihi", "Fasondan Geliş Tarihi",
        "Fasondan Gelen Adet", "Çıtçıt", "Çıtçıt Gelen Adet", "Çıtçıt Sayısı",
        "Çıtçıt Tutar", "Ütü", "Ütü Fiyat", "Ütü Gelen Adet", "Defolu",
        "Parti Devam", "Eksik", "Model Açıklama"]
    
    static let sortingOptions = [
        "Tarihe göre (önce en yeni)", "Tarihe göre (önce en eski)",
        "Evrak No'ya göre (yüksekten düşüğe)", "Evrak No'ya göre (düşükten yükseğe)",
        "Adet sayısına göre (yüksekten düşüğe)", "Adet sayısına göre (düşükten yükseğe)",
        "Fason fiyatına göre (yüksekten düşüğe)", "Fason fiyatına göre (düşükten yükseğe)",
        "Fasona gidiş tarihine göre (önce en yeni)", "Fasona gidiş tarihine göre (önce en eski)",
        "Fasondan geliş tarihine göre (önce en yeni)", "Fasondan geliş tarihine göre (önce en eski)",
        "Fasondan gelen adet sayısına göre (yüksekten düşüğe)", "Fasondan gelen adet sayısına göre (düşükten yükseğe)",
        "Çıtçıttan gelen adet sayısına göre (yüksekten düşüğe)", "Çıtçıttan gelen adet sayısına göre (düşükten yükseğe)", "Çıtçıt sayısına göre (yüksekten düşüğe)", "Çıtçıt sayısına göre (düşükten yükseğe)",
        "Çıtçıt tutarına göre (yüksekten düşüğe)", "Çıtçıt tutarına göre (düşükten yükseğe)",
        "Ütü fiyatına göre (yüksekten düşüğe)", "Ütü fiyatına göre (düşükten yükseğe)",
        "Ütüden gelen adet sayısına göre (yüksekten düşüğe)", "Ütüden gelen adet sayısına göre (düşükten yükseğe)",
        "Defolu sayısına göre (yüksekten düşüğe)", "Defolu sayısına göre (düşükten yükseğe)",
        "Eksik sayısına göre (yüksekten düşüğe)", "Eksik sayısına göre (düşükten yükseğe)"]
}


