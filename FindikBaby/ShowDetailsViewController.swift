import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class ShowDetailsViewController: UIViewController {

    let db = Firestore.firestore()
    var liste = [Any]() // Changed to [Any]
    var keysList = [Any]() // Changed to [Any]
    var chosenIndex = String()
    
    private var productKeys = [String]()
    private var productValues = [String]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.backButtonTitle = "Geri Dön"
        self.title = "Ürün Detayları"
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    let categories = [
        "Ürün Fotoğrafı", "Tarih", "Evrak No", "Kod", "Adet", "Açıklama", "Aksesuar", "Baskı", "Ense Baskı", "Fason Dikiş", "Operasyon", "Fason Fiyat", "Fasona Gidiş Tarihi", "Fasondan Geliş Tarihi", "Fasondan Gelen Adet", "Çıtçıt", "Çıtçıt Gelen Adet", "Çıtçıt Sayısı", "Çıtçıt Tutar", "Ütü", "Ütü Fiyat", "Ütü Gelen Adet", "Defolu", "Parti Devam", "Eksik", "Model Açıklama"
    ]
    
    func getData() {
            let docRef = db.document("Products/\(DataManager.documentName)")
            docRef.getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else { return }
                for key in self.categories {
                    if let value = data[key] {
                        if key == "Tarih" || key == "Fasona Gidiş Tarihi" || key == "Fasondan Geliş Tarihi" {
                            if let timestamp = value as? Timestamp {
                                let date = timestamp.dateValue()
                                self.liste.append(date) // Append Date
                            }
                        } else {
                            self.liste.append(value) // Append Any type
                        }
                        self.keysList.append(key)
                    }
                }
                self.tableView.reloadData()
            }
        }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ShowDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liste.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.textProperties.alignment = .center
            content.secondaryText = keysList[indexPath.row] as? String // Cast to String

            // Handle different types of data
            if let value = liste[indexPath.row] as? String {
                content.text = value
            } else if let value = liste[indexPath.row] as? Int {
                content.text = String(value)
            } else if let value = liste[indexPath.row] as? Float {
                content.text = String(value) // Format float with 2 decimal places
            } else if let value = liste[indexPath.row] as? Date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                content.text = formatter.string(from: value)
            } else {
                content.text = "Unknown Type"
            }

            if content.secondaryText == "Ürün Fotoğrafı" {
                content.text = "TIKLAYINIZ"
                content.textProperties.color = .systemBlue
            }
            
            cell.contentConfiguration = content

            return cell
        }

    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.alignment = .center
        content.secondaryText = keysList[indexPath.row] as? String // Cast to String
        if content.secondaryText == "Ürün Fotoğrafı" {
            let showPictureVC = ShowPictureViewController()
            navigationController?.pushViewController(showPictureVC, animated: true)
            
            return indexPath
        } else {
            return nil
        }
    }
}
