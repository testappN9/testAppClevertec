import Foundation
import UIKit

class NetworkManager {
    static let data: NetworkManager = NetworkManager()
    private let dispatchGroupForImages = DispatchGroup()
    private var readyArray = [MovieNet]()
    private struct Links {
        static let currentToken = "c98b2518c9b7df3023cd8b316c524623"
        static let linkAllData = "https://api.themoviedb.org/3/movie/popular?api_key="
        static let linkImage = "https://image.tmdb.org/t/p/w500"
        static let linkGenres = "https://api.themoviedb.org/3/genre/movie/list?api_key="
    }
    
    private init() {}

    func getImage(link: String?, completitionHandler: @escaping (Data?) -> Void) {
        URLSessionProvider.getData(currentLink: Links.linkImage + (link ?? "")) { background, _ in
            completitionHandler(background)
        }
    }
    
    private func getAllGenres(completitionHandler: @escaping ([Genre]?) -> Void) {
        URLSessionProvider.getData(currentLink: Links.linkGenres + Links.currentToken) {dataGenres, _ in
            let genresModel: (GenresModel?, NetworkError) = NetworkDecoder.decodeData(data: dataGenres)
            completitionHandler(genresModel.0?.genres)
        }
    }
    
    func getAllData(completionHandler: @escaping ([MovieNet], [Genre], NetworkError) -> Void) {
        var movies = [MovieNet]()
        var genres = [Genre]()
        var netError = NetworkError.success
        let group = DispatchGroup()
        group.enter()
        URLSessionProvider.getData(currentLink: Links.linkAllData + Links.currentToken, completionHandler: {dataMovies, error in
            if error == NetworkError.success {
                let moviesRaw: (MoviesNetModel?, NetworkError) = NetworkDecoder.decodeData(data: dataMovies)
                netError = moviesRaw.1
                if let moviesReady = moviesRaw.0?.results {
                    movies = moviesReady
                } else {
                    netError = NetworkError.noData
                }
            } else {
                netError = error
            }
            group.leave()
        })
        group.enter()
        URLSessionProvider.getData(currentLink: Links.linkGenres + Links.currentToken, completionHandler: {dataGenres, _ in
            let genresRaw: (GenresModel?, NetworkError) = NetworkDecoder.decodeData(data: dataGenres)
            if let genresReady = genresRaw.0?.genres {
                genres = genresReady
            }
            group.leave()
        })
        group.notify(queue: .main) {
            completionHandler(movies, genres, netError)
        }
    }
}
