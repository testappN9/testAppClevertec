//
//  NetworkManager.swift
//  testAppClevertec
//
//  Created by Apple on 20.03.22.
//

import Foundation
import UIKit

class NetworkManager {
    static let data: NetworkManager = NetworkManager()
    private let dispatchGroupForImages = DispatchGroup()
    private var readyArray = [Movie]()
    private struct Links {
        static let currentToken = "c98b2518c9b7df3023cd8b316c524623"
        static let linkAllData = "https://api.themoviedb.org/3/movie/popular?api_key="
        static let linkImage = "https://image.tmdb.org/t/p/w500"
        static let linkGenres = "https://api.themoviedb.org/3/genre/movie/list?api_key="
    }
    
    private init() {}
    
    private func getData(currentLink: String, completionHandler: @escaping (Data?) -> Void) {
        guard let link = URL(string: currentLink) else {return}
        let session = URLSession.shared.dataTask(with: link) { (data, _, error) in
            if error == nil {
                guard let data = data else { return }
                completionHandler(data)
            } else {
                completionHandler(nil)
                print(error as Any)
            }
        }
        session.resume()
    }
    
    private func decodeData<T: Codable>(data: Data?) -> T? {
        guard let data = data else { return nil }
        do {
            let dataReady: T = try JSONDecoder().decode(T.self, from: data)
            return dataReady
        } catch {
            print(error)
            return nil
        }
    }
        
    private func updateGenres(allDataReady: inout [Movie], allAvailableGenres: [Genre]) {
        var dictionaryGenres = [Int: String]()
        for item in allAvailableGenres {
            dictionaryGenres.updateValue(item.name ?? "", forKey: item.id)
        }
        for (index, value) in allDataReady.enumerated() {
            allDataReady[index].genresReady = []
            for item in value.genres ?? [] {
                allDataReady[index].genresReady?.append(dictionaryGenres[item] ?? "")
            }
        }
    }
 
    private func updateImages() {
        for (index, value) in readyArray.enumerated() {
            dispatchGroupForImages.enter()
            getData(currentLink: Links.linkImage + (value.backgroundImage ?? "")) { (background) in
                self.readyArray[index].backgroundImageReady = background
                self.getData(currentLink: Links.linkImage + (value.posterImage ?? "")) { poster in
                    self.readyArray[index].posterImageReady = poster
                    self.dispatchGroupForImages.leave()
                }
            }
        }
    }
    
    func getAllData(completionHandler: @escaping ([Movie]) -> Void) {
        getData(currentLink: Links.linkAllData + Links.currentToken, completionHandler: {(dataMovies) in
            let movies: MoviesModel? = self.decodeData(data: dataMovies)
            guard var allDataReady = movies?.results else { completionHandler([Movie]()); return}
            self.getData(currentLink: Links.linkGenres + Links.currentToken, completionHandler: {(dataGenres) in
                let genres: GenresModel? = self.decodeData(data: dataGenres)
                if let allAvailableGenres = genres?.genres {
                    self.updateGenres(allDataReady: &allDataReady, allAvailableGenres: allAvailableGenres)
                }
                self.readyArray = allDataReady
                self.updateImages()
                self.dispatchGroupForImages.notify(queue: .main) {
                    completionHandler(self.readyArray)
                }
            })
        })
    }
}

