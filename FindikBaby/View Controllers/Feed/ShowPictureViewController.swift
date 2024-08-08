import UIKit
import FirebaseFirestore
import SDWebImage

class ShowPictureViewController: UIViewController {
    let db = Firestore.firestore()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "checkered")
        imageView.clipsToBounds = true
        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemGray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadImageFromFirestore()
    }

    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.65),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.05),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.bounds.width * 0.05),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func loadImageFromFirestore() {
        activityIndicator.startAnimating()
        let docRef = db.document("Products/\(DataManager.documentName)")
        docRef.getDocument { [weak self] (snapshot, error) in
            guard let self = self else { return }
            guard let data = snapshot?.data(), error == nil else {

                print("Error fetching document: \(error?.localizedDescription ?? "No error description")")
                self.activityIndicator.stopAnimating()
                return
            }
            if let imageUrlString = data["Ürün Fotoğrafı"] as? String, let imageUrl = URL(string: imageUrlString) {
                self.imageView.sd_setImage(with: imageUrl) { (_, _, _, _) in
                    self.activityIndicator.stopAnimating()
                }
            } else {
                print("No image URL found in the document.")
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
