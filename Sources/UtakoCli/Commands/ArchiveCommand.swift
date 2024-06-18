import ArgumentParser
import Foundation
import RegexBuilder

struct ArchiveCommand: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "archive")

    @Option(name: .customLong("credentials")) var credentialsFile: String
    @Option(name: .customLong("destination")) var destinationPath: String

    var destinationBaseUrl: URL {
        URL(filePath: destinationPath)
    }

    func run() async throws {
        let destinationBaseUrl = URL(filePath: destinationPath)
        let credentials: Credentials = try loadJson(path: credentialsFile)

        let idResolver = VideoIdResolver(credentials: credentials)
        let videoLoader = ListVideos()
        let channelLoader = ListChannel()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        try FileManager.default.createDirectory(at: destinationBaseUrl, withIntermediateDirectories: true)

        // ビデオ情報書き出し
        var allVideos: [OutputVideo] = []
        for type in ArchiveType.allCases {
            let ids = try await idResolver.ids(type: type)
            let videos = try await videoLoader.load(ids, credentials: credentials)
            let url = destinationBaseUrl.appending(path: type.archiveFileName).appendingPathExtension("json")

            print("writing \(type)(\(videos.count)) to \(url.absoluteString)")
            
            let data = try encoder.encode(videos)
            try data.write(to: url)

            allVideos.append(contentsOf: videos)
        }

        // チャンネル情報書き出し
        let channelIds = Array(Set(allVideos.map(\.channelId)))
        let channels = try await channelLoader.load(channelIds, credentials: credentials)
        let channelUrl = destinationBaseUrl.appending(path: "processed-channels").appendingPathExtension("json")

        print("writing channels(\(channels.count)) to \(channelUrl.absoluteString)")

        let data = try encoder.encode(channels)
        try data.write(to: channelUrl)
    }
}
