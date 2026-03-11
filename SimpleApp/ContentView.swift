import SwiftUI

// MARK: - Models

struct ChecklistItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
}

struct NoteItem: Identifiable {
    let id = UUID()
    var title: String
    var body: String
    var date: Date = Date()
}

// MARK: - Main App Entry

@main
struct ProductivityApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

// MARK: - Tab View

struct MainTabView: View {
    @StateObject private var store = AppStore()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ChecklistView()
                .tabItem {
                    Label("Checklist", systemImage: "checkmark.square.fill")
                }

            FocusView()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }

            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
        }
        .accentColor(.red)
        .environmentObject(store)
    }
}

// MARK: - App Store

class AppStore: ObservableObject {
    @Published var checklistItems: [ChecklistItem] = []
    @Published var notes: [NoteItem] = []

    var completedCount: Int { checklistItems.filter { $0.isDone }.count }
    var totalCount: Int { checklistItems.count }
    var progress: Double {
        totalCount == 0 ? 0 : Double(completedCount) / Double(totalCount)
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var store: AppStore

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Hero Card
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "1a1a2e"), Color(hex: "0f3460")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(Date(), style: .date)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)

                            Text("\(greeting) 👋")
                                .font(.system(size: 26, weight: .bold, design: .serif))
                                .foregroundColor(.white)

                            HStack(spacing: 12) {
                                ProgressView(value: store.progress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .red))
                                    .frame(maxWidth: .infinity)

                                Text("\(store.completedCount)/\(store.totalCount)")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(20)
                    }
                    .padding(.horizontal)

                    // Stats Row
                    HStack(spacing: 12) {
                        StatCard(icon: "📋", value: "\(store.totalCount)", label: "Tasks")
                        StatCard(icon: "✅", value: "\(store.completedCount)", label: "Done")
                        StatCard(icon: "📝", value: "\(store.notes.count)", label: "Notes")
                    }
                    .padding(.horizontal)

                    // Recent Tasks
                    if !store.checklistItems.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Tasks")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .padding(.horizontal)

                            ForEach(store.checklistItems.suffix(4).reversed()) { item in
                                HStack(spacing: 10) {
                                    Image(systemName: item.isDone ? "checkmark.square.fill" : "square")
                                        .foregroundColor(item.isDone ? .green : .gray)
                                    Text(item.title)
                                        .strikethrough(item.isDone)
                                        .foregroundColor(item.isDone ? .secondary : .primary)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        VStack(spacing: 8) {
                            Text("🚀")
                                .font(.system(size: 48))
                            Text("You're all clear!")
                                .font(.headline)
                            Text("Add tasks in the Checklist tab.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(40)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("FlowDesk")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(icon).font(.title2)
            Text(value).font(.title2.bold())
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

// MARK: - Checklist View

struct ChecklistView: View {
    @EnvironmentObject var store: AppStore
    @State private var newItemTitle: String = ""

    var pending: [ChecklistItem] { store.checklistItems.filter { !$0.isDone } }
    var done: [ChecklistItem]    { store.checklistItems.filter {  $0.isDone } }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Add bar
                HStack(spacing: 10) {
                    TextField("Add a new task...", text: $newItemTitle)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .onSubmit { addItem() }

                    Button(action: addItem) {
                        Text("Add")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(colors: [.red, Color.orange],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                List {
                    if !pending.isEmpty {
                        Section(header: Text("To Do · \(pending.count)")) {
                            ForEach(pending) { item in
                                ChecklistRow(item: item)
                            }
                            .onDelete { offsets in
                                let ids = offsets.map { pending[$0].id }
                                store.checklistItems.removeAll { ids.contains($0.id) }
                            }
                        }
                    }

                    if !done.isEmpty {
                        Section(header: Text("Completed · \(done.count)")) {
                            ForEach(done) { item in
                                ChecklistRow(item: item)
                            }
                            .onDelete { offsets in
                                let ids = offsets.map { done[$0].id }
                                store.checklistItems.removeAll { ids.contains($0.id) }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Checklist")
            .background(Color(.systemGroupedBackground))
        }
    }

    func addItem() {
        let trimmed = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.checklistItems.append(ChecklistItem(title: trimmed, isDone: false))
        newItemTitle = ""
    }
}

struct ChecklistRow: View {
    @EnvironmentObject var store: AppStore
    let item: ChecklistItem

    var body: some View {
        HStack {
            Text(item.title)
                .strikethrough(item.isDone)
                .foregroundColor(item.isDone ? .secondary : .primary)
            Spacer()
            Button {
                if let idx = store.checklistItems.firstIndex(where: { $0.id == item.id }) {
                    store.checklistItems[idx].isDone.toggle()
                }
            } label: {
                Image(systemName: item.isDone ? "checkmark.square.fill" : "square")
                    .foregroundColor(item.isDone ? .green : .gray)
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Focus / Pomodoro View

struct FocusView: View {
    @State private var mode: FocusMode = .work
    @State private var timeRemaining: Int = 25 * 60
    @State private var isRunning = false
    @State private var timer: Timer? = nil

    enum FocusMode: String, CaseIterable {
        case work = "🎯 Focus"
        case shortBreak = "☕ Break"

        var duration: Int {
            switch self {
            case .work: return 25 * 60
            case .shortBreak: return 5 * 60
            }
        }
    }

    var progress: Double {
        1.0 - Double(timeRemaining) / Double(mode.duration)
    }

    var timeString: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {

                // Mode Picker
                Picker("Mode", selection: $mode) {
                    ForEach(FocusMode.allCases, id: \.self) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: mode) { _ in resetTimer() }

                // Ring Timer
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 12)
                        .frame(width: 200, height: 200)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: mode == .work ? [.red, .orange] : [.green, .mint],
                                startPoint: .leading, endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)

                    VStack(spacing: 4) {
                        Text(timeString)
                            .font(.system(size: 44, weight: .bold, design: .monospaced))
                        Text(mode == .work ? "Focus Time" : "Break")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                    }
                }

                // Controls
                HStack(spacing: 16) {
                    Button(action: resetTimer) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray6))
                            .cornerRadius(14)
                    }

                    Button(action: toggleTimer) {
                        Text(isRunning ? "⏸ Pause" : "▶ Start")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(colors: [.red, .orange],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(14)
                            .shadow(color: .red.opacity(0.3), radius: 8, y: 4)
                    }
                }

                // Info Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("How Pomodoro Works")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    Text("Work for **25 minutes**, then take a **5 minute break**. After 4 sessions, take a longer break. Repeat to stay in flow! 🍅")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Focus")
            .background(Color(.systemGroupedBackground))
        }
    }

    func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
            isRunning = false
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                    isRunning = false
                }
            }
        }
    }

    func resetTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = mode.duration
    }
}

// MARK: - Notes View

struct NotesView: View {
    @EnvironmentObject var store: AppStore
    @State private var showingNewNote = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                if store.notes.isEmpty {
                    VStack(spacing: 8) {
                        Text("📝").font(.system(size: 52))
                        Text("No notes yet").font(.headline)
                        Text("Tap + to create your first note.")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .padding(60)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach($store.notes) { $note in
                            NavigationLink(destination: NoteEditorView(note: $note)) {
                                NoteCard(note: note)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.notes.append(NoteItem(title: "Untitled Note", body: ""))
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.red)
                            .imageScale(.large)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct NoteCard: View {
    let note: NoteItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
                .lineLimit(2)

            Text(note.body.isEmpty ? "Empty note" : note.body)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(4)

            Spacer()

            Text(note.date, style: .date)
                .font(.system(size: 10))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding()
        .frame(minHeight: 120, alignment: .topLeading)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}

struct NoteEditorView: View {
    @Binding var note: NoteItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Title", text: $note.title)
                .font(.title2.bold())
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Divider().padding(.horizontal)

            TextEditor(text: $note.body)
                .font(.body)
                .padding(.horizontal, 12)
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
    }
}

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
