import UIKit

protocol FilteringOptionsDelegate: AnyObject {
    func applyFilters(filter1: String, filter2: String, keyword: String)
}

class FilteringOptionsViewController: UIViewController {

    weak var delegate: FilteringOptionsDelegate?
    var filterValues: [String: (filter1: String, filter2: String)] = [:]
    
    private var selectedDate: String?
    private let filter1TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "En çok"
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        return textField
    }()

    private let filter2TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "En az"
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        return textField
    }()
    
    private let keywordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Aranacak bir kelime giriniz"
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        return textField
    }()

    private let radioButton1: UIButton = {
           let button = UIButton(type: .custom)
           button.setTitle("Fotoğraf Eklenmiş", for: .normal)
           button.setTitleColor(.black, for: .normal)
           button.setImage(UIImage(systemName: "circle"), for: .normal)
           button.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .selected)
           button.addTarget(self, action: #selector(radioButtonTapped(_:)), for: .touchUpInside)
           button.contentHorizontalAlignment = .left
        
           return button
       }()
       
       private let radioButton2: UIButton = {
           let button = UIButton(type: .custom)
           button.setTitle("Fotoğraf Eklenmemiş", for: .normal)
           button.setTitleColor(.black, for: .normal)
           button.setImage(UIImage(systemName: "circle"), for: .normal)
           button.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .selected)
           button.addTarget(self, action: #selector(radioButtonTapped(_:)), for: .touchUpInside)
           button.contentHorizontalAlignment = .left
          

           return button
       }()
    
    private let pickerView = UIPickerView()
    private let segmentedControl = UISegmentedControl(items: ["Tarih", "Ay/Yıl", "Yıl"])

    var selectedYear = Calendar.current.component(.year, from: Date())
    var selectedMonth = Calendar.current.component(.month, from: Date())
    var selectedDay = Calendar.current.component(.day, from: Date())

    let startYear = 2010
    let endYear = 2030
    var hasPhotoOptions: Bool = false
    var hasPickerViewOptions: Bool = false
    var hasTextFieldsOptions: Bool = false
    var hasKeywordTextFieldOptions: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        filter1TextField.isHidden = true
        filter2TextField.isHidden = true
        pickerView.isHidden = true
        segmentedControl.isHidden = true
        radioButton1.isHidden = true
        radioButton2.isHidden = true
        keywordTextField.isHidden = true
        setPhotoOptionsVisibility()
        setPickerViewVisibility()
        setTextFieldsVisibility()
    }

    
    private func setPhotoOptionsVisibility() {
        radioButton1.isHidden = !hasPhotoOptions
        radioButton2.isHidden = !hasPhotoOptions
    }

    private func setPickerViewVisibility() {
        pickerView.isHidden = !hasPickerViewOptions
        segmentedControl.isHidden = !hasPickerViewOptions
    }
    private func setTextFieldsVisibility() {
        filter1TextField.isHidden = !hasTextFieldsOptions
        filter2TextField.isHidden = !hasTextFieldsOptions
        keywordTextField.isHidden = !hasKeywordTextFieldOptions
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
        setupSegmentedControl(in: containerView)
        setupPickerView(in: containerView)
        setupKeywordTextField(in: containerView)
        setupRadioButtons(in: containerView)
        setupButtons(in: containerView)
        setupTextFields(in: containerView)
        
        pickerView.reloadAllComponents()
    }



    private func setupRadioButtons(in containerView: UIView) {
        containerView.addSubview(radioButton1)
        containerView.addSubview(radioButton2)

        radioButton1.translatesAutoresizingMaskIntoConstraints = false
        radioButton2.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            radioButton1.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 50),
            radioButton1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            radioButton1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            radioButton2.topAnchor.constraint(equalTo: radioButton1.bottomAnchor, constant: 20),
            radioButton2.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            radioButton2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSegmentedControl(in containerView: UIView) {
        containerView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            segmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        ])
    }

    private func setupPickerView(in containerView: UIView) {
        pickerView.delegate = self
        pickerView.dataSource = self
        containerView.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            pickerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            pickerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -0),
            pickerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -80)
        ])
    }

    private func setupKeywordTextField(in containerView: UIView) {
        containerView.addSubview(keywordTextField)
        keywordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            keywordTextField.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            keywordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            keywordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ])
    }

    private func setupButtons(in containerView: UIView) {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Vazgeç", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        containerView.addSubview(cancelButton)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
            cancelButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -30)
        ])
        
        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Uygula", for: .normal)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        applyButton.layer.cornerRadius = 8
        applyButton.addTarget(self, action: #selector(applyButtonTapped), for: .touchUpInside)
        containerView.addSubview(applyButton)
        
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            applyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            applyButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            applyButton.heightAnchor.constraint(equalToConstant: 44),
            applyButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5, constant: -30)
        ])
    }

    private func setupTextFields(in containerView: UIView) {
        containerView.addSubview(filter1TextField)
        containerView.addSubview(filter2TextField)

        filter1TextField.translatesAutoresizingMaskIntoConstraints = false
        filter2TextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            filter1TextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            filter1TextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            filter1TextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),

            filter2TextField.topAnchor.constraint(equalTo: filter1TextField.bottomAnchor, constant: 10),
            filter2TextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            filter2TextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        ])
    }
    @objc private func radioButtonTapped(_ sender: UIButton) {
            if sender == radioButton1 {
                radioButton1.isSelected = true
                radioButton2.isSelected = false
            } else if sender == radioButton2 {
                radioButton1.isSelected = false
                radioButton2.isSelected = true
            }
        }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func applyButtonTapped() {
        let filter1 = filter1TextField.text ?? ""
        let filter2 = filter2TextField.text ?? ""
        let keyword = keywordTextField.text ?? ""
        
        if let selectedOption = (delegate as? FilterViewController)?.selectedFilterOption {
            if hasKeywordTextFieldOptions {
                let keywordKey = "\(selectedOption)Filter"
                    DataManager.keywordValues[keywordKey] = keyword
                } else if hasPhotoOptions {
                    let photoKey = "\(selectedOption)Filter"
                    if radioButton1.isSelected {
                        DataManager.keywordValues[photoKey] = "Var"
                    } else if radioButton2.isSelected {
                        DataManager.keywordValues[photoKey] = "Yok"
                    }
                } else if hasPickerViewOptions {
                    let dateKey = "\(selectedOption)Filter"
                    DataManager.keywordValues[dateKey] = selectedDate
                } else {
                    let filter1Key = "\(selectedOption)1Filter"
                    let filter2Key = "\(selectedOption)2Filter"
                    DataManager.keywordValues[filter1Key] = filter1
                    DataManager.keywordValues[filter2Key] = filter2
                }
        }
        
        delegate?.applyFilters(filter1: filter1, filter2: filter2, keyword: keyword)
        print(DataManager.keywordValues)
        dismiss(animated: true, completion: nil)
    }



    private func formatDate() -> String {
            let calendar = Calendar.current
            let dateFormatter = DateFormatter()
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                dateFormatter.dateFormat = "d.M.yyyy"
            case 1:
                dateFormatter.dateFormat = "M.yyyy"
            case 2:
                dateFormatter.dateFormat = "yyyy"
            default:
                return ""
            }
            let dateComponents = DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)
            let date = calendar.date(from: dateComponents)
            return dateFormatter.string(from: date ?? Date())
        }

    @objc func segmentedControlChanged(_ sender: UISegmentedControl) {
        pickerView.reloadAllComponents()
    }

    

}

extension FilteringOptionsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return 3
        case 1:
            return 2
        case 2:
            return 1
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            switch component {
            case 0:
                return 31
            case 1:
                return 12
            case 2:
                return endYear - startYear + 1
            default:
                return 0
            }
        case 1:
            switch component {
            case 0:
                return 12
            case 1:
                return endYear - startYear + 1
            default:
                return 0
            }
        case 2:
            return endYear - startYear + 1
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            switch component {
            case 0:
                return "\(row + 1)"
            case 1:
                return "\(row + 1)"
            case 2:
                return "\(startYear + row)"
            default:
                return nil
            }
        case 1:
            switch component {
            case 0:
                return "\(row + 1)"
            case 1:
                return "\(startYear + row)"
            default:
                return nil
            }
        case 2:
            return "\(startYear + row)"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if component == 0 {
                selectedDay = row + 1
            } else if component == 1 {
                selectedMonth = row + 1
            } else if component == 2 {
                selectedYear = startYear + row
            }
        case 1:
            if component == 0 {
                selectedMonth = row + 1
            } else if component == 1 {
                selectedYear = startYear + row
            }
        case 2:
            if component == 0 {
                selectedYear = startYear + row
            }
        default:
            break
        }
        
        selectedDate = formatDate()
    }
}
