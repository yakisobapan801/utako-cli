import Foundation

class ListChannel {
    enum Error: Swift.Error {
        case failedToBuildRequest([String])
        case failedToLoadChannels([String])
        case failedToRequest(URLResponse)
    }

    func load(_ channelIds: [String], credentials: Credentials) async throws -> [OutputChannel] {
        guard let baseURL = URL(string: "https://www.googleapis.com/youtube/v3/channels") else {
            throw Error.failedToLoadChannels(channelIds)
        }

        var allItems: [OutputChannel] = []

        for ids in channelIds.chunked(into: 20) {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
            components.queryItems = [
                URLQueryItem(name: "key", value: credentials.apiKey),
                URLQueryItem(name: "id", value: ids.joined(separator: ",")),
                URLQueryItem(name: "part", value: "snippet,id,contentDetails,statistics,status,contentOwnerDetails,topicDetails"),
            ]

            guard let url = components.url else {
                throw Error.failedToBuildRequest(ids)
            }

            let (data, response) = try await URLSession.shared.data(for: .init(url: url))
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                throw Error.failedToRequest(response)
            }

            let decoder = JSONDecoder()
            let items = try decoder.decode(ChannelResponse.self, from: data).items

            let processedItems = items.map { OutputChannel(from: $0) }
            allItems.append(contentsOf: processedItems)
        }

        return allItems
    }
}
