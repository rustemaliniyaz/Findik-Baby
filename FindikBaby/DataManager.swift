

import Foundation
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

struct DataManager {
    let uuid = UUID().uuidString
    static var documentName = String()
    static var productCode = String()
    static var productData = [String:Any]()
    static var messageText = String()
    static let storage = Storage.storage()
    static let storageReference = storage.reference()
    static let mediaFolder = storageReference.child("media")
    static let imageReference = mediaFolder.child("productImages")
    static let firestoreDatabase = Firestore.firestore()
    static var firestoreReference : DocumentReference? = nil
    static var checkmarkStates = [String: Bool]()
    static var productKey = [String]()
    static var filterValues: [String: (filter1: String, filter2: String)] = [:]
    static func saveFilterValues(for option: String, filter1: String, filter2: String) {
        filterValues[option] = (filter1, filter2)
    }
    static var keywordValues: [String: String] = [:]
    static func saveKeywordValue(for option: String, keyword: String) {
        keywordValues[option] = keyword
    }
    
}


