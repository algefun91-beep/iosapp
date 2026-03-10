import SwiftUI

struct ChecklistItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
}

struct ContentView: View {
    @State private var items: [ChecklistItem] = []
    @State private var newItemTitle: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Add new item...", text: $newItemTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                    
                    Button(action: {
                        addItem()
                    }) {
                        Text("Add")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical)
                
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
                    .onDelete { indexSet in
                        items.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("Checklist")
        }
    }
    
    func addItem() {
        let trimmed = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        items.append(ChecklistItem(title: trimmed, isDone: false))
        newItemTitle = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}