

import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class AddProductViewController: UIViewController {

    let db = Firestore.firestore()
    
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
    
    let categories = DataManager.elements
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.backButtonTitle = "Vazgeç"
        setupNavigationBar()
        initializeCheckmarkStates()
        
    }
    
    private func initializeCheckmarkStates() {
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
    
    private func setupNavigationBar() {
            let clearButton = UIBarButtonItem(title: "Temizle", style: .plain, target: self, action: #selector(clearButtonAction))
            navigationItem.rightBarButtonItem = clearButton
        }
        
    @objc private func clearButtonAction() {
        DataManager.productData.removeAll()
        for key in DataManager.checkmarkStates.keys {
            DataManager.checkmarkStates[key] = false
        }
        tableView.reloadData()
    }
    @objc func saveButtonActionForProduct() {
        
        if DataManager.productData["Kod"] == nil {
                makeAlert(titleInput: "Kod Bulunamadı", messageInput: "Kod eklemeden ürün kaydı yapılamaz.")
                return
            }
        
        let productsRef = db.collection("Products")
        let documentID = (DataManager.productData["Kod"] as! String)
        productsRef.document(documentID).setData(DataManager.productData)

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
    
    
}


extension AddProductViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let clearAction = UIContextualAction(style: .destructive, title: "Temizle") { (action, view, completionHandler) in
                if DataManager.productData[self.categories[indexPath.row]] != nil {
                    DataManager.productData.removeValue(forKey: self.categories[indexPath.row])
                    DataManager.checkmarkStates[self.categories[indexPath.row]] = false
                    self.tableView.reloadData()
                }
                completionHandler(true)
            }
            clearAction.backgroundColor = .systemRed
            
            let configuration = UISwipeActionsConfiguration(actions: [clearAction])
            configuration.performsFirstActionWithFullSwipe = false
            return configuration
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
