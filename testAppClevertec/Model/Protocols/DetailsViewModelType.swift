import Foundation

protocol DetailsViewModelType {
    var readyMovie: Box<MovieDetails> { get set }
    func getMovie()
}
