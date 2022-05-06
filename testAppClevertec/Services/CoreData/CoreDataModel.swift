
import Foundation

struct MovieCoreData: Codable, Equatable {
    var id: Int
    var name: String?
    var released: String?
    var description: String?
    var rating: Float?
    var genres: [String]?
    var backgroundImage: Data?
    var posterImage: Data?
    
    init(model: MovieNet, allGenresList: [Genre], background: Data?, poster: Data?) {
        id = model.id
        name = model.name
        released = model.released
        description = model.description
        rating = model.rating
        genres = convertGenres(genres: model.genres, allGenresList: allGenresList)
        backgroundImage = background
        posterImage = poster
    }
    
    func convertGenres(genres: [Int]?, allGenresList: [Genre]) -> [String]? {
        guard let genres = genres else { return nil }
        var readyArray = [String]()
        
        for genre in genres {
            for item in allGenresList where genre == item.id {
                readyArray.append(item.name ?? "")
            }
        }
        return readyArray
    }
}




