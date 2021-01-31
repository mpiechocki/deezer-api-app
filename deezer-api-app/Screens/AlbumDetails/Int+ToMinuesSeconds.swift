extension Int {

    var toMinuesSeconds: (m: Int, s: Int) {
        ((self / 60), self % 60)
    }

}
