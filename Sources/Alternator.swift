import ArgumentParser
import Foundation
import Network

@main
struct Alternator: ParsableCommand {
  static let configuration = CommandConfiguration(
    commandName: "alternator",
    abstract: "Alternator builds simple, static sites.",
    discussion: "Visit https://jarrodtaylor.github.io/alternator to learn more.",
    version: "1.0.0")

  @Argument(help: "Path to your source directory.")
  var source: String = "."
  @Argument(help: "Path to your target directory.")
  var target: String = "<source>/_build"

  @Option(name: .shortAndLong, help: "Port for the localhost server.")
  var port: UInt16?

  mutating func run() throws {
    if target == "<source>/_build" { target = "\(source)/_build" }

    Project.source = URL(string: source.asRef, relativeTo: URL.currentDirectory())
    Project.target = URL(string: target.asRef, relativeTo: URL.currentDirectory())

    guard Project.source!.exists
    else { throw ValidationError("<source> does not exist.") }

    guard Project.source!.masked != Project.target!.masked
    else { throw ValidationError("<source> and <target> cannot be the same directory.") }

    Project.build()

    if port != nil, let port = NWEndpoint.Port(rawValue: port!) {
      Project.source!.watch { urls in
        guard !urls
          .filter({
            guard Project.sourceContainsTarget else { return true }
            return !$0.absoluteString.contains(Project.target!.absoluteString) })
          .isEmpty
        else { return }
        Project.build()
      }
      log("[watch] watching \(Project.source!.masked) for changes")

      Project.target!.serve(port: port) { req, res, err in
        var message: [String] = ["[serve]"]
        if let req { message.append(req.path) }
        if let res { message.append("(\(res.status.rawValue) \(res.status))") }
        if let err { message.append("Error: \(err)") }
        log(message.joined(separator: " "))
      }
      log("[serve] serving \(Project.target!.masked) on http://localhost:\(port)")

      log("^c to stop")
      RunLoop.current.run()
    }
  }
}
