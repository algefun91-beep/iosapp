import SwiftUI

struct ContentView: View {
    @State private var count = 0
    @State private var message = "Hello, World!"

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.fill")
                .font(.system(size: 64))
                .foregroundColor(.yellow)

            Text(message)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Count: \(count)")
                .font(.title2)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                Button(action: { count -= 1 }) {
                    Label("Minus", systemImage: "minus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)

                Button(action: { count += 1 }) {
                    Label("Plus", systemImage: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
            }

            Button("Reset") {
                count = 0
                message = "Reset! 🎉"
            }
            .foregroundColor(.red)
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
