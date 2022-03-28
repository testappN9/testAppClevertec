import Foundation

protocol MainCollectionViewCellType: AnyObject {
    func markMovie(movie: Movie) -> Bool
}
