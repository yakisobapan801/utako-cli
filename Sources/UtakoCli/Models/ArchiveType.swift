import Foundation

enum ArchiveType: CaseIterable {
    case stream
    case video
    case short
    case membership
    case external

    var archiveFileName: String {
        switch self {
        case .stream:
            return "processed-all-streams"
        case .video:
            return "processed-all-videos"
        case .short:
            return "processed-all-shorts"
        case .membership:
            return "processed-from-membership"
        case .external:
            return "processed-external"
        }
    }
}
