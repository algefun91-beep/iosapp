import SwiftUI

// MARK: - Models

struct ChecklistItem: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
}

// MARK: - App Store

class AppStore: ObservableObject {
    @Published var checklistItems: [ChecklistItem] = []
    @AppStorage("userName") var userName: String = "Friend"
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("dailyGoal") var dailyGoal: Int = 5

    var completedCount: Int { checklistItems.filter { $0.isDone }.count }
    var totalCount: Int { checklistItems.count }
    var pendingCount: Int { checklistItems.filter { !$0.isDone }.count }
    var progress: Double {
        totalCount == 0 ? 0 : Double(completedCount) / Double(totalCount)
    }
    var goalProgress: Double {
        dailyGoal == 0 ? 0 : min(Double(completedCount) / Double(dailyGoal), 1.0)
    }
}

// MARK: - Main App

@main
struct ProductivityApp: App {
    @StateObject private var store = AppStore()
    var body: some Scene {
        WindowGroup {
            MainTabView().environmentObject(store)
        }
    }
}

// MARK: - Tab View

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            ChecklistView()
                .tabItem { Label("Checklist", systemImage: "checkmark.square.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .accentColor(.red)
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var store: AppStore

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        else if hour < 17 { return "Good afternoon" }
        else { return "Good evening" }
    }

    var motivationalMessage: String {
        if store.totalCount == 0 { return "Add some tasks to get started!" }
        if store.completedCount == store.totalCount { return "You crushed it today! 🎉" }
        if store.goalProgress >= 1.0 { return "Daily goal smashed! Keep going 💪" }
        if store.completedCount == 0 { return "Let's get things done! 🚀" }
        return "\(store.pendingCount) task\(store.pendingCount == 1 ? "" : "s") left to go!"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // Hero greeting card
                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "1a1a2e"), Color(hex: "0f3460")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(maxWidth: .infinity, minHeight: 170)

                        Circle()
                            .fill(Color.red.opacity(0.15))
                            .frame(width: 120, height: 120)
                            .offset(x: 260, y: -60)
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .offset(x: 300, y: 20)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(greeting + ", \(store.userName)!")
                                .font(.system(size: 26, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                            Text(motivationalMessage)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            Text(Date(), style: .date)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 4)
                        }
                        .padding(24)
                    }
                    .padding(.horizontal)
                    .clipped()

                    // Stats cards
                    HStack(spacing: 12) {
                        StatCard(value: "\(store.totalCount)",     label: "Total",     icon: "list.bullet",           color: .blue)
                        StatCard(value: "\(store.completedCount)", label: "Done",      icon: "checkmark.circle.fill", color: .green)
                        StatCard(value: "\(store.pendingCount)",   label: "Remaining", icon: "clock.fill",            color: .orange)
                    }
                    .padding(.horizontal)

                    // Daily goal card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Daily Goal", systemImage: "target")
                                .font(.subheadline.bold())
                            Spacer()
                            Text("\(store.completedCount) / \(store.dailyGoal)")
                                .font(.subheadline.bold())
                                .foregroundColor(.red)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 10)
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(colors: [.red, .orange],
                                                       startPoint: .leading, endPoint: .trailing)
                                    )
                                    .frame(width: geo.size.width * store.goalProgress, height: 10)
                                    .animation(.easeInOut(duration: 0.5), value: store.goalProgress)
                            }
                        }
                        .frame(height: 10)

                        Text(store.goalProgress >= 1.0
                             ? "🎯 Goal complete!"
                             : "\(store.dailyGoal - min(store.completedCount, store.dailyGoal)) more to hit your goal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                    .padding(.horizontal)

                    // Task summary breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Summary")
                            .font(.subheadline.bold())
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            SummaryRow(label: "Tasks created",   value: store.totalCount,     icon: "plus.circle",           color: .blue)
                            Divider().padding(.leading, 44)
                            SummaryRow(label: "Completed",       value: store.completedCount, icon: "checkmark.circle.fill", color: .green)
                            Divider().padding(.leading, 44)
                            SummaryRow(label: "Still pending",   value: store.pendingCount,   icon: "circle",                color: .orange)
                            Divider().padding(.leading, 44)
                            SummaryRow(label: "Completion rate",
                                       value: store.totalCount == 0 ? 0 : Int(store.progress * 100),
                                       icon: "percent",
                                       color: .purple,
                                       suffix: "%")
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                        .padding(.horizontal)
                    }

                    // Recently completed
                    if store.completedCount > 0 {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recently Completed")
                                .font(.subheadline.bold())
                                .padding(.horizontal)

                            ForEach(store.checklistItems.filter { $0.isDone }.suffix(3).reversed()) { item in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(item.title)
                                        .strikethrough()
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
                                .padding(.horizontal)
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.title2.bold())
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

// MARK: - Summary Row

struct SummaryRow: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color
    var suffix: String = ""

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
                .padding(.leading, 14)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("\(value)\(suffix)")
                .font(.subheadline.bold())
                .padding(.trailing, 14)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Checklist View

struct ChecklistView: View {
    @EnvironmentObject var store: AppStore
    @State private var newItemTitle = ""
    @State private var showingClearConfirm = false

    var pending: [ChecklistItem] { store.checklistItems.filter { !$0.isDone } }
    var done: [ChecklistItem]    { store.checklistItems.filter {  $0.isDone } }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                                LinearGradient(colors: [.red, .orange],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                if store.checklistItems.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.square")
                            .font(.system(size: 52))
                            .foregroundColor(.secondary)
                        Text("No tasks yet")
                            .font(.headline)
                        Text("Type something above and tap Add!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        if !pending.isEmpty {
                            Section(header: Text("To Do — \(pending.count)")) {
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
                            Section(header: Text("Completed — \(done.count)")) {
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
            }
            .navigationTitle("Checklist")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !store.checklistItems.isEmpty {
                        Button("Clear All") { showingClearConfirm = true }
                            .foregroundColor(.red)
                    }
                }
            }
            .confirmationDialog("Delete all tasks?", isPresented: $showingClearConfirm, titleVisibility: .visible) {
                Button("Delete All", role: .destructive) { store.checklistItems.removeAll() }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    func addItem() {
        let trimmed = newItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.checklistItems.append(ChecklistItem(title: trimmed, isDone: false))
        newItemTitle = ""
    }
}

// MARK: - Checklist Row

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

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @State private var showingClearCompletedConfirm = false
    @State private var showingClearAllConfirm = false

    let goalOptions = [3, 5, 7, 10, 15, 20]

    var body: some View {
        NavigationView {
            List {

                // Profile
                Section(header: Text("Profile")) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.red, .orange],
                                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 52, height: 52)
                            Text(store.userName.prefix(1).uppercased())
                                .font(.title2.bold())
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.userName).font(.headline)
                            Text("\(store.completedCount) tasks completed")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)

                    HStack {
                        Label("Your Name", systemImage: "person")
                        Spacer()
                        TextField("Name", text: $store.userName)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.secondary)
                    }
                }

                // Preferences
                Section(header: Text("Preferences")) {
                    HStack {
                        Label("Daily Goal", systemImage: "target")
                        Spacer()
                        Picker("", selection: $store.dailyGoal) {
                            ForEach(goalOptions, id: \.self) { g in
                                Text("\(g) tasks").tag(g)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Toggle(isOn: $store.notificationsEnabled) {
                        Label("Notifications", systemImage: "bell")
                    }
                    .tint(.red)
                }

                // Stats
                Section(header: Text("Your Stats")) {
                    SettingsStatRow(label: "Total Tasks",     value: "\(store.totalCount)",     icon: "list.bullet",           color: .blue)
                    SettingsStatRow(label: "Completed",       value: "\(store.completedCount)", icon: "checkmark.circle.fill", color: .green)
                    SettingsStatRow(label: "Pending",         value: "\(store.pendingCount)",   icon: "clock",                 color: .orange)
                    SettingsStatRow(label: "Completion Rate",
                                   value: store.totalCount == 0 ? "—" : "\(Int(store.progress * 100))%",
                                   icon: "chart.pie.fill", color: .purple)
                }

                // Data
                Section(header: Text("Data")) {
                    Button {
                        showingClearCompletedConfirm = true
                    } label: {
                        Label("Clear Completed Tasks", systemImage: "trash")
                            .foregroundColor(.orange)
                    }
                    .confirmationDialog("Clear completed tasks?",
                                        isPresented: $showingClearCompletedConfirm,
                                        titleVisibility: .visible) {
                        Button("Clear Completed", role: .destructive) {
                            store.checklistItems.removeAll { $0.isDone }
                        }
                    }

                    Button {
                        showingClearAllConfirm = true
                    } label: {
                        Label("Clear All Tasks", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                    .confirmationDialog("Delete everything?",
                                        isPresented: $showingClearAllConfirm,
                                        titleVisibility: .visible) {
                        Button("Delete Everything", role: .destructive) {
                            store.checklistItems.removeAll()
                        }
                    }
                }

                // About
                Section(header: Text("About")) {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                    HStack {
                        Label("Built with", systemImage: "swift")
                        Spacer()
                        Text("SwiftUI").foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Settings Stat Row

struct SettingsStatRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Label(label, systemImage: icon).foregroundColor(.primary)
            Spacer()
            Text(value).font(.subheadline.bold()).foregroundColor(color)
        }
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

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView().environmentObject(AppStore())
    }
}
