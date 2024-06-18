import Foundation

struct OutputVideo : Encodable {
    let id: String
    let url: String
    let title: String
    let description: String
    let statistics: Statistics
    let thumbnails: [String: Thumbnails]
    let time: Time
    let channelId: String

    struct Statistics : Encodable {
        let viewCount: Int
        let likeCount: Int
        let commentCount: Int
    }

    struct Time: Encodable {
        let startAt: String
        let duration: Int
    }
}

extension OutputVideo {

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

    // utc時間を日本時間に変換する
    static func toJapanTime(_ datetime: String) -> String {
        let date = inputDateFormatter.date(from: datetime)!
        return outputDateFormatter.string(from: date)
    }

    init(from: VideosResponse.Item) {
        id = from.id
        url = from.url
        title = from.snippet.title
        description = from.snippet.description
        statistics = Statistics(viewCount: Int(from.statistics.viewCount!)!, likeCount: Int(from.statistics.likeCount)!, commentCount: Int(from.statistics.commentCount ?? "0")!)
        thumbnails = from.snippet.thumbnails
        time = Time(startAt: Self.adjustedStartAt(from: from), duration: from.contentDetails.duration.value)
        channelId = from.snippet.channelId
    }

    private static func adjustedStartAt(from: VideosResponse.Item) -> String {
        // 元メン限動画のうち、公開日時が不明なものを補完するためのリスト
        // 動画についている最速コメントの日時から逆算していい感じの時刻を計算した
        let datetimes: [String: String] = [
            "pnIeqauQC7c": "2023-02-28T00:10:00",
            "H5uPT4VB_Gw": "2023-12-02T00:30:00",
            "Bbi-di4G8wg": "2023-08-31T00:30:00",
            "rP_pf2EK7Ug": "2023-03-31T18:15:00",
            "50rymakPi9A": "2023-03-25T00:15:00",
            "hzOXDeDCdeA": "2023-06-14T23:30:00",
        ]

        return datetimes[from.id] ?? Self.toJapanTime(from.liveStreamingDetails?.actualStartTime ?? from.snippet.publishedAt)
    }
}
