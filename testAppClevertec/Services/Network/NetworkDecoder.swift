import Foundation

class NetworkDecoder {
    static func decodeData<T: Codable>(data: Data?) -> (T?, NetworkError) {
        guard let data = data else { return (nil, NetworkError.noData) }
        do {
            let dataReady: T = try JSONDecoder().decode(T.self, from: data)
            return (dataReady, NetworkError.success)
        } catch {
            print(error)
            return (nil, NetworkError.unableToDecode)
        }
    }
}
