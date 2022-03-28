//
//  CoreDataManager.swift
//  testAppClevertec
//
//  Created by Apple on 22.03.22.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    static let data = CoreDataManager()
    
    private init() {}
    
    private func getContext() -> NSManagedObjectContext{
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    private func saveContext(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func encodeData(data: Movie) -> Data? {
        do {
            return try JSONEncoder().encode(data)
        } catch {
            print(error)
            return nil
        }
    }
    
    func decodeData(data: Data) -> Movie? {
        do {
            return try JSONDecoder().decode(Movie?.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
   
    private func receiveData(id: Int?) -> ([Movie], NSManagedObjectContext, [MovieSaved]) {
        let context = getContext()
        let fetchRequest: NSFetchRequest<MovieSaved> = MovieSaved.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        if let realId = id {
            fetchRequest.predicate = NSPredicate(format: "id = \(realId)")
        }
        do {
            let data = try context.fetch(fetchRequest)
            var moviesReady = [Movie]()
            for item in data {
                if let movieData = item.movie {
                    if let movieReady = decodeData(data: movieData) {
                        moviesReady.append(movieReady)
                    }
                }
            }
            return (moviesReady, context, data)
        } catch {
            print(error)
            return ([Movie](), context, [MovieSaved]())
        }
    }

    func receiveAllData() -> [Movie] {
        return receiveData(id: nil).0
    }
    
    func getSavedMovieIds() -> [Int] {
        var ids = [Int]()
        let movies = receiveAllData()
        for item in movies {
            ids.append(item.id)
        }
        return ids
    }
    
    func receiveItem(_ id: Int) -> Movie? {
        let movies = receiveData(id: id).0
        return movies != [] ? movies[0] : nil
    }

    func saveItem(movie: Movie) {
        let context = getContext()
        let object = MovieSaved(context: context)
        object.id = Int64(movie.id)
        object.movie = encodeData(data: movie)
        saveContext(context: context)
    }
    
    func deleteItem(id: Int) {
        let dataContext = receiveData(id: id)
        if dataContext.2 != [] {
            dataContext.1.delete(dataContext.2[0])
            saveContext(context: dataContext.1)
        }
    }
}
