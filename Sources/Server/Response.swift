import Foundation
import UniformTypeIdentifiers

struct Response {
  let status: Status

  private let body: Data
	private let headers: [Header: String]
	private let httpVersion = "HTTP/1.1"

	enum Header: String {
		case contentLength = "Content-Length"
		case contentType = "Content-Type"
	}

	enum Status: Int, CustomStringConvertible {
		case ok = 200
		case notFound = 404
		case teapot = 418

		var description: String {
		  switch self {
				case .ok: return "OK"
				case .notFound: return "Not Found"
				case .teapot: return "I'm a teapot"
			}
		}
	}

	var data: Data {
	  var headerLines = ["\(httpVersion) \(status.rawValue) \(status)"]
		headerLines.append(contentsOf: headers.map({ "\($0.key.rawValue): \($0.value)" }))
		headerLines.append(""); headerLines.append("")
		let header = headerLines
		  .joined(separator: "\r\n")
			.data(using: .utf8)!

		return header + body
	}

	init(_
    status: Status = .ok,
    body: Data = Data(),
    contentType: UTType? = nil,
    headers: [Header: String] = [:])
  {
    self.body = body
    self.headers = headers.merging(
      [.contentLength: String(body.count), .contentType: contentType?.preferredMIMEType]
        .compactMapValues { $0 },
      uniquingKeysWith: { _, new in new })
    self.status = status
	}

	init(filePath: String) throws {
		let url = URL(filePath: filePath)
		try self.init(
		  body: Data(contentsOf: url),
			contentType: url.resourceValues(forKeys: [.contentTypeKey]).contentType)
	}

	private init(_ text: String, contentType: UTType = .plainText) {
	  self.init(body: text.data(using: .utf8)!, contentType: contentType)
	}
}
