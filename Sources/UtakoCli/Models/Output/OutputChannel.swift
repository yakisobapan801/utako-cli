import Foundation

struct OutputChannel: Encodable {
    let id: String
    let title: String
    let description: String
    let handle: String
    let url: String
    let thumbnails: [String: Thumbnails]
}

extension OutputChannel {
    init(from: ChannelResponse.Item) {
        self.id = from.id
        self.title = from.snippet.title
        self.description = from.snippet.description
        self.handle = from.snippet.customUrl
        self.url = "https://www.youtube.com/\(from.snippet.customUrl)"
        self.thumbnails = from.snippet.thumbnails
    }
}
