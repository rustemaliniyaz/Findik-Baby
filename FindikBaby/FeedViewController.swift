import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FeedViewController: UIViewController {

    private var productCodes = [String]()
    private var filteredData: [String]!
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
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()
    
    private var navController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        filteredData = productCodes
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.backButtonTitle = "Geri Dön"
        getDataFromFirestore()
        tableView.tableHeaderView = searchBar
        setupNavigationItems()
    }
    
    private func getDataFromFirestore() {
        DataManager.firestoreDatabase.collection("Products")
            .order(by: "Kod")
            .addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
            } else {
                if snapshot?.isEmpty != true {
                    self.productCodes.removeAll(keepingCapacity: false)
                    for doc in snapshot!.documents {
                        let documentID = doc.documentID
                        self.productCodes.append(documentID)
                    }
                    self.filteredData = self.productCodes
                    self.filteredData.sort(by: { (kod1, kod2) -> Bool in
                        return kod1 < kod2
                    })
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
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNavigationItems() {
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(sortButtonTapped))
        let filterButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease"), style: .plain, target: self, action: #selector(filterButtonTapped))
        navigationItem.rightBarButtonItems = [sortButton, filterButton]
    }
    
    @objc private func sortButtonTapped() {
        let sortVC = SortViewController()
        sortVC.delegate = self
        presentPopupViewController(sortVC)
    }
    
    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        presentPopupViewController(filterVC)
    }
    
    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    private func presentPopupViewController(_ viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        dimmingView.frame = window.frame
        window.addSubview(dimmingView)
        
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .overFullScreen
        
        window.addSubview(navController.view)
        navController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navController.view.topAnchor.constraint(equalTo: window.topAnchor, constant: window.frame.height * 0.2),
            navController.view.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: window.frame.width * 0.1),
            navController.view.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -window.frame.width * 0.1),
            navController.view.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: -window.frame.height * 0.1)
        ])
        
        navController.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        navController.view.alpha = 0
        dimmingView.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            navController.view.alpha = 1
            self.dimmingView.alpha = 1
            navController.view.transform = CGAffineTransform.identity
        })
        
        self.navController = navController
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopupView))
        dimmingView.addGestureRecognizer(tapGesture)
    }

    
    @objc func dismissPopupView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.navController?.view.alpha = 0
            self.dimmingView.alpha = 0
            self.navController?.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            self.navController?.view.removeFromSuperview()
            self.dimmingView.removeFromSuperview()
            self.navController = nil
        }
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        navigationController?.pushViewController(ShowDetailsViewController(), animated: true)
    }
}

extension FeedViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData = productCodes
        } else {
            filteredData = productCodes.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }
}

extension FeedViewController: PopupViewControllerDelegate {
    func dismissPopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.navController?.view.alpha = 0
            self.dimmingView.alpha = 0
            self.navController?.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            self.navController?.view.removeFromSuperview()
            self.dimmingView.removeFromSuperview()
            self.navController = nil
        }
    }
}
