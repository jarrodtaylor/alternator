import Foundation
import Ink

extension MarkdownParser {
	nonisolated(unsafe) static let shared = MarkdownParser()
}

extension String {
  var asRef: String {
    split(separator: "/").joined(separator: "/")
  }

 	func find(_ pattern: String) -> [String] {
    let range = NSRange(location: 0, length: self.utf16.count)
		return try! NSRegularExpression(pattern: pattern)
			.matches(in: self, range: range)
			.map { (self as NSString).substring(with: $0.range) }
	}

  func removingFirstOccurrence(of: String) -> String {
    replacingFirstOccurrence(of: of, with: "")
  }

  func replacingFirstOccurrence(of: String, with: String) -> String {
    guard let range = range(of: of) else { return self }
    return replacingCharacters(in: range, with: with)
  }
}

extension URL {
  var contents: String {
    get throws {
  		if pathExtension == "md" { MarkdownParser.shared.html(from: try rawContents) }
      else if try context.isEmpty { try rawContents }
      else {
  		  try rawContents
  				.removingFirstOccurrence(of: try rawContents
            .find(#"---(\n|.)*?---\n"#)
            .first!)
      }
    }
	}

  var context: [String: String] {
    get throws {
      MarkdownParser.shared.parse(try rawContents).metadata
    }
  }

  var exists: Bool {
    var isDirectory: ObjCBool = true
    return FileManager.default
      .fileExists(atPath: path(percentEncoded: false), isDirectory: &isDirectory)
  }

  var masked: String {
    path(percentEncoded: false)
      .removingFirstOccurrence(of: FileManager.default.currentDirectoryPath)
      .removingFirstOccurrence(of: "file:///")
      .asRef
  }

  private var rawContents: String {
    get throws {
      String(decoding: try Data(contentsOf: self), as: UTF8.self)
    }
  }
}
