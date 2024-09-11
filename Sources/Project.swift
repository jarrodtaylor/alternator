import Foundation

struct Project {
  nonisolated(unsafe) static var source: URL?
  nonisolated(unsafe) static var target: URL?

  static var sourceContainsTarget: Bool {
    target!.masked.contains(source!.masked)
  }

  static func build() {
    let manifest = source!.files
      .filter {
        guard sourceContainsTarget else { return true }
        return !$0.absoluteString.contains(target!.absoluteString) }
      .filter { $0.lastPathComponent.prefix(1) != "!" }
      .map { File(source: $0) }

    do {
      try manifest.forEach { try $0.build() }

      try target!.files
        .filter {
          !manifest
            .map { $0.target.absoluteString }
            .contains($0.absoluteString)
        }.forEach {
          log("[build] deleting \($0.masked)")
          try FileManager.default.removeItem(at: $0)
        }

      try target!.folders
        .filter { try FileManager.default
          .contentsOfDirectory(atPath: $0.path())
          .isEmpty
        }.forEach {
          log("[build] deleting \($0.masked)")
          try FileManager.default.removeItem(at: $0)
        }
    }

    catch {
      guard ["no such file", "doesn't exist", "already exists", "couldn’t be removed."]
        .contains(where: error.localizedDescription.contains)
      else {
        log("[build] Error: \(error.localizedDescription)")
        exit(1)
      }
    }
  }

  static func file(_ ref: String) -> File? {
    source!.files
      .map { File(source: $0) }
      .first(where: { $0.ref == ref })
  }
}

extension URL {
  var files: [URL] { list.filter { !$0.isDirectory } }
  var folders: [URL] { list.filter { $0.isDirectory } }

  private var isDirectory: Bool {
    (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }

  private var list: [URL] {
    guard exists else { return [] }
    return FileManager.default
      .subpaths(atPath: path())!
      .filter { !$0.contains(".DS_Store") }
      .map { appending(component: $0) }
  }
}
