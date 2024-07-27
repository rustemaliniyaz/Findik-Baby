import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

class ShowUpdateableDetailsViewController: UIViewController {

    let db = Firestore.firestore()
    var liste = [String]()
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }

    var keysList = [
       "Ürün Fotoğrafı", "Tarih", "Evrak No", "Kod", "Adet", "Açıklama", "Aksesuar", "Baskı", "Ense Baskı", "Fason Dikiş", "Operasyon", "Fason Fiyat", "Fasona Gidiş Tarihi", "Fasondan Geliş Tarihi", "Fasondan Gelen Adet", "Çıtçıt", "Çıtçıt Gelen Adet", "Çıtçıt Sayısı", "Çıtçıt Tutar", "Ütü", "Ütü Fiyat", "Ütü Gelen Adet", "Defolu", "Parti Devam", "Eksik", "Model Açıklama"]
    
    func getData() {
        let docRef = db.document("Products/\(DataManager.documentName)")
        
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            self.liste = []
            for key in self.keysList {
                self.liste.append(data[key] as? String ?? "")
            }
            self.tableView.reloadData()
        }
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ShowUpdateableDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liste.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.alignment = .center
        
        if keysList[indexPath.row] == "Ürün Fotoğrafı" {
            let text = liste[indexPath.row].isEmpty ? "Fotoğraf Yok" : "Fotoğraf Var"
            let textColor: UIColor = liste[indexPath.row].isEmpty ? .red : .systemGreen
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor]
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            content.attributedText = attributedText
        } else {
            content.text = liste[indexPath.row]
        }
        content.secondaryText = "(\(keysList[indexPath.row]))"
        content.textProperties.alignment = .natural
        cell.contentConfiguration = content
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataManager.messageText = keysList[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        let updateContentVC = UpdateContentViewController()
        updateContentVC.delegate = self
        navigationController?.pushViewController(updateContentVC, animated: true)
    }
}

extension ShowUpdateableDetailsViewController: UpdateContentViewControllerDelegate {
    func updateContentViewControllerDidSave(text: String, forMessageText messageText: String) {
        if let index = keysList.firstIndex(of: messageText) {
            liste[index] = text
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}