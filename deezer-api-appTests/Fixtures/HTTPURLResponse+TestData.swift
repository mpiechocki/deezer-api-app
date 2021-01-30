import Foundation

extension HTTPURLResponse {

    static var success: HTTPURLResponse {
        HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    static var forbidden: HTTPURLResponse {
        HTTPURLResponse(url: URL(fileURLWithPath: ""), statusCode: 403, httpVersion: nil, headerFields: nil)!
    }

}
