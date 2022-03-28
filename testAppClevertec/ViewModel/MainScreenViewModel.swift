import Foundation

class MainScreenViewModel: MainFavoritesViewModelType {
    var readyMoviesList = Box([(Movie, Bool)]())
    var stateForCell = Box(false)
    var alert = Box(AlertType.noConnection)
    private var moviesList = [Movie]() {
        didSet {
            DispatchQueue.main.async {
                self.openMoviesList = self.moviesList
                self.handleConnectionProblems()
            }
        }
    }
    private var openMoviesList = [Movie]() {
        didSet {
            updateReadyMovieList()
        }
    }
    private var savedMovieIds = [Int]()
    private struct DateFormatConstants {
        static let before = "yyyy-MM-dd"
        static let after = " yyyy"
        static let incorrectData = ""
    }

    func allDataWillUpdate() {
        NetworkManager.data.getAllData { [weak self] movies in
            self?.moviesList = movies
        }
    }
    
    func savedDataWillUpdate() {
        savedMovieIds = CoreDataManager.data.getSavedMovieIds()
        if readyMoviesList.value.count != 0 {
            updateReadyMovieList()
        }
    }
    
    func movieMarked(movie: Movie?) {
        guard let movie = movie else { return }
        if CoreDataManager.data.receiveItem(movie.id) == nil {
            CoreDataManager.data.saveItem(movie: movie)
            savedMovieIds.append(movie.id)
            stateForCell.value = true
        } else {
            CoreDataManager.data.deleteItem(id: movie.id)
            if let index = savedMovieIds.firstIndex(of: movie.id) {
                savedMovieIds.remove(at: index)
            }
            stateForCell.value = false
        }
        savedDataWillUpdate()
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
    
    private func updateReadyMovieList () {
        var tempList = [(Movie, Bool)]()
        for item in openMoviesList {
            var state = false
            for id in savedMovieIds where id == item.id {
                state = true
            }
            tempList.append((changeToDisplay(item: item), state))
        }
        readyMoviesList.value = tempList
    }
    
    private func handleConnectionProblems() {
        if moviesList.isEmpty {
            alert.value = AlertType.noConnection
        }
    }
    
    private func changeToDisplay(item: Movie) -> Movie {
        var newItem = item
        newItem.released = dateFormatter(item.released)
        if let genres = item.genresReady {
            newItem.genresReady?.append(Array(genres.prefix(2)).reduce("", { $0 + $1 + " " }))
        }
        return newItem
    }
    
    private func dateFormatter(_ date: String?) -> String {
        guard let date = date else {return DateFormatConstants.incorrectData}
        let formatterDate = DateFormatter()
        formatterDate.dateFormat = DateFormatConstants.before
        guard let year = formatterDate.date(from: date) else { return DateFormatConstants.incorrectData }
        formatterDate.dateFormat = DateFormatConstants.after
        return formatterDate.string(from: year)
    }
}
