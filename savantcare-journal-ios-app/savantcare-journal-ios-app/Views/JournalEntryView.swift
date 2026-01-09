import SwiftUI

struct JournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
    @State private var content: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var showSuccess = false
    
    @State private var currentEntry: JournalEntry?
    @State private var lastSavedContent: String = ""
    
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Journal Entry")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                        .focused($isTextEditorFocused)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: JournalListView(viewModel: viewModel)) {
                        Text("List View")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            if !content.isEmpty && content != lastSavedContent {
                                await autoSave()
                            }
                            resetForm()
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: content) { newValue in
                Task {
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second debounce
                    if newValue == content {
                        await autoSave()
                    }
                }
            }
            .onAppear {
                // Add a small delay to ensure view is fully loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextEditorFocused = true
                }
            }
        }
    }
    
    private func autoSave() async {
        guard !content.isEmpty else { return }
        guard content != lastSavedContent else { return }
        
        if var entry = currentEntry {
            // Update existing
            entry.content = content
            let success = await viewModel.updateEntry(entry)
            if success {
                lastSavedContent = content
                currentEntry = entry
            }
        } else {
            // Create new
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            let defaultTitle = "Entry - \(formatter.string(from: Date()))"
            
            if let newEntry = await viewModel.createEntry(
                title: defaultTitle,
                content: content,
                mood: "😊",
                symptoms: nil,
                medications: nil
            ) {
                currentEntry = newEntry
                lastSavedContent = content
            }
        }
    }
    
    private func resetForm() {
        content = ""
        currentEntry = nil
        lastSavedContent = ""
    }
}

#Preview {
    JournalEntryView(viewModel: JournalViewModel())
}