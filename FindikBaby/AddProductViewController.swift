

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class AddProductViewController: UIViewController {

    let db = Firestore.firestore()
    static var checkmarkStates = [String: Bool]()
    var accessoryType : UITableViewCell.AccessoryType = .none
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        return tableView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("Kaydet", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = button.titleLabel?.font.withSize(20)
        button.addTarget(self, action: #selector(saveButtonActionForProduct), for: .touchUpInside)
        return button
    }()
    
    let categories = [
        "Ürün Fotoğrafı", "Tarih", "Evrak No", "Kod", "Adet", "Açıklama", "Aksesuar", "Baskı", "Ense Baskı", "Fason Dikiş", "Operasyon", "Fason Fiyat", "Fasona Gidiş Tarihi", "Fasondan Geliş Tarihi", "Fasondan Gelen Adet", "Çıtçıt", "Çıtçıt Gelen Adet", "Çıtçıt Sayısı", "Çıtçıt Tutar", "Ütü", "Ütü Fiyat", "Ütü Gelen Adet", "Defolu", "Parti Devam", "Eksik", "Model Açıklama"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.backButtonTitle = "Vazgeç"
        for category in categories {
                    if DataManager.checkmarkStates[category] == nil {
                        DataManager.checkmarkStates[category] = false
                    }
                }
        
    }
    
    
    
    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        view.addSubview(saveButton)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5)
        ])
    }
}


extension AddProductViewController: UITableViewDelegate, UITableViewDataSource {
    
    @objc func saveButtonActionForProduct() {
        
        if DataManager.productData["Kod"] == nil || (DataManager.productData["Kod"] as? String ?? "").isEmpty {
                makeAlert(titleInput: "Kod Bulunamadı", messageInput: "Kod eklemeden ürün kaydı yapılamaz.")
                return
            }
        
        let productsRef = db.collection("Products")
        productsRef.document(DataManager.productData["Kod"] as! String).setData(DataManager.productData)
        DataManager.productData.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            for key in DataManager.checkmarkStates.keys {
                        DataManager.checkmarkStates[key] = false
                    }
                    self.tableView.reloadData()
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = categories[indexPath.row]
        cell.contentConfiguration = content
        if DataManager.checkmarkStates[categories[indexPath.row]] == true {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataManager.messageText = categories[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        let addContentVC = AddContentViewController()
        addContentVC.delegate = self
        navigationController?.pushViewController(addContentVC, animated: true)
    }

}

protocol AddContentViewControllerDelegate: AnyObject {
    func didUpdateContent(for category: String)
}

extension AddProductViewController: AddContentViewControllerDelegate {
    func didUpdateContent(for category: String) {
            DataManager.checkmarkStates[category] = true
            tableView.reloadData()
        }
}
