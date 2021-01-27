import Combine
import Foundation

protocol DataTaskProvider {
    func taskPublisher(for url: URL) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLError>
}

extension URLSession: DataTaskProvider {
    func taskPublisher(for url: URL) -> AnyPublisher<DataTaskPublisher.Output, URLError> {
        dataTaskPublisher(for: url).eraseToAnyPublisher()
    }
}
