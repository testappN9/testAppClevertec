import Foundation

class DetailsScreenViewModel: DetailsViewModelType {
    private let movie: Movie
    var image = Box(Data())
    var rating = Box("")
    var genres = Box("")
    var descriptionReleased = Box("")

    init(movie: Movie) {
        self.movie = movie
    }
    
    func viewsDidLoad() {
        if let data = movie.posterImageReady {
            image.value = data
        }
        if let data = movie.rating {
            rating.value = String(data)
        }
        var text = ""
        if let data = movie.description {
            text = "   \(data) "
        }
        if let data = movie.released {
            text += "Release date: \(data)."
        }
        descriptionReleased.value = text
        if let data = movie.genresReady {
            let array = data.dropLast()
            genres.value = array.reduce(" ", { $0 + $1 + " " })
        }
    }
}
