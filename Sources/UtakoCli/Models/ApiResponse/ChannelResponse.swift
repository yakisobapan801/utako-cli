import Foundation

struct ChannelResponse: Decodable {
    let items: [Item]

    struct Item: Decodable {
        let id: String
        let snippet: Snippet
    }

    struct Snippet: Decodable {
        let title: String
        let description: String
        let customUrl: String
        let thumbnails: [String: Thumbnails]
    }
}
