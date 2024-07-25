import UIKit

class SortViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: PopupViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    let sortOptions = [ "Tarihe göre (önce en yeni)", "Tarihe göre (önce en eski)",
        "Evrak No'ya göre (yüksekten düşüğe)", "Evrak No'ya göre (düşükten yükseğe)", "Koda göre (yüksekten düşüğe)",
        "Koda göre (düşükten yükseğe)", "Adet sayısına göre (yüksekten düşüğe)", "Adet sayısına göre (düşükten yükseğe)",
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)  // Adjust the bottom constraint
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

    

}
