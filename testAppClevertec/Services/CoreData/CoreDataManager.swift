import Foundation
import UIKit
import CoreData

class CoreDataManager {
    static let data = CoreDataManager()
    private init() {}
    
    private func receiveData(id: Int?) -> ([MovieCoreData], NSManagedObjectContext, [MovieSaved]) {
        let context = CoreDataProvider.getContext()
        let fetchRequest: NSFetchRequest<MovieSaved> = MovieSaved.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        if let realId = id {
            fetchRequest.predicate = NSPredicate(format: "id = \(realId)")
        }
        do {
            let data = try context.fetch(fetchRequest)
            var moviesReady = [MovieCoreData]()
            for item in data {
                guard let movieData = item.movie, let movieReady = CoreDataCoder.decodeData(data: movieData) else { continue }
                moviesReady.append(movieReady)
            }
            return (moviesReady, context, data)
        } catch {
            print(error)
            return ([MovieCoreData](), context, [MovieSaved]())
        }
    }

    func receiveAllData() -> [MovieCoreData] {
        return receiveData(id: nil).0
    }
    
    func getSavedMovieIds() -> [Int] {
        let movies = receiveAllData()
        return movies.map {$0.id}
    }
    
    func receiveItem(_ id: Int) -> MovieCoreData? {
        let movies = receiveData(id: id).0
        return movies != [] ? movies[0] : nil
    }
    
    func saveItem(movie: MovieCoreData) {
        let context = CoreDataProvider.getContext()
        let object = MovieSaved(context: context)
        object.id = Int64(movie.id)
        object.movie = CoreDataCoder.encodeData(data: movie)
        CoreDataProvider.saveContext(context: context)
    }
    
    func deleteItem(id: Int) {
        let dataContext = receiveData(id: id)
        if dataContext.2 != [] {
            dataContext.1.delete(dataContext.2[0])
            CoreDataProvider.saveContext(context: dataContext.1)
        }
    }
}
