import Foundation

class URLSessionProvider {
    private enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    static func getData(currentLink: String, completionHandler: @escaping (Data?, NetworkError) -> Void) {
        guard let link = URL(string: currentLink) else {
            completionHandler(nil, NetworkError.badRequest)
            return
        }
        var request = URLRequest(url: link)
        request.httpMethod = HTTPMethod.get.rawValue
        let session = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error == nil {
                guard let data = data else {
                    completionHandler(nil, NetworkError.noData)
                    return
                }
                completionHandler(data, NetworkError.success)
            } else {
                completionHandler(nil, NetworkError.connectionProblems)
                print(error as Any)
            }
        }
        session.resume()
    }
}
