import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore


protocol FilteringOptionsDelegate: AnyObject {
    func applyFilters(filter1: String, filter2: String, keyword: String)
    func didUpdateFilteredResults(_ results: [String])
    func didUpdateContent(for category: String) 
}

class FilteringOptionsViewController: UIViewController {
    
    weak var delegate: FilteringOptionsDelegate?
    var filterValues: [String: (filter1: String, filter2: String)] = [:]
    private var selectedDate1: String?
    private var selectedDate2: String?
    var newArray: [String] = []
   
    var finishedArray: [String] = []
    private let filter1TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "En az"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        return textField
    }()

    private let filter2TextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "En çok"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
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
    
    private let pickerView1 = UIPickerView()
    private let pickerView2 = UIPickerView()
    private var containerView: UIView!
    private let label1: UILabel = {
        let label = UILabel()
        label.text = "Başlangıç"
        label.textAlignment = .center
        return label
        }()
        
    private let label2: UILabel = {
        let label = UILabel()
        label.text = "Bitiş"
        label.textAlignment = .center
        return label
        }()
    
    var selectedYear = Calendar.current.component(.year, from: Date())
    var selectedMonth = Calendar.current.component(.month, from: Date())
    var selectedDay = Calendar.current.component(.day, from: Date())

    var hasPhotoOptions: Bool = false
    var hasPickerViewOptions: Bool = false
    var hasTextFieldsOptions: Bool = false
    var hasKeywordTextFieldOptions: Bool = false
    var finalArray: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        filter1TextField.isHidden = true
        filter2TextField.isHidden = true
        pickerView1.isHidden = true
        pickerView2.isHidden = true
        radioButton1.isHidden = true
        radioButton2.isHidden = true
        keywordTextField.isHidden = true
        setPhotoOptionsVisibility()
        setPickerViewVisibility()
        setTextFieldsVisibility()
        
    }
   
    
    
    private var containerHeightConstraint: NSLayoutConstraint?
    private func updateContainerHeight() {
        var height: CGFloat = 20
        
        if !filter1TextField.isHidden || !filter2TextField.isHidden {
            height += 100
        }
        
        if !pickerView1.isHidden || !pickerView2.isHidden {
            height += 350
        }
        
        if !keywordTextField.isHidden {
            height += 50
        }
        
        if !radioButton1.isHidden || !radioButton2.isHidden {
            height += 120
        }
        
        height += 84
        
        containerHeightConstraint?.constant = height
    }
    private func setPhotoOptionsVisibility() {
        radioButton1.isHidden = !hasPhotoOptions
        radioButton2.isHidden = !hasPhotoOptions
        updateContainerHeight()
    }

    private func setPickerViewVisibility() {
        pickerView1.isHidden = !hasPickerViewOptions
        pickerView2.isHidden = !hasPickerViewOptions
        label1.isHidden = !hasPickerViewOptions
        label2.isHidden = !hasPickerViewOptions
        updateContainerHeight()
    }

    private func setTextFieldsVisibility() {
        filter1TextField.isHidden = !hasTextFieldsOptions
        filter2TextField.isHidden = !hasTextFieldsOptions
        keywordTextField.isHidden = !hasKeywordTextFieldOptions
        updateContainerHeight()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 200)
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            containerHeightConstraint!
        ])
        
        self.containerView = containerView
        
        setupPickerViews(in: containerView)
        setupKeywordTextField(in: containerView)
        setupRadioButtons(in: containerView)
        setupButtons(in: containerView)
        setupTextFields(in: containerView)
        
        updateContainerHeight()
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
    
    

    private func setupPickerViews(in containerView: UIView) {
            pickerView1.delegate = self
            pickerView1.dataSource = self
            pickerView2.delegate = self
            pickerView2.dataSource = self
            
            containerView.addSubview(label1)
            containerView.addSubview(pickerView1)
            containerView.addSubview(label2)
            containerView.addSubview(pickerView2)
            
            label1.translatesAutoresizingMaskIntoConstraints = false
            pickerView1.translatesAutoresizingMaskIntoConstraints = false
            label2.translatesAutoresizingMaskIntoConstraints = false
            pickerView2.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label1.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
                label1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                label1.heightAnchor.constraint(equalToConstant: 30),
                
                pickerView1.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 8),
                pickerView1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
                pickerView1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
                pickerView1.heightAnchor.constraint(equalToConstant: 130),
                
                label2.topAnchor.constraint(equalTo: pickerView1.bottomAnchor, constant: 10),
                label2.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                label2.heightAnchor.constraint(equalToConstant: 30),

                pickerView2.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 8),
                pickerView2.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
                pickerView2.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
                pickerView2.heightAnchor.constraint(equalToConstant: 130)
            ])
        }

    private func setupKeywordTextField(in containerView: UIView) {
        containerView.addSubview(keywordTextField)
        keywordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            keywordTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
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
    var isFinalArrayEverContainedAnyValue: Bool = false

    private func filterData(completion: @escaping ([String]) -> Void) {
        let db = Firestore.firestore()
        var query: Query = db.collection("Products")
        var query1Items: [String] = []
        var query2Items: [String] = []
        var comparedItems: [String] = []
        let dispatchGroup = DispatchGroup()
        
        for (key, value) in DataManager.keywordValues {
            let field = key.replacingOccurrences(of: "Filter1", with: "")
                .replacingOccurrences(of: "Filter2", with: "")
                .replacingOccurrences(of: "Filter", with: "")

            if key.contains("TarihFilter1") || key.contains("TarihiFilter1") {
                let startDateString = value
                let endDateKey = key.replacingOccurrences(of: "Filter1", with: "Filter2")
                let endDateString = DataManager.keywordValues[endDateKey]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a 'UTC'XXX"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                guard let startDate = dateFormatter.date(from: startDateString),
                      let endDate = dateFormatter.date(from: endDateString!) else {
                    print("Invalid date format")
                    return
                }
                
                let startTimestamp = Timestamp(date: startDate)
                let endTimestamp = Timestamp(date: endDate)
                let dateQuery = db.collection("Products")
                    .whereField(field, isGreaterThanOrEqualTo: startTimestamp)
                    .whereField(field, isLessThanOrEqualTo: endTimestamp)
                dateQuery.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error fetching filtered data: \(error)")
                        
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("No filtered documents found")
                        return
                    }
                    
                    let newArray = documents.compactMap { $0.data()["Kod"] as? String }
                    completion(newArray)
                }
            } else if key.contains("Filter1") {
                if let intValue = Int(value) {
                    query = query.whereField(field, isGreaterThanOrEqualTo: intValue)
                }
            } else if key.contains("Filter2") {
                if let intValue = Int(value) {
                    query = query.whereField(field, isLessThanOrEqualTo: intValue)
                }
            } else if key.contains("Ürün FotoğrafıFilter") {
                query = query.whereField("Ürün Fotoğrafı", isNotEqualTo: "a")
            } else if key.contains("Ürün FotoğrafıFiltre") {
                dispatchGroup.enter()
                let query1 = query.whereField("Kod", isNotEqualTo: "aaa")
                query1.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error fetching filtered data: \(error)")
                        dispatchGroup.leave()
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("No filtered documents found")
                        dispatchGroup.leave()
                        return
                    }
                    query1Items = documents.compactMap { $0.data()["Kod"] as? String }
                    dispatchGroup.leave()
                }

                dispatchGroup.enter()
                let query2 = query.whereField("Ürün Fotoğrafı", isNotEqualTo: "a")
                query2.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error fetching filtered data: \(error)")
                        dispatchGroup.leave()
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        print("No filtered documents found")
                        dispatchGroup.leave()
                        return
                    }
                    query2Items = documents.compactMap { $0.data()["Kod"] as? String }
                    dispatchGroup.leave()
                }
            } else {
                query = query.whereField(field, isEqualTo: value)
            }
        }

        dispatchGroup.notify(queue: .main) {
            let set1 = Set(query1Items)
            let set2 = Set(query2Items)

            let uniqueItems = set1.symmetricDifference(set2)
            comparedItems = Array(uniqueItems)

            
            if !comparedItems.isEmpty {
                completion(comparedItems)
            }
        }

        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching filtered data: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No filtered documents found")
                return
            }

            let newArray = documents.compactMap { $0.data()["Kod"] as? String }
            completion(newArray)
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
                if let category = (delegate as? FilterViewController)?.selectedFilterOption {
                    delegate?.didUpdateContent(for: category)
                }
            } else if hasPhotoOptions {
                var photoKey = "\(selectedOption)Filter"
                if radioButton1.isSelected {
                    if DataManager.keywordValues["\(selectedOption)Filtre"] != nil {
                        DataManager.keywordValues.removeValue(forKey: "\(selectedOption)Filtre")
                    }
                    DataManager.keywordValues[photoKey] = "https://firebasestorage"
                    if let category = (delegate as? FilterViewController)?.selectedFilterOption {
                        delegate?.didUpdateContent(for: category)
                    }
                } else if radioButton2.isSelected {
                    if DataManager.keywordValues["\(selectedOption)Filter"] != nil {
                        DataManager.keywordValues.removeValue(forKey: "\(selectedOption)Filter")
                    }
                    photoKey = "\(selectedOption)Filtre"
                    DataManager.keywordValues[photoKey] = "Yok"
                    if let category = (delegate as? FilterViewController)?.selectedFilterOption {
                        delegate?.didUpdateContent(for: category)
                    }
                }
            } else if hasPickerViewOptions {
                let dateKey1 = "\(selectedOption)Filter1"
                let dateKey2 = "\(selectedOption)Filter2"
                DataManager.keywordValues[dateKey1] = selectedDate1
                DataManager.keywordValues[dateKey2] = selectedDate2
                if let category = (delegate as? FilterViewController)?.selectedFilterOption {
                    delegate?.didUpdateContent(for: category)
                }
            } else {
                let filter1Key = "\(selectedOption)Filter1"
                let filter2Key = "\(selectedOption)Filter2"
                DataManager.keywordValues[filter1Key] = filter1
                DataManager.keywordValues[filter2Key] = filter2
                if let category = (delegate as? FilterViewController)?.selectedFilterOption {
                    delegate?.didUpdateContent(for: category)
                }
            }
            
            filterData { newArray in
                self.delegate?.didUpdateFilteredResults(newArray)
                DataManager.keywordValues.removeAll()
                self.delegate?.applyFilters(filter1: filter1, filter2: filter2, keyword: keyword)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    

}

extension FilteringOptionsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 32
        case 1:
            return 13
        case 2:
            return 2028 - 2015 + 1
        default:
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row)"
        case 1:
            return "\(row)"
        case 2:
            return "\(2015 + row)"
        default:
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedDay = row
        case 1:
            selectedMonth = row
        case 2:
            selectedYear = 2015 + row
        default:
            break
        }
        
        
        let selectedDate = formatDate()
                
                if pickerView == pickerView1 {
                    selectedDate1 = selectedDate
                } else if pickerView == pickerView2 {
                    selectedDate2 = selectedDate
                }
    }
    
    private func formatDate() -> String {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy 'at' h:mm:ss a 'UTC'XXX"
        
        let dateComponents = DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)
        let date = calendar.date(from: dateComponents)
        return dateFormatter.string(from: date ?? Date())
    }
}
