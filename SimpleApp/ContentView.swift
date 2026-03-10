import SwiftUI

struct ChecklistItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
}

struct ContentView: View {
    @State private var items = [
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach($items) { $item in
                    HStack {
                        Text(item.title)
                        Spacer()
                        Button(action: {
                            item.isDone.toggle()
                        }) {
                            Image(systemName: item.isDone ? "checkmark.square" : "square")
                                .foregroundColor(item.isDone ? .green : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(5)
                }
            }
            .navigationTitle("Checklist")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}