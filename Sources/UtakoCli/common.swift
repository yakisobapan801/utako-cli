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

extension DateFormatter {
    // apiの日時をパースする用のフォーマッター
    static let inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    // 日本時間で出力する用のフォーマッター
    static let outputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .init(identifier: "Asia/Tokyo")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}
