import Foundation

class MainViewModel: MainViewModelType {
    var updateCollection = Box(false)
    var movieForDetailsScreen = Box(MovieDetails())
    var alert = Box(NetworkError.success)
    private var moviesCollectionList = [MovieCollectionItem]()
    private var reservedArrayForEmptySearch = [MovieCollectionItem]()
    private var savedMovieIdsList = [Int]()
    private var moviesNetList = [MovieNet]() {
        didSet {
            DispatchQueue.main.async {
                self.convertNetToCollectionList()
            }
        }
    }
    private var allGenresList = [Genre]()
    
    func getNumberOfCells() -> Int {
        return moviesCollectionList.count
    }
    
    func getMovieForIndexPath(indexPath: Int) -> MovieCollectionItem {
        return moviesCollectionList[indexPath]
    }
    
    func updateAllData(fromNetwork: Bool) {
        savedMovieIdsList = CoreDataManager.data.getSavedMovieIds()
        if fromNetwork {
            NetworkManager.data.getAllData { [weak self] movies, allGenres, error in
                if error == NetworkError.success {
                    self?.moviesNetList = movies
                    self?.allGenresList = allGenres
                } else {
                    self?.alert.value = error
                }
            }
        } else {
            convertNetToCollectionList()
        }
    }
    
    func getImageForCell(indexPath: Int, completitionHandler: @escaping (Data?) -> Void) {
        NetworkManager.data.getImage(link: moviesCollectionList[indexPath].backgroundImage) { data in
            completitionHandler(data)
        }
    }
    
    func openDetailsScreen(indexPath: Int) {
        let collectionMovie = moviesCollectionList[indexPath]
        NetworkManager.data.getImage(link: collectionMovie.posterImage) { poster in
            for item in self.moviesNetList where item.id == collectionMovie.id {
                let detailsMovie = MovieDetails(model: item, poster: poster, allGenresList: self.allGenresList)
                DispatchQueue.main.async {
                    self.movieForDetailsScreen.value = detailsMovie
                }
            }
        }
    }
        
    func markMovie(movie: MovieCollectionItem) -> Bool {
        if CoreDataManager.data.receiveItem(movie.id) == nil {
            for item in moviesNetList where item.id == movie.id {
                var poster: Data?
                var background: Data?
                let group = DispatchGroup()
                group.enter()
                NetworkManager.data.getImage(link: item.posterImage) { image in
                    poster = image
                    group.leave()
                }
                group.enter()
                NetworkManager.data.getImage(link: item.backgroundImage) { image in
                    background = image
                    group.leave()
                }
                
                group.notify(queue: .main) {
                    let movie = MovieCoreData(model: item, allGenresList: self.allGenresList, background: background, poster: poster)
                    CoreDataManager.data.saveItem(movie: movie)
                    self.savedMovieIdsList.append(movie.id)
                    self.changeState(id: movie.id, state: true)
                }
            }
            return true
        } else {
            CoreDataManager.data.deleteItem(id: movie.id)
            if let index = savedMovieIdsList.firstIndex(of: movie.id) {
                savedMovieIdsList.remove(at: index)
            }
            changeState(id: movie.id, state: false)
            return false
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

    private func changeState(id: Int, state: Bool) {
        for (index, value) in moviesCollectionList.enumerated() where value.id == id {
            moviesCollectionList[index].state = state
        }
    }
    
    private func convertNetToCollectionList() {
       
        var array = [MovieCollectionItem]()
        
        for item in moviesNetList {
            array.append(MovieCollectionItem(model: item, allGenresList: allGenresList, savedIdsArray: savedMovieIdsList))
        }
        moviesCollectionList = array
        reservedArrayForEmptySearch = moviesCollectionList
        if !moviesCollectionList.isEmpty {
            updateCollection.value = true
        }
    }
}
