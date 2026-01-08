import SwiftUI

struct JournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
    @State private var content: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Journal Entry")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
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
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(content.isEmpty)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Entry saved successfully!")
            }
        }
    }
    
    private func saveEntry() {
        Task {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            let defaultTitle = "Entry - \(formatter.string(from: Date()))"
            
            let success = await viewModel.createEntry(
                title: defaultTitle,
                content: content,
                mood: "😊",
                symptoms: nil,
                medications: nil
            )
            
            if success {
                resetForm()
                showSuccess = true
            } else {
                errorMessage = viewModel.errorMessage ?? "Failed to save entry"
                showError = true
            }
        }
    }
    
    private func resetForm() {
        content = ""
    }
}

#Preview {
    JournalEntryView(viewModel: JournalViewModel())
}