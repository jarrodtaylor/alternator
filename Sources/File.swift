import Foundation

struct File {
  let source: URL

  var target: URL {
    var targetURL: URL = Project.target!.appending(path: ref)

    if targetURL.pathExtension == "md" {
      targetURL = targetURL
        .deletingPathExtension()
        .appendingPathExtension("html")
    }

    return targetURL
  }

  var ref: String {
    source.path(percentEncoded: false)
      .removingFirstOccurrence(of: Project.source!.path())
      .asRef
  }

  func build() throws {
    guard try isModified else { return }

    if target.exists {
      try FileManager.default.removeItem(at: target)
    }

    try FileManager.default.createDirectory(
      atPath: target.deletingLastPathComponent().path(percentEncoded: false),
      withIntermediateDirectories: true)

    if source.isRenderable {
      log("[build] rendering \(source.masked) -> \(target.masked)")
      FileManager.default.createFile(
        atPath: target.path(percentEncoded: false),
        contents: try render().data(using: .utf8))
    }

    else {
      log("[build] copying \(source.masked) -> \(target.masked)")
      try source.touch()
      try FileManager.default.copyItem(at: source, to: target)
      try target.touch()
    }
  }
}

fileprivate extension File {
  var isModified: Bool {
    get throws {
      guard
        target.exists,
        let sourceModDate = try source.modificationDate,
        let targetModDate = try target.modificationDate,
        targetModDate > sourceModDate
      else { return true }

      for dependency in try source.dependencies {
        if let dependencyModDate = try dependency.source.modificationDate,
          dependencyModDate > targetModDate,
          try dependency.isModified
        { return true }
      }

      return false
    }
  }

  func render(_ context: [String: String] = [:]) throws -> String {
    var context = context
    for (key, val) in try source.context { context[key] = val }
    var text = try source.contents

    if context["#forceLayout"] == "true" || context["#isIncluding"] != "true",
      let layoutRef = context["#layout"],
      let layoutFile = Project.file(layoutRef)
    {
      let macro = Layout(template: layoutFile, content: text)

      for (key, value) in try macro.context {
        if context[key] == nil { context[key] = value }
      }

      text = try macro.render()
    }

    for match in text.find(Include.pattern) {
      let macro = Include(fragment: match)

      if macro.file?.source.exists == true {
        var params = macro.parameters

        for (key, value) in params {
          if let val = context[value] { params[key] = val }
        }

        params["#isIncluding"] = "true"

        text = text.replacingFirstOccurrence(
          of: match,
          with: try macro.file!.render(params))
      }
    }

    for match in text.find(Variable.pattern) {
      let macro = Variable(fragment: match)

      if let value = context.contains(where: { $0.key == macro.key })
      ? context[macro.key]
      : macro.defaultValue
      {
        text = text.replacingFirstOccurrence(
          of: match,
          with: value as String)
      }
    }

    return text
  }
}

extension URL {
  var dependencies: [File] {
    get throws {
  		guard isRenderable else { return [] }

   	  var deps: [File?] = []

     	for match in try contents.find(Include.pattern) {
  		  deps.append(Include(fragment: match).file)
      }

      if let ref = try context["#layout"] {
  		  deps.append(Project.file(ref))
      }

      return deps
  		  .filter { $0 != nil && $0!.source.exists == true }
  			.map { $0! }
    }
  }

  var isRenderable: Bool {
    ["css", "htm", "html", "js", "md", "rss", "svg", "xml"]
      .contains(pathExtension)
  }

  var modificationDate: Date? {
    get throws {
      try FileManager.default
        .attributesOfItem(atPath: self.path(percentEncoded: false))[FileAttributeKey.modificationDate] as? Date
    }
	}

  func touch() throws {
    var file = self
    var resourceValues = URLResourceValues()
    resourceValues.contentModificationDate = Date()
    try file.setResourceValues(resourceValues)
  }
}
