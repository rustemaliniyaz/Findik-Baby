import UIKit
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore

protocol UpdateContentViewControllerDelegate: AnyObject {
    func updateContentViewControllerDidSave(text: Any, forMessageText messageText: String)
}

class UpdateContentViewController: UIViewController, UITextFieldDelegate {

    weak var delegate: UpdateContentViewControllerDelegate?
    let db = Firestore.firestore()
    
    private let addProduct = AddProductViewController()
    private var isUploadInProgress = false
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .systemBackground
        label.text = DataManager.messageText
        label.textAlignment = .center
        label.font = label.font.withSize(30)
        label.textColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        if label.text == "Ürün Fotoğrafı" { label.isHidden = true }
        return label
    }()
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.backgroundColor = .systemBackground
        return picker
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray6
        textField.attributedPlaceholder = NSAttributedString(string: "Güncelleme giriniz", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1.0
        textField.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        textField.layer.borderColor = UIColor.systemGray.withAlphaComponent(1.0).cgColor
        textField.textAlignment = .center
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("Kaydet", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = button.titleLabel?.font.withSize(20)
        button.addTarget(self, action: #selector(saveButtonActionForProductInfo), for: .touchUpInside)
        return button
    }()
    
    private lazy var selectPhotoButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Fotoğraf Çek", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = button.titleLabel?.font.withSize(20)
        button.addTarget(self, action: #selector(selectPhotoButtonAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIComponents()
        textField.delegate = self
        navigationItem.backBarButtonItem?.title = "Geri Dön"
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }

    @objc func saveButtonActionForProductInfo() {
        if label.text == "Ürün Fotoğrafı" {
            // Handle image upload
            if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
                isUploadInProgress = true
                updateSaveButtonTitle(isUploading: true)
                let filename = UUID().uuidString + ".jpg"
                let imageRef = DataManager.imageReference.child(filename)
                imageRef.putData(data, metadata: nil) { metadata, error in
                    if let error = error {
                        self.makeAlert(titleInput: "Yükleme Hatası", messageInput: "Fotoğraf yüklenirken bir hata oluştu. Tekrar deneyiniz.")
                        print("Error uploading image: \(error.localizedDescription)")
                        self.isUploadInProgress = false
                        self.updateSaveButtonTitle(isUploading: false)
                    } else {
                        imageRef.downloadURL { url, error in
                            if let error = error {
                                print("Error retrieving download URL: \(error.localizedDescription)")
                            } else if let imageURL = url?.absoluteString {
                                DataManager.productData[String(self.label.text!)] = imageURL
                                print("Uploaded image URL: \(imageURL)")
                                self.isUploadInProgress = false
                                self.updateSaveButtonTitle(isUploading: false)
                                let docRef = self.db.document("Products/\(DataManager.documentName)")
                                docRef.updateData(["\(DataManager.messageText)": imageURL]) { error in
                                    if let error = error {
                                        print("Error updating document: \(error)")
                                    } else {
                                        if let delegate = self.delegate {
                                            delegate.updateContentViewControllerDidSave(text: imageURL, forMessageText: DataManager.messageText)
                                        }
                                        DataManager.productData.removeAll()
                                        DispatchQueue.main.async {
                                            self.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } else if label.text == "Kod" {
            makeAlert(titleInput: "Hata", messageInput: "Kod güncellenemez.")
            
        } else if label.text == "Evrak No" || label.text == "Kod" || label.text == "Adet" || label.text == "Operasyon" || label.text == "Fasondan Gelen Adet" || label.text == "Çıtçıt Gelen Adet" || label.text == "Çıtçıt Sayısı" || label.text == "Ütü Gelen Adet" || label.text == "Defolu" || label.text == "Parti Devam" || label.text == "Eksik" {
            // **Updated Code: Convert text field input to Integer**
            if let intValue = Int(textField.text ?? "") {
                let docRef = db.document("Products/\(DataManager.documentName)")
                docRef.updateData(["\(DataManager.messageText)": intValue]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        if let delegate = self.delegate {
                            delegate.updateContentViewControllerDidSave(text: "\(intValue)", forMessageText: DataManager.messageText)
                        }
                        DataManager.productData.removeAll()
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                makeAlert(titleInput: "Geçersiz Girdi", messageInput: "Lütfen geçerli bir sayı girin.")
            }
            
        } else if label.text == "Fason Fiyat" || label.text == "Çıtçıt Tutar" || label.text == "Ütü Fiyat" {
            let text = textField.text?.replacingOccurrences(of: ",", with: ".") ?? ""
            if let floatValue = Float(text) {
                let docRef = db.document("Products/\(DataManager.documentName)")
                docRef.updateData(["\(DataManager.messageText)": floatValue]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                    } else {
                        if let delegate = self.delegate {
                            delegate.updateContentViewControllerDidSave(text: "\(floatValue)", forMessageText: DataManager.messageText)
                        }
                        DataManager.productData.removeAll()
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            } else {
                makeAlert(titleInput: "Geçersiz Girdi", messageInput: "Lütfen geçerli bir sayı girin.")
            }
            
        } else if label.text == "Tarih" || label.text == "Fasona Gidiş Tarihi" || label.text == "Fasondan Geliş Tarihi" {
            // **Updated Code: Use date picker date**
            let selectedDate = datePicker.date
            let docRef = db.document("Products/\(DataManager.documentName)")
            docRef.updateData(["\(DataManager.messageText)": selectedDate]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    if let delegate = self.delegate {
                        delegate.updateContentViewControllerDidSave(text: "\(selectedDate)", forMessageText: DataManager.messageText)
                    }
                    DataManager.productData.removeAll()
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        } else {
            // **Updated Code: Handle default case**
            let docRef = db.document("Products/\(DataManager.documentName)")
            docRef.updateData(["\(DataManager.messageText)": textField.text ?? ""]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    if let delegate = self.delegate {
                        delegate.updateContentViewControllerDidSave(text: self.textField.text ?? "", forMessageText: DataManager.messageText)
                    }
                    DataManager.productData.removeAll()
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    
    private func updateSaveButtonTitle(isUploading: Bool) {
        if isUploading {
            saveButton.setTitle("Yükleniyor...", for: .normal)
            selectPhotoButton.isHidden = true
            saveButton.isEnabled = false
        } else {
            saveButton.setTitle("Kaydet", for: .normal)
            selectPhotoButton.isHidden = false
            saveButton.isEnabled = true
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
        }
    
    private func setupUIComponents() {
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        view.addSubview(textField)
        view.addSubview(saveButton)
        label.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            label.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            textField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            saveButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05)
        ])
        
        if DataManager.messageText == "Tarih" || DataManager.messageText == "Fasona Gidiş Tarihi" || DataManager.messageText == "Fasondan Geliş Tarihi" {
            
            view.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            textField.isHidden = true
            NSLayoutConstraint.activate([
                
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            datePicker.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            datePicker.heightAnchor.constraint(equalToConstant: 200) // Adjust height as needed
            ])
        }
        
        if DataManager.messageText == "Ürün Fotoğrafı" {
            view.addSubview(imageView)
            view.addSubview(selectPhotoButton)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            selectPhotoButton.translatesAutoresizingMaskIntoConstraints = false
            textField.isHidden = true
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.2),
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                imageView.bottomAnchor.constraint(equalTo: selectPhotoButton.topAnchor, constant: -20),
                
                selectPhotoButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10),
                selectPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                selectPhotoButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
                selectPhotoButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05)
            ])
        }
        if DataManager.messageText == "Fason Fiyat" || DataManager.messageText == "Çıtçıt Tutar" || DataManager.messageText == "Ütü Fiyat" {
            textField.keyboardType = .decimalPad
        } else if DataManager.messageText == "Evrak No" || DataManager.messageText == "Kod" || DataManager.messageText == "Adet" || DataManager.messageText == "Operasyon" || DataManager.messageText == "Fasondan Gelen Adet" || DataManager.messageText == "Çıtçıt Gelen Adet" || DataManager.messageText == "Çıtçıt Sayısı" || DataManager.messageText == "Ütü Gelen Adet" || DataManager.messageText == "Defolu" || DataManager.messageText == "Parti Devam" || DataManager.messageText == "Eksik" {
            textField.keyboardType = .numberPad
        } else {
            textField.keyboardType = .default
        }
    }
}

extension UpdateContentViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UpdateContentViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func selectPhotoButtonAction() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = (info[.originalImage] as? UIImage)
        self.dismiss(animated: true, completion: nil)
    }
}
