
import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        configureTabs()
    }

    private func configureTabs() {
        
        let vc1 = FeedViewController()
        let vc2 = AddProductViewController()
        let vc3 = UpdateViewController()
        let vc4 = SettingsViewController()
        
        vc1.tabBarItem.image = UIImage(systemName: "shippingbox")
        vc2.tabBarItem.image = UIImage(systemName: "plus")
        vc3.tabBarItem.image = UIImage(systemName: "text.badge.plus")
        vc4.tabBarItem.image = UIImage(systemName: "gear")
        vc1.title = "Envanter"
        vc2.title = "Ürün Ekle"
        vc3.title = "Ürün Güncelle"
        vc4.title = "Ayarlar"
        let nav1 = UINavigationController(rootViewController: vc1)
        let nav2 = UINavigationController(rootViewController: vc2)
        let nav3 = UINavigationController(rootViewController: vc3)
        let nav4 = UINavigationController(rootViewController: vc4)


        
        tabBar.tintColor = .label
        tabBar.backgroundColor = .systemGray6
        setViewControllers([nav1, nav2, nav3, nav4], animated: true)
    }

}
