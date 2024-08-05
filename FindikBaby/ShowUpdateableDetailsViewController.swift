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

    var keysList = DataManager.elements
    
    func getData() {
        let docRef = db.document("Products/\(DataManager.documentName)")
        
        docRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.liste = []
            for key in self.keysList {
                if let value = data[key] {
                    switch value {
                    case let intValue as Int:
                        self.liste.append(String(intValue))
                    case let floatValue as Float:
                        self.liste.append(String(format: "%.2f", floatValue))
                    case let dateValue as Timestamp:
                        let date = dateValue.dateValue()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .short
                        dateFormatter.locale = Locale(identifier: "tr_TR")
                        self.liste.append(dateFormatter.string(from: date))
                    default:
                        self.liste.append(String(describing: value))
                    }
                } else {
                    self.liste.append("")
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        
        let key = keysList[indexPath.row]
        let value = liste[indexPath.row]
        
        if key == "Ürün Fotoğrafı" {
            let text = value.isEmpty ? "Fotoğraf Yok" : "Fotoğraf Var"
            let textColor: UIColor = value.isEmpty ? .red : .systemGreen
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor]
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            content.attributedText = attributedText
        } else {
            content.text = value
        }
        
        content.secondaryText = "(\(key))"
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
    func updateContentViewControllerDidSave(text: Any, forMessageText messageText: String) {
        if let index = keysList.firstIndex(of: messageText) {
            liste[index] = text as! String
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
