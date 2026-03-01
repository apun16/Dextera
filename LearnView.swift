import SwiftUI

struct Learn: View {
    var body: some View {
        AboutParkinsons()
    }
}

struct Learn_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { Learn() }
    }
}
