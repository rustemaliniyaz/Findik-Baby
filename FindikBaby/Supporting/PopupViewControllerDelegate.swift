
import Foundation
protocol PopupViewControllerDelegate: AnyObject {
    func dismissPopup()
    func sortData(by option: String)
    func didApplyFilters(filteredArray: [String])
    func turnIsFilteringToFalse() 
}
