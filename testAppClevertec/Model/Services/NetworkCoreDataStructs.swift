import Foundation

struct MoviesModel: Codable {
    var results: [Movie]?
}

struct Movie: Codable, Equatable {
    var id: Int
    var name: String?
    var backgroundImage: String?
    var posterImage: String?
    var released: String?
    var genres: [Int]?
    var description: String?
    var rating: Float?
    var genresReady: [String]?
    var backgroundImageReady: Data?
    var posterImageReady: Data?
    enum CodingKeys: String, CodingKey {
        case id
        case name = "title"
        case backgroundImage = "backdrop_path"
        case posterImage = "poster_path"
        case released = "release_date"
        case genres = "genre_ids"
        case description = "overview"
        case rating = "vote_average"
        case genresReady
        case backgroundImageReady
        case posterImageReady
    }
}

struct GenresModel: Codable {
    var genres: [Genre]?
}

struct Genre: Codable {
    var id: Int
    var name: String?
}
