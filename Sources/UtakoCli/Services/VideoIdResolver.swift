import Foundation

class VideoIdResolver {
    enum Error: Swift.Error {
        case failedToLoadIds(String)
        case failedToLoadPlaylistItems(String)
        case failedToRequest(URLResponse)
    }

    let credentials: Credentials

    init(credentials: Credentials) {
        self.credentials = credentials
    }

    func ids(type: ArchiveType) async throws -> [String] {
        switch type {
        case .stream: return try load(name: "IDs/stream")

        case .video: return try load(name: "IDs/video")

        case .short: return try load(name: "IDs/short")

        case .membership: return try load(name: "IDs/membership")

        case .external:
            // ネタ元 https://youtube.com/playlist?list=PLzYQzp1X7nSgQs0aMQlbHRjh_B6SxjWFx
            let loader = ListPlaylistItems()
            let items = try await loader.load(palylistId: "PLvqccTT5o2dW-dkkHIsLTZA6SnLxYRFMw", credentials: credentials)
            return items.map { $0.contentDetails.videoId }
        }
    }

    private func load(name: String) throws -> [String] {
        guard let url = Bundle.module.url(forResource: name, withExtension: "txt"),
              let content = try? String(contentsOf: url)
        else {
            throw Error.failedToLoadIds(name)
        }
        return content
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
    }
}
