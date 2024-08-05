import UIKit
protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(filteredArray: [String])
    func dismissPopup()
    func turnIsFilteringToFalse()
}

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: PopupViewControllerDelegate?
    
    var selectedFilterOption: String?
    var finishedArray = [String]()
    var finishedArrayEverContainedAnyValue: Bool = false
    var checkedIndices: Set<Int> = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    let filterOptions = DataManager.elements
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filtre"
        view.backgroundColor = .white
        setupTableView()
        setupButtons()
        initializeCheckmarkStatesForFilters()
    }
    
    private func initializeCheckmarkStatesForFilters() {
        for category in filterOptions {
            if DataManager.checkmarkStatesForFilters[category] == nil {
                DataManager.checkmarkStatesForFilters[category] = false
            }
        }
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
        cancelButton.setTitle("Temizle", for: .normal)
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
        filteringOptionsVC.delegate = self
        
        filteringOptionsVC.hasPhotoOptions = hasPhotoOptions
        filteringOptionsVC.hasPickerViewOptions = hasPickerViewOptions
        filteringOptionsVC.hasTextFieldsOptions = hasTextFieldsOptions
        filteringOptionsVC.hasKeywordTextFieldOptions = keywordTextFieldOptions
        
        filteringOptionsVC.modalPresentationStyle = .overCurrentContext
        present(filteringOptionsVC, animated: false, completion: nil)
    }

    
    @objc private func cancelButtonTapped() {
        DataManager.keywordValues.removeAll()
        for key in DataManager.checkmarkStatesForFilters.keys {
            DataManager.checkmarkStatesForFilters[key] = false
        }
        
        self.tableView.reloadData()
        delegate?.turnIsFilteringToFalse()
        delegate?.dismissPopup()
    }
    
    @objc private func applyButtonTapped() {
        finishedArrayEverContainedAnyValue = false
        delegate?.didApplyFilters(filteredArray: finishedArray)
        print(FeedViewController().filteredProductCodes)
        print(FeedViewController().isFiltering)
        
        DataManager.keywordValues.removeAll()
        for key in DataManager.checkmarkStatesForFilters.keys {
            DataManager.checkmarkStatesForFilters[key] = false
        }
        delegate?.dismissPopup()
    }
    func updateCheckmark(for filterOption: String) {
        if let index = filterOptions.firstIndex(of: filterOption) {
            let indexPath = IndexPath(row: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            
            
            if let (filter1, filter2) = DataManager.filterValues[filterOption] {
                
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
        if DataManager.checkmarkStatesForFilters[filterOptions[indexPath.row]] == true {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < filterOptions.count else {
            return
        }
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        selectedFilterOption = filterOptions[indexPath.row]
        let selectedOption = filterOptions[indexPath.row]
        switch selectedOption {
        case "Ürün Fotoğrafı":
            presentFilteringOptions(withPhotoOptions: true, pickerViewOptions: false, textFieldsOptions: false, keywordTextFieldOptions: false)
        case "Tarih", "Fasona Gidiş Tarihi", "Fasondan Geliş Tarihi":
            presentFilteringOptions(withPhotoOptions: false, pickerViewOptions: true, textFieldsOptions: false, keywordTextFieldOptions: false)
        case "Evrak No", "Kod", "Adet", "Operasyon", "Fason Fiyat", "Fasondan Gelen Adet", "Çıtçıt Gelen Adet", "Çıtçıt Sayısı", "Çıtçıt Tutar", "Ütü Fiyat", "Ütü Gelen Adet", "Defolu", "Parti Devam", "Eksik":
            presentFilteringOptions(withPhotoOptions: false, pickerViewOptions: false, textFieldsOptions: true, keywordTextFieldOptions: false)
        case "Açıklama", "Aksesuar", "Baskı", "Ense Baskı", "Fason Dikiş", "Çıtçıt", "Ütü", "Model Açıklama":
            presentFilteringOptions(withPhotoOptions: false, pickerViewOptions: false, textFieldsOptions: false, keywordTextFieldOptions: true)
        default:
            presentFilteringOptions(withPhotoOptions: false, pickerViewOptions: false, textFieldsOptions: false, keywordTextFieldOptions: false)
        }
        
        print("FilterViewController's finishedArray:\(self.finishedArray)")
        tableView.deselectRow(at: indexPath, animated: true)
    }


}



extension FilterViewController: FilteringOptionsDelegate {
    func didUpdateFilteredResults(_ results: [String]) {
        if finishedArray.isEmpty && finishedArrayEverContainedAnyValue == false {
            finishedArray.append(contentsOf: results)
            finishedArrayEverContainedAnyValue = true
        } else if finishedArray.isEmpty && finishedArrayEverContainedAnyValue == true {
            return
        } else {
            finishedArray = finishedArray.filter { results.contains($0) }
        }
    }
    
    func applyFilters(filter1: String, filter2: String, keyword: String) {
            if let selectedFilterOption = selectedFilterOption {
                if let index = filterOptions.firstIndex(of: selectedFilterOption) {
                    let indexPath = IndexPath(row: index, section: 0)
                    if let cell = tableView.cellForRow(at: indexPath) {
                        cell.accessoryType = .checkmark
                    }
                }
            }
            
            
            dismiss(animated: true, completion: nil)
        }
    func didUpdateContent(for category: String) {
            DataManager.checkmarkStatesForFilters[category] = true
            tableView.reloadData()
        }
}
