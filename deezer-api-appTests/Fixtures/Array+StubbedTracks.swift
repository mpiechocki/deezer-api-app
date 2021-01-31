@testable import deezer_api_app

extension Array where Element == Track {

    static var stubbedTracks: [Track] {
        [
            Track(title: "Second Hand News", duration: 120, trackPosition: 1, diskNumber: 1),
            Track(title: "Dreams", duration: 180, trackPosition: 2, diskNumber: 1),
            Track(title: "Never Going Back Again", duration: 431, trackPosition: 3, diskNumber: 3)
        ]
    }

}
