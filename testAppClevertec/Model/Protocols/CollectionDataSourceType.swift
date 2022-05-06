import Foundation

protocol CollectionDataSourceType: AnyObject {
    func getNumberOfCells() -> Int
    func getMovieForIndexPath(indexPath: Int) -> MovieCollectionItem
    func openDetailsScreen(indexPath: Int)
    func markMovie(movie: MovieCollectionItem) -> Bool
    func updateAllData(fromNetwork: Bool)
    func getImageForCell(indexPath: Int, completitionHandler: @escaping (Data?) -> Void)
}
