import Foundation

struct PlaylistItemsResponse: Decodable {
    let nextPageToken: String?
    let items: [Item]

    struct Item: Decodable {
        let snippet: Snippet
        let contentDetails: ContentDetails
    }

    struct Snippet: Decodable {
        let publishedAt: String
        let title: String
    }

    struct ContentDetails: Decodable {
        let videoId: String
    }
}
