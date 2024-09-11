import Foundation

struct Request {
  let method: String
	let path: String

	private let httpVersion: String
	private let headers: [String: String]

	init?(_ data: Data) {
		let request = String(data: data, encoding: .utf8)!
			.components(separatedBy: "\r\n")

		guard let requestLine = request.first, request.last!.isEmpty
		else { return nil }

		let requestComponents = requestLine.components(separatedBy: " ")
		guard requestComponents.count == 3 else { return nil }

		self.method = requestComponents[0]
		self.path = requestComponents[1]
		self.httpVersion = requestComponents[2]

		let headerElements = request
		  .dropFirst()
			.map { $0.split(separator: ":", maxSplits: 1) }
			.filter { $0.count == 2 }
			.map { ($0[0].lowercased(), $0[1].trimmingCharacters(in: .whitespaces)) }

		self.headers = Dictionary(headerElements, uniquingKeysWith: { old, _ in old })
	}
}
