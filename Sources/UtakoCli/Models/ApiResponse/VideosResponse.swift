import Foundation
import RegexBuilder

struct VideosResponse: Decodable {
    let items: [Item]

    enum Error: Swift.Error {
        case duration(String)
    }

    struct Item: Decodable {
        let id: String
        let snippet: Snippet
        let contentDetails: ContentDetails
        let statistics: Statistics
        let liveStreamingDetails: LiveStreamingDetails?

        var url: String {
            "https://www.youtube.com/watch?v=\(id)"
        }

        struct Snippet : Decodable {
            let channelId: String
            let publishedAt: String
            let title: String
            let description: String
            let thumbnails: [String: Thumbnails]
        }

        struct ContentDetails : Decodable {
            let duration: Duration
        }

        struct Statistics : Decodable {
            let viewCount: String?
            let likeCount: String
            let commentCount: String?
        }

        struct LiveStreamingDetails : Decodable {
            let actualStartTime: String
            let actualEndTime: String
        }

        struct Duration : Decodable {

            let value: Int
            init(from decoder: any Decoder) throws {
                let container = try decoder.singleValueContainer()

                let content = try container.decode(String.self)

                let regex = Regex {
                    "PT"
                    Optionally {
                        TryCapture {
                            OneOrMore(.digit)
                        } transform: { str -> Int in
                            return Int(str)!
                        }
                        "H"
                    }
                    Optionally {
                        TryCapture {
                            OneOrMore(.digit)
                        } transform: { str -> Int in
                            return Int(str)!
                        }
                        "M"
                    }
                    Optionally {
                        TryCapture {
                            OneOrMore(.digit)
                        } transform: { str -> Int in
                            return Int(str)!
                        }
                        "S"
                    }
                }

                guard let match = content.firstMatch(of: regex) else {
                    throw Error.duration(content)
                }
                value = (match.output.1 ?? 0) * 60 * 60 + (match.output.2 ?? 0) * 60 + (match.output.3 ?? 0)
            }
        }
    }
}

