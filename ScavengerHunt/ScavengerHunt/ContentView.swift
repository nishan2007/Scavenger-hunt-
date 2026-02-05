import SwiftUI

struct ContentView: View {
    @StateObject private var store = TaskStore()

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.tasks) { task in
                    NavigationLink {
                        TaskDetailView(taskID: task.id)
                            .environmentObject(store)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .font(.headline)
                                Text(task.details)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if task.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Scavenger Hunt")
        }
    }
}

#Preview {
    ContentView()
}
