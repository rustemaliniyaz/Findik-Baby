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
    
    func getDataFromFirestore() {
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
                        self.filteredData.sort(by: self.compareStringsAsIntegers)
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
        DataManager.keywordValues.removeAll() 
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
    private func compareStringsAsIntegers(_ str1: String, _ str2: String) -> Bool {
        // Ensure non-numeric values are handled gracefully
        let int1 = Int(str1) ?? Int.max
        let int2 = Int(str2) ?? Int.max
        return int1 < int2
    }

    internal func sortData(by option: String) {
        let isDescending = sortDescending(for: option)
        let sortField = sortField(for: option)

        DataManager.firestoreDatabase.collection("Products")
            .order(by: sortField, descending: isDescending)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                } else {
                    self.productCodes.removeAll()
                    for doc in snapshot?.documents ?? [] {
                        let documentID = doc.documentID
                        self.productCodes.append(documentID)
                    }
                    self.filteredData = self.productCodes
                    self.tableView.reloadData()
                }
            }

    }


        
        private func sortField(for option: String) -> String {
            switch option {
            case "Tarihe göre (önce en yeni)", "Tarihe göre (önce en eski)":
                return "Tarih"
            case "Evrak No'ya göre (yüksekten düşüğe)", "Evrak No'ya göre (düşükten yükseğe)":
                return "Evrak No"
            case "Adet sayısına göre (yüksekten düşüğe)", "Adet sayısına göre (düşükten yükseğe)":
                return "Adet"
            case "Fason fiyatına göre (yüksekten düşüğe)", "Fason fiyatına göre (düşükten yükseğe)":
                return "Fason Fiyat"
            case "Fasona gidiş tarihine göre (önce en yeni)", "Fasona gidiş tarihine göre (önce en eski)":
                return "Fasona Gidiş Tarihi"
            case "Fasondan geliş tarihine göre (önce en yeni)", "Fasondan geliş tarihine göre (önce en eski)":
                return "Fasondan Geliş Tarihi"
            case "Fasondan gelen adet sayısına göre (yüksekten düşüğe)", "Fasondan gelen adet sayısına göre (düşükten yükseğe)":
                return "Fasondan Gelen Adet"
            case "Çıtçıttan gelen adet sayısına göre (yüksekten düşüğe)", "Çıtçıttan gelen adet sayısına göre (düşükten yükseğe)":
                return "Çıtçıt Gelen Adet"
            case "Çıtçıt sayısına göre (yüksekten düşüğe)", "Çıtçıt sayısına göre (düşükten yükseğe)":
                return "Çıtçıt Sayısı"
            case "Çıtçıt tutarına göre (yüksekten düşüğe)", "Çıtçıt tutarına göre (düşükten yükseğe)":
                return "Çıtçıt Tutar"
            case "Ütü fiyatına göre (yüksekten düşüğe)", "Ütü fiyatına göre (düşükten yükseğe)":
                return "Ütü Fiyat"
            case "Ütüden gelen adet sayısına göre (yüksekten düşüğe)", "Ütüden gelen adet sayısına göre (düşükten yükseğe)":
                return "Ütü Gelen Adet"
            case "Defolu sayısına göre (yüksekten düşüğe)", "Defolu sayısına göre (düşükten yükseğe)":
                return "Defolu"
            case "Eksik sayısına göre (yüksekten düşüğe)", "Eksik sayısına göre (düşükten yükseğe)  ":
                return "Eksik"
            default:
                return "Kod"
            }
        }
        
    private func sortDescending(for option: String) -> Bool {
            switch option {
            case "Tarihe göre (önce en yeni)", "Evrak No'ya göre (yüksekten düşüğe)", "Adet sayısına göre (yüksekten düşüğe)", "Fason fiyatına göre (yüksekten düşüğe)", "Fasona gidiş tarihine göre (önce en yeni)", "Fasondan geliş tarihine göre (önce en yeni)", "Fasondan gelen adet sayısına göre (yüksekten düşüğe)", "Çıtçıttan gelen adet sayısına göre (yüksekten düşüğe)", "Çıtçıt sayısına göre (yüksekten düşüğe)", "Çıtçıt tutarına göre (yüksekten düşüğe)", "Ütü fiyatına göre (yüksekten düşüğe)", "Ütüden gelen adet sayısına göre (yüksekten düşüğe)", "Defolu sayısına göre (yüksekten düşüğe)", "Eksik sayısına göre (yüksekten düşüğe)" :
                return true
            default:
                return false
            }
        }

}
