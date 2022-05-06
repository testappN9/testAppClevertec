import Foundation

class FavoritesViewModel: FavoritesViewModelType {
    var updateCollection = Box(true)
    var alert = Box(true)
    var movieForDetailsScreen = Box(MovieDetails())
    var indexPathItemToDelete = Box(0)
    private var moviesCollectionList = [MovieCollectionItem]()
    private var moviesCoreDataList = [MovieCoreData]()
    private var reservedArrayForEmptySearch = [MovieCollectionItem]()
    private var movieForDelete: MovieCollectionItem?
    
    func updateAllData(fromNetwork: Bool) {
        moviesCoreDataList = CoreDataManager.data.receiveAllData()
        var array = [MovieCollectionItem]()
        for item in moviesCoreDataList {
            array.append(MovieCollectionItem(model: item))
        }
        moviesCollectionList = array
        updateCollection.value = true
        reservedArrayForEmptySearch = moviesCollectionList
    }
    
    func getNumberOfCells() -> Int {
        return moviesCollectionList.count
    }
    
    func getMovieForIndexPath(indexPath: Int) -> MovieCollectionItem {
        return moviesCollectionList[indexPath]
    }

    func getImageForCell(indexPath: Int, completitionHandler: @escaping (Data?) -> Void) {
        completitionHandler(moviesCoreDataList[indexPath].backgroundImage)
    }
    
    func openDetailsScreen(indexPath: Int) {
        for item in moviesCoreDataList where item.id == moviesCollectionList[indexPath].id {
            movieForDetailsScreen.value = MovieDetails(model: item)
        }
    }
    
    func markMovie(movie: MovieCollectionItem) -> Bool {
        movieForDelete = movie
        alert.value = true
        return true
    }
    
    func deleteItem() {
        guard let movie = movieForDelete else { return }
        CoreDataManager.data.deleteItem(id: movie.id)
        for (index, value) in moviesCoreDataList.enumerated() where value.id == movie.id {
            moviesCoreDataList.remove(at: index)
            
        }
        for (index, value) in moviesCollectionList.enumerated() where value.id == movie.id {
            moviesCollectionList.remove(at: index)
            indexPathItemToDelete.value = index
        }
    }
    
    func searchTextUpdated(text: String?) {
        guard let string = text, !string.isEmpty else {
            moviesCollectionList = reservedArrayForEmptySearch
            updateCollection.value = true
            return
        }
        moviesCollectionList = reservedArrayForEmptySearch.filter({ (movie: MovieCollectionItem) in
                return movie.name?.lowercased().contains(string.lowercased()) ?? false
            })
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) ) {
            self.updateCollection.value = true
        }
    }
}
