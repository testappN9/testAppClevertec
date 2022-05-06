import Foundation
import UIKit

protocol CollectionType: UIView {
    func updateCollection()
    func endRefreshing()
    func deleteItem(indexPath: Int)
}
