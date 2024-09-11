import Foundation
import Network

final class Server: Sendable {
  private let callback: @Sendable (Request?, Response?, NWError?) -> Void
	private let listener: NWListener
	private let path: String

	@discardableResult init(
	  path: String,
		port: NWEndpoint.Port,
		callback: @escaping @Sendable (Request?, Response?, NWError?) -> Void)
	{
		self.callback = callback
		self.path = path
		self.listener = try! NWListener(using: .tcp, on: port)
		listener.newConnectionHandler = handleConnection
		listener.start(queue: .main)
	}

	@Sendable private func handleConnection(_ connection: NWConnection) {
		connection.start(queue: .main)
		receive(from: connection)
	}

	private func receive(from connection: NWConnection) {
		connection.receive(
		  minimumIncompleteLength: 1,
			maximumLength: connection.maximumDatagramSize
		) { content, _, isComplete, error in
			if let error { self.callback(nil, nil, error) }
			else if let content, let request = Request(content) {
				self.respond(on: connection, request: request)
			}
			if !isComplete { self.receive(from: connection) }
		}
	}

	private func respond(on connection: NWConnection, request: Request) {
		guard request.method == "GET" else {
			let response = Response(.teapot)
			self.callback(request, response, nil)
			connection.send(content: response.data, completion: .idempotent)
			return
		}

		func findFile(_ filePath: String) -> String? {
			guard let foundPath = [filePath, filePath + "/index.html", filePath + "index.htm"]
				.first(where: {
					var isDirectory: ObjCBool = false
					return FileManager.default.fileExists(atPath: $0, isDirectory: &isDirectory)
					? !isDirectory.boolValue
					: false
				})
			else { return nil }

			return foundPath
		}

		guard
		  let filePath = findFile(self.path + request.path),
			let response = try? Response(filePath: filePath)
		else {
			let response = Response(.notFound)
			callback(request, response, nil)
			connection.send(content: response.data, completion: .idempotent)
			return
		}

		callback(request, response, nil)
		connection.send(content: response.data, completion: .idempotent)
	}
}

extension URL {
  func serve(
    port: NWEndpoint.Port,
    callback: @escaping @Sendable (Request?, Response?, NWError?) -> Void)
  {
    Server(path: masked, port: port, callback: callback)
  }
}
