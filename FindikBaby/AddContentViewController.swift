import UIKit

class AddContentViewController: UIViewController, UITextFieldDelegate {

    
    weak var delegate: AddContentViewControllerDelegate?
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
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "photo")
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        
        textField.backgroundColor = .systemGray6
        textField.attributedPlaceholder = NSAttributedString(string: "Güncelleme giriniz", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1.0
        textField.textColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        
        textField.layer.borderColor = UIColor(white: 1, alpha:1).cgColor
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
        button.isEnabled = true
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
            if DataManager.productData["Kod"] != nil {
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
                                    DispatchQueue.main.async {self.delegate?.didUpdateContent(for: "Ürün Fotoğrafı")}
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    }
                }
            } else {
                makeAlert(titleInput: "Kod Bulunamadı", messageInput: "Fotoğraf yüklemek için önce Kod giriniz.")
            }
        } else {
            DataManager.productData[String(label.text!)] = String(textField.text!)
            print(DataManager.productData)
            if let category = label.text {
                delegate?.didUpdateContent(for: category)
            }
            navigationController?.popViewController(animated: true)
        }
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
}

extension AddContentViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddContentViewController.hideKeyboard))
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
