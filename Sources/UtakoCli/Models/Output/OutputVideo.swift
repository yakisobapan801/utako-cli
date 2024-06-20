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
    // utc時間を日本時間に変換する
    static func toJapanTime(_ datetime: String) -> String {
        let date = DateFormatter.inputDateFormatter.date(from: datetime)!
        return DateFormatter.outputDateFormatter.string(from: date)
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

            "U9XkQuPBI_E": "2018-03-13T12:22:00", // Mirrativ
            "b76lRoOvU_w": "2018-03-14T17:42:00", // Mirrativ
            "EvU-6hRG4Po": "2018-03-21T17:04:00", // Mirrativ
            "_GjFXdUuZ3o": "2018-04-24T12:00:00", // Mirrativ
            "FaU5ROye-fQ": "2018-04-26T17:00:00", // showroom
            "1jPlQqS8L5M": "2018-04-28T17:00:00", // showroom
            "xUZUmcGZH7I": "2018-05-07T12:09:00", // Mirrativ
            "bmQrl8p_upM": "2018-05-02T17:00:00", // showroom
            "3KEZjSj4cLY": "2018-05-04T17:00:00", // showroom
            "3mO-A9jN8dg": "2018-05-16T17:00:00", // showroom
            "Pthq1oQOiN4": "2018-05-09T18:03:00", // Mirrativ
            "fBcEHp7U-pA": "2018-05-19T11:10:00", // showroom
            "QT0TLN9mhmM": "2018-06-01T17:00:00", // showroom
            "bDBMFir3jso": "2018-06-07T17:00:00", // showroom
            "el6bWP4G0t4": "2018-06-12T11:00:00", // showroom
            "FVrmNJnVVEs": "2018-06-16T17:00:00", // showroom
            "eABXEeAHs08": "2018-07-08T17:04:00", // Mirrativ
        ]

        return datetimes[from.id] ?? Self.toJapanTime(from.liveStreamingDetails?.actualStartTime ?? from.snippet.publishedAt)
    }
}
