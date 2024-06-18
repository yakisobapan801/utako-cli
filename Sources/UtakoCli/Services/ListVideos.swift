import Foundation

class ListVideos {
    enum Error: Swift.Error {
        case invalidBaseURL
        case failedToBuildRequest([String])
        case failedToRequest(URLResponse)
    }

    func load(_ videoIds: [String], credentials: Credentials) async throws -> [OutputVideo] {
        guard let baseURL = URL(string: "https://www.googleapis.com/youtube/v3/videos") else {
            throw Error.invalidBaseURL
        }

        var allItems: [OutputVideo] = []

        for ids in videoIds.chunked(into: 20) {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
            components.queryItems = [
                URLQueryItem(name: "key", value: credentials.apiKey),
                URLQueryItem(name: "id", value: ids.joined(separator: ",")),
                URLQueryItem(name: "part", value: "contentDetails,id,liveStreamingDetails,localizations,player,recordingDetails,snippet,statistics,status,topicDetails")
            ]

            guard let url = components.url else {
                throw Error.failedToBuildRequest(ids)
            }

            let (data, response) = try await URLSession.shared.data(for: .init(url: url))
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                throw Error.failedToRequest(response)
            }

            let decoder = JSONDecoder()
            let items = try decoder.decode(VideosResponse.self, from: data).items

            let processedItems = items.map { OutputVideo(from: $0) }
            allItems.append(contentsOf: processedItems)
        }

        return allItems.sorted { $0.time.startAt < $1.time.startAt }
    }
}
