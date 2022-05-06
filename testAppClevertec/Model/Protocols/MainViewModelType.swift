import Foundation

protocol MainViewModelType: CollectionDataSourceType {
    var updateCollection: Box<Bool> { get set }
    var movieForDetailsScreen: Box<MovieDetails> { get set }
    var alert: Box<NetworkError> { get set }
    func searchTextUpdated(text: String?)
}
