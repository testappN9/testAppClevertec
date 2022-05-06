import Foundation

class DetailsViewModel: DetailsViewModelType {
    private var movie: MovieDetails!
    var readyMovie = Box(MovieDetails())
    
    init(movie: MovieDetails) {
        self.movie = movie
    }
    
    func getMovie() {
        readyMovie.value = movie
    }
}
