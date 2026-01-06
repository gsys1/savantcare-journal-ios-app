import SwiftUI

struct JournalListView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingNewEntry = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.entries.isEmpty {
                    ProgressView("Loading entries...")
                        .tint(.blue)
                } else if viewModel.entries.isEmpty {
                    emptyStateView
                } else {
                    entriesList
                }
            }
            .navigationTitle("Health Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingNewEntry = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                JournalEntryView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
        }
        .task {
            await viewModel.loadEntries()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.6))
            Text("No journal entries yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Start recording your health journey")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: { showingNewEntry = true }) {
                Label("Create First Entry", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
    }
    
    private var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.entries) { entry in
                    NavigationLink(destination: EntryDetailView(entry: entry, viewModel: viewModel)) {
                        JournalEntryCard(entry: entry)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadEntries()
        }
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.mood)
                    .font(.system(size: 40))
                Spacer()
                if let date = entry.createdAt {
                    VStack(alignment: .trailing) {
                        Text(date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(date, style: .time)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(entry.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(entry.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack(spacing: 16) {
                if let symptoms = entry.symptoms, !symptoms.isEmpty {
                    Label("Symptoms", systemImage: "cross.case.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                if let medications = entry.medications, !medications.isEmpty {
                    Label("Meds", systemImage: "pills.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    JournalListView()
}