import SwiftUI

struct View2: View {
    var items: [String] // array of items to display
    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
        }
    }
}


struct View2_Previews: PreviewProvider {
    static var previews: some View {
        View2(items: ["Item 1", "Item 2", "Item 3"])
    }
}
