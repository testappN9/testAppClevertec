import Foundation

struct MoviesNetModel: Codable {
    var results: [MovieNet]?
}

struct MovieNet: Codable, Equatable {
    var id: Int
    var name: String?
    var backgroundImage: String?
    var posterImage: String?
    var released: String?
    var genres: [Int]?
    var description: String?
    var rating: Float?

    enum CodingKeys: String, CodingKey {
        case id
        case name = "title"
        case backgroundImage = "backdrop_path"
        case posterImage = "poster_path"
        case released = "release_date"
        case genres = "genre_ids"
        case description = "overview"
        case rating = "vote_average"
    }
}

struct GenresModel: Codable {
    var genres: [Genre]?
}

struct Genre: Codable {
    var id: Int
    var name: String?
}

enum NetworkError: String {
    case success
    case unableToDecode = "Unable to decode data"
    case noData = "No data to decode"
    case badRequest = "Something has changed on the server"
    case connectionProblems = "Internet connection problems"
}
