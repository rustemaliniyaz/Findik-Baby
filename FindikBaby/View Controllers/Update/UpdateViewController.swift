import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore


class UpdateViewController: UIViewController {

    private var productCodes = [String]()
    private var filteredData = [String]()
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Kod Giriniz"
        searchBar.sizeToFit()
        return searchBar
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.allowsSelection = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.backButtonTitle = "Geri Dön"
        getDataFromFirestore()
        tableView.tableHeaderView = searchBar
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredData.removeAll()
        tableView.reloadData()
    }
    
    private func getDataFromFirestore() {
        DataManager.firestoreDatabase.collection("Products").addSnapshotListener { snapshot, error in
            if error != nil {
                print("Error fetching data: \(error!.localizedDescription)")
            } else {
                if let snapshot = snapshot, !snapshot.isEmpty {
                    self.productCodes.removeAll()
                    for doc in snapshot.documents {
                        let documentID = doc.documentID
                        self.productCodes.append(documentID)
                    }
                    self.filteredData.removeAll()
                    self.tableView.reloadData()
                }
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

extension UpdateViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = filteredData[indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DataManager.documentName = filteredData[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(ShowUpdateableDetailsViewController(), animated: true)
    }
}

extension UpdateViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData.removeAll()
        } else {
            filteredData = productCodes.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
}
extension UpdateViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}
