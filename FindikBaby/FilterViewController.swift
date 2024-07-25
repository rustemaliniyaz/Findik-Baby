import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: PopupViewControllerDelegate?
    var selectedFilterOption: String?
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    let filterOptions = [
        "Ürün Fotoğrafı", "Tarih", "Evrak No", "Kod", "Adet", "Açıklama",
        "Aksesuar", "Baskı", "Ense Baskı", "Fason Dikiş", "Operasyon",
        "Fason Fiyat", "Fasona Gidiş Tarihi", "Fasondan Geliş Tarihi",
        "Fasondan Gelen Adet", "Çıtçıt", "Çıtçıt Gelen Adet", "Çıtçıt Sayısı",
        "Çıtçıt Tutar", "Ütü", "Ütü Fiyat", "Ütü Gelen Adet", "Defolu",
        "Parti Devam", "Eksik", "Model Açıklama"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filter"
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

    
    func presentFilteringOptions(withPhotoOptions hasPhotoOptions: Bool, pickerViewOptions hasPickerViewOptions: Bool, textFieldsOptions hasTextFieldsOptions: Bool, keywordTextFieldOptions: Bool) {
        let filteringOptionsVC = FilteringOptionsViewController()
        filteringOptionsVC.delegate = self // Ensure this is correctly set
        
        filteringOptionsVC.hasPhotoOptions = hasPhotoOptions
        filteringOptionsVC.hasPickerViewOptions = hasPickerViewOptions
        filteringOptionsVC.hasTextFieldsOptions = hasTextFieldsOptions
        filteringOptionsVC.hasKeywordTextFieldOptions = keywordTextFieldOptions
        
        filteringOptionsVC.modalPresentationStyle = .overCurrentContext
        present(filteringOptionsVC, animated: false, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        delegate?.dismissPopup()
    }
    
    @objc private func applyButtonTapped() {
        delegate?.dismissPopup()
    }
    func updateCheckmark(for filterOption: String) {
        if let index = filterOptions.firstIndex(of: filterOption) {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            
            // Check if filter values exist in DataManager and use them
            if let (filter1, filter2) = DataManager.filterValues[filterOption] {
                // Use filter1 and filter2 as needed
                print("Filter1 for \(filterOption): \(filter1)")
                print("Filter2 for \(filterOption): \(filter2)")
            }
        }
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = filterOptions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard indexPath.row < filterOptions.count else {
                return
            }
        
        selectedFilterOption = filterOptions[indexPath.row]
            let selectedOption = filterOptions[indexPath.row]
            if selectedOption == "Ürün Fotoğrafı" {
                presentFilteringOptions(withPhotoOptions: true, pickerViewOptions: false, textFieldsOptions: false, keywordTextFieldOptions: false)
            } else if selectedOption == "Tarih" || selectedOption == "Fasona Gidiş Tarihi" || selectedOption == "Fasondan Geliş Tarihi" {
                presentFilteringOptions(withPhotoOptions: false, pickerViewOptions: true, textFieldsOptions: false, keywordTextFieldOptions: false)
            } else if selectedOption == "Evrak No" || selectedOption == "Kod" || selectedOption == "Adet" || selectedOption == "Operasyon" || selectedOption == "Fason Fiyat" || selectedOption == "Fasondan Gelen Adet" || selectedOption == "Çıtçıt Gelen Adet" || selectedOption == "Çıtçıt Sayısı" || selectedOption == "Çıtçıt Tutar" || selectedOption == "Ütü Fiyat" || selectedOption == "Ütü Gelen Adet" || selectedOption == "Defolu" || selectedOption == "Parti Devam" || selectedOption == "Eksik" {
                presentFilteringOptions(withPhotoOptions: false, pickerViewOptions: false, textFieldsOptions: true, keywordTextFieldOptions: false)
            } else if selectedOption == "Açıklama" || selectedOption == "Aksesuar" || selectedOption == "Baskı" || selectedOption == "Ense Baskı" || selectedOption == "Fason Dikiş" || selectedOption == "Çıtçıt" || selectedOption == "Ütü" || selectedOption == "Model Açıklama" {
                presentFilteringOptions(withPhotoOptions: false, pickerViewOptions: false, textFieldsOptions: false, keywordTextFieldOptions: true)
            } else {
                presentFilteringOptions(withPhotoOptions: false, pickerViewOptions: false, textFieldsOptions: false, keywordTextFieldOptions: false)
            }

            tableView.deselectRow(at: indexPath, animated: true)
        }
}

extension FilterViewController: FilteringOptionsDelegate {
    func applyFilters(filter1: String, filter2: String, keyword: String) {

        dismiss(animated: true, completion: nil)
    }
}
