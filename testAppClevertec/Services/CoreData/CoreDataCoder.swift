import Foundation

class CoreDataCoder {
    static func encodeData(data: MovieCoreData) -> Data? {
        do {
            return try JSONEncoder().encode(data)
        } catch {
            print(error)
            return nil
        }
    }

    static func decodeData(data: Data) -> MovieCoreData? {
        do {
            return try JSONDecoder().decode(MovieCoreData?.self, from: data)
        } catch {
            print(error)
            return nil
        }
    }
}
