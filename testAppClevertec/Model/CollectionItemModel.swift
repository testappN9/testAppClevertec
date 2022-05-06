import Foundation

struct MovieCollectionItem {
    var id: Int
    var name: String?
    var released: String?
    var genres: String?
    var backgroundImage: String?
    var posterImage: String?
    var state: Bool
    private struct DateFormatConstants {
        static let before = "yyyy-MM-dd"
        static let after = " yyyy"
        static let incorrectData = ""
    }
    
    init(model: MovieNet, allGenresList: [Genre], savedIdsArray: [Int]) {
        id = model.id
        name = model.name
        released = Self.getFormattedDate(model.released)
        genres = Self.getGenres(genres: model.genres, allGenresList: allGenresList)
        backgroundImage = model.backgroundImage
        posterImage = model.posterImage
        state = Self.getSaveState(id: model.id, savedIdsArray: savedIdsArray)
    }
   
    init(model: MovieCoreData) {
        id = model.id
        name = model.name
        released = Self.getFormattedDate(model.released)
        state = true
        guard let fullGenres = model.genres else { return }
        genres = Array(fullGenres.prefix(2)).reduce("", { $0 + $1 + " " })
    }
    
    private static func getFormattedDate(_ date: String?) -> String {
        guard let date = date else {return DateFormatConstants.incorrectData}
        let formatterDate = DateFormatter()
        formatterDate.dateFormat = DateFormatConstants.before
        guard let year = formatterDate.date(from: date) else { return DateFormatConstants.incorrectData }
        formatterDate.dateFormat = DateFormatConstants.after
        return formatterDate.string(from: year)  + "|"
    }
    
    private static func getGenres(genres: [Int]?, allGenresList: [Genre]) -> String {
        var text = ""
        guard let genres = genres else { return "" }
        for genre in genres.prefix(2) {
            for item in allGenresList where genre == item.id {
                text += ((item.name ?? "") + " ")
            }
        }
        return text
    }
    
    private static func getSaveState(id: Int, savedIdsArray: [Int]) -> Bool {
        for item in savedIdsArray where item == id {
            return true
        }
        return false
    }
}
