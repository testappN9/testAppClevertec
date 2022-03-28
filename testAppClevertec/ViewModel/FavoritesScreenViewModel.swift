import Foundation

class FavoritesScreenViewModel: MainFavoritesViewModelType {
    var readyMoviesList = Box([(Movie, Bool)]())
    var stateForCell = Box(false)
    var alert = Box(AlertType.noConnection)
    private var moviesList = [Movie]() {
        didSet {
            self.openMoviesList = self.moviesList
        }
    }
    private var openMoviesList = [Movie]() {
        didSet {
            updateReadyMovieList()
        }
    }
    private var movieForDelete: Int?

    func allDataWillUpdate() {
        moviesList = CoreDataManager.data.receiveAllData()
    }
    
    private func updateReadyMovieList () {
        var tempList = [(Movie, Bool)]()
        for item in openMoviesList {
            tempList.append((item, true))
        }
        readyMoviesList.value = tempList
    }

    func savedDataWillUpdate() {
        allDataWillUpdate()
    }

    func movieMarked(movie: Movie?) {
        if movie == nil {
            guard let id = movieForDelete else { return }
            CoreDataManager.data.deleteItem(id: id)
            movieForDelete = nil
        } else {
            alert.value = .deleteItem
            movieForDelete = movie?.id
        }
    }
    
    func searchTextUpdated(text: String?) {
        guard let string = text, !string.isEmpty else {
            openMoviesList = moviesList
            return
        }
        filterForSearchResults(string)
        func filterForSearchResults(_ text: String) {
            openMoviesList = moviesList.filter({ (movie: Movie) in
                    return movie.name?.lowercased().contains(text.lowercased()) ?? false
                })
        }
    }
}
