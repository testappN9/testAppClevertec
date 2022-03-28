import Foundation

protocol DetailsViewModelType {
    var genres: Box<String> { get set }
    var image: Box<Data> { get set }
    var rating: Box<String> { get set }
    var descriptionReleased: Box<String> { get set }
    func viewsDidLoad()
}
