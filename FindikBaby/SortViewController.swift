import UIKit
import FirebaseFirestore
import FirebaseCore



class SortViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: PopupViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    let sortOptions = [ "Tarihe göre (önce en yeni)", "Tarihe göre (önce en eski)",
        "Evrak No'ya göre (yüksekten düşüğe)", "Evrak No'ya göre (düşükten yükseğe)",
        "Adet sayısına göre (yüksekten düşüğe)", "Adet sayısına göre (düşükten yükseğe)",
        "Fason fiyatına göre (yüksekten düşüğe)", "Fason fiyatına göre (düşükten yükseğe)",
        "Fasona gidiş tarihine göre (önce en yeni)", "Fasona gidiş tarihine göre (önce en eski)",
        "Fasondan geliş tarihine göre (önce en yeni)", "Fasondan geliş tarihine göre (önce en eski)",
        "Fasondan gelen adet sayısına göre (yüksekten düşüğe)", "Fasondan gelen adet sayısına göre (düşükten yükseğe)",
        "Çıtçıttan gelen adet sayısına göre (yüksekten düşüğe)", "Çıtçıttan gelen adet sayısına göre (düşükten yükseğe)",
        "Çıtçıt sayısına göre (yüksekten düşüğe)", "Çıtçıt sayısına göre (düşükten yükseğe)",
        "Çıtçıt tutarına göre (yüksekten düşüğe)", "Çıtçıt tutarına göre (düşükten yükseğe)",
        "Ütü fiyatına göre (yüksekten düşüğe)", "Ütü fiyatına göre (düşükten yükseğe)",
        "Ütüden gelen adet sayısına göre (yüksekten düşüğe)", "Ütüden gelen adet sayısına göre (düşükten yükseğe)",
        "Defolu sayısına göre (yüksekten düşüğe)", "Defolu sayısına göre (düşükten yükseğe)",
        "Eksik sayısına göre (yüksekten düşüğe)", "Eksik sayısına göre (düşükten yükseğe)"
    ]
    
    var selectedSortOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sort"
        view.backgroundColor = .white
        setupTableView()
        setupButtons()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
    }
    
    private func setupButtons() {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Vazgeç", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Uygula", for: .normal)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        applyButton.layer.cornerRadius = 8
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        
        let buttonsStackView = UIStackView(arrangedSubviews: [cancelButton, applyButton])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 20
        buttonsStackView.alignment = .center
        buttonsStackView.distribution = .fillEqually
        
        view.addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    @objc private func cancelButtonTapped() {
        print("cancel")
        delegate?.dismissPopup()
    }
    
    @objc private func applyButtonTapped() {
        if let option = selectedSortOption {
            delegate?.sortData(by: option)
            delegate?.dismissPopup()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = sortOptions[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedSortOption = sortOptions[indexPath.row]
        }
    
//    private func sortData(by option: String) {
//            let db = Firestore.firestore()
//            var query: Query = db.collection("Products")
//            
//            switch option {
//            case "Tarihe göre (önce en yeni)":
//                query = query.order(by: "Tarih", descending: true)
//            case "Tarihe göre (önce en eski)":
//                query = query.order(by: "Tarih", descending: false)
//            case "Evrak No'ya göre (yüksekten düşüğe)":
//                query = query.order(by: "Evrak No", descending: true)
//            case "Evrak No'ya göre (düşükten yükseğe)":
//                query = query.order(by: "Evrak No", descending: false)
////            case "Koda göre (yüksekten düşüğe)":
////                query = query.order(by: "Kod", descending: true)
////            case "Koda göre (düşükten yüksek)":
////                query = query.order(by: "Kod", descending: false)
//            case "Adet sayısına göre (yüksekten düşüğe)":
//                query = query.order(by: "Adet", descending: true)
//            case "Adet sayısına göre (düşükten yüksek)":
//                query = query.order(by: "Adet", descending: false)
//            case "Fason fiyatına göre (yüksekten düşüğe)":
//                query = query.order(by: "Fason Fiyat", descending: true)
//            case "Fason fiyatına göre (düşükten yüksek)":
//                query = query.order(by: "Fason Fiyat", descending: false)
//            case "Fasona gidiş tarihine göre (önce en yeni)":
//                query = query.order(by: "Fasona Gidiş Tarihi", descending: true)
//            case "Fasona gidiş tarihine göre (önce en eski)":
//                query = query.order(by: "Fasona Gidiş Tarihi", descending: false)
//            case "Fasondan geliş tarihine göre (önce en yeni)":
//                query = query.order(by: "Fasondan Geliş Tarihi", descending: true)
//            case "Fasondan geliş tarihine göre (önce en eski)":
//                query = query.order(by: "Fasondan Geliş Tarihi", descending: false)
//            case "Fasondan gelen adet sayısına göre (yüksekten düşüğe)":
//                query = query.order(by: "Fasondan Gelen Adet", descending: true)
//            case "Fasondan gelen adet sayısına göre (düşükten yükseğe)":
//                query = query.order(by: "Fasondan Gelen Adet", descending: false)
//            case "Çıtçıttan gelen adet sayısına göre (yüksekten düşüğe)":
//                query = query.order(by: "Çıtçıt Gelen Adet", descending: true)
//            case "Çıtçıttan gelen adet sayısına göre (düşükten yüksek)":
//                query = query.order(by: "Çıtçıt Gelen Adet", descending: false)
//            case "Çıtçıt sayısına göre (yüksekten düşüğe)":
//                query = query.order(by: "Çıtçıt Sayısı", descending: true)
//            case "Çıtçıt sayısına göre (düşükten yüksek)":
//                query = query.order(by: "Çıtçıt Sayısı", descending: false)
//            case "Çıtçıt tutarına göre (yüksekten düşüğe)":
//                query = query.order(by: "Çıtçıt Tutar", descending: true)
//            case "Çıtçıt tutarına göre (düşükten yüksek)":
//                query = query.order(by: "Çıtçıt Tutar", descending: false)
//            case "Ütü fiyatına göre (yüksekten düşüğe)":
//                query = query.order(by: "Ütü Fiyat", descending: true)
//            case "Ütü fiyatına göre (düşükten yüksek)":
//                query = query.order(by: "Ütü Fiyat", descending: false)
//            case "Ütüden gelen adet sayısına göre (yüksekten düşüğe)":
//                query = query.order(by: "Ütü Gelen Adet", descending: true)
//            case "Ütüden gelen adet sayısına göre (düşükten yüksek)":
//                query = query.order(by: "Ütü Gelen Adet", descending: false)
//            case "Defolu sayısına göre (yüksekten düşüğe)":
//                query = query.order(by: "Defolu", descending: true)
//            case "Defolu sayısına göre (düşükten yüksek)":
//                query = query.order(by: "Defolu", descending: false)
//            case "Eksik sayısına göre (yüksekten düşüğe)":
//                query = query.order(by: "Eksik", descending: true)
//            case "Eksik sayısına göre (düşükten yüksek)":
//                query = query.order(by: "Eksik", descending: false)
//            default:
//                return
//            }
//            
//            query.getDocuments { snapshot, error in
//                guard let documents = snapshot?.documents else {
//                    print("Error getting documents: \(error?.localizedDescription ?? "Unknown error")")
//                    return
//                }
//                
//                
//                for document in documents {
//                    print("\(document.documentID) => \(document.data())")
//                }
//            }
//        }

}
