import Foundation

protocol FavoritesViewModelType: CollectionDataSourceType {
    var updateCollection: Box<Bool> { get set }
    var alert: Box<Bool> { get set }
    var indexPathItemToDelete: Box<Int> { get set }
    var movieForDetailsScreen: Box<MovieDetails> { get set }
    func searchTextUpdated(text: String?)
    func deleteItem()
}
