import Foundation

struct MovieDetails {
    var posterImage: Data?
    var rating: String?
    var genres: String?
    var description: String?

    init() { }
    
    init(model: MovieNet, poster: Data?, allGenresList: [Genre]) {
        posterImage = poster
        description = model.description
        genres = getGenres(genres: model.genres, allGenresList: allGenresList)
        if let text = model.rating {
            rating = String(text)
        }
    }
    
    init(model: MovieCoreData) {
        posterImage = model.posterImage
        description = model.description
        if let text = model.rating {
            rating = String(text)
        }
        guard let fullGenres = model.genres else { return }
        genres = Array(fullGenres).reduce("", { $0 + $1 + " " })
    }
    
    private func getGenres(genres: [Int]?, allGenresList: [Genre]) -> String {
        var text = ""
        guard let genres = genres else { return "" }
        for genre in genres {
            for item in allGenresList where genre == item.id {
                text += ((item.name ?? "") + " ")
            }
        }
        return text
    }
}
