import Foundation

class ListPlaylistItems {
    enum Error: Swift.Error {
        case failedToLoadPlaylistItems(String)
        case failedToRequest(URLResponse)
    }

    func load(palylistId: String, credentials: Credentials) async throws -> [PlaylistItemsResponse.Item] {
        guard let baseURL = URL(string: "https://www.googleapis.com/youtube/v3/playlistItems") else {
            throw Error.failedToLoadPlaylistItems(palylistId)
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        let commonQueryItems = [
            URLQueryItem(name: "key", value: credentials.apiKey),
            URLQueryItem(name: "playlistId", value: palylistId),
            URLQueryItem(name: "part", value: "snippet,id,contentDetails"),
            URLQueryItem(name: "maxResults", value: "50")
        ]

        var allItems: [PlaylistItemsResponse.Item] = []

        // ページングしながらデータを取得する
        var pageToken: String? = nil

        while true {
            components.queryItems = commonQueryItems + [
                URLQueryItem(name: "pageToken", value: pageToken)
            ]

            guard let url = components.url else {
                throw Error.failedToLoadPlaylistItems(palylistId)
            }

            let (data, response) = try await URLSession.shared.data(for: .init(url: url))
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                throw Error.failedToRequest(response)
            }

            let decoder = JSONDecoder()
            let responseBody = try decoder.decode(PlaylistItemsResponse.self, from: data)

            allItems.append(contentsOf: responseBody.items)

            pageToken = responseBody.nextPageToken

            if pageToken == nil {
                // ページングおわり
                break
            }
        }

        return allItems.sorted { $0.snippet.publishedAt < $1.snippet.publishedAt }
    }
}
