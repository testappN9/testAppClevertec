import Foundation

protocol MainFavoritesViewModelType {
    var readyMoviesList: Box<[(Movie, Bool)]> { get set }
    var alert: Box<AlertType> { get set }
    var stateForCell: Box<Bool> { get set }
    func allDataWillUpdate()
    func savedDataWillUpdate()
    func movieMarked(movie: Movie?)
    func searchTextUpdated(text: String?)
}
