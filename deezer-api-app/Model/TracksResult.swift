struct TracksResult: Decodable, Equatable {
    let data: [Track]
    let total: Int
}
