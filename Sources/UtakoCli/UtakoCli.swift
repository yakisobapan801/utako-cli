import Foundation
import ArgumentParser

@main
struct UtakoCli: AsyncParsableCommand {
    static var configuration: CommandConfiguration = .init(
        subcommands: [
            ArchiveCommand.self,
        ]
    )
}
