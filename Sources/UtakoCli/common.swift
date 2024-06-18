import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

func loadJson<T: Decodable>(path: String) throws -> T {
    let data = try Data(contentsOf: URL(filePath: path))
    let decoder = JSONDecoder()
    return try decoder.decode(T.self, from: data)
}

struct Credentials: Decodable {
    let apiKey: String
}
