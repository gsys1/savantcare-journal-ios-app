import SwiftUI

struct JournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedMood: String = "😊"
    @State private var symptoms: String = ""
    @State private var medications: String = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    let moods = ["😊", "😃", "😢", "😴", "😰", "😡", "🤒", "😷", "🤕", "😌"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entry Details")) {
                    TextField("Title", text: $title)
                    
                    Picker("How are you feeling?", selection: $selectedMood) {
                        ForEach(moods, id: \.self) { mood in
                            Text(mood).tag(mood)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Journal Entry")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Health Information (Optional)")) {
                    TextField("Symptoms", text: $symptoms)
                    TextField("Medications", text: $medications)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveEntry() {
        Task {
            let success = await viewModel.createEntry(
                title: title,
                content: content,
                mood: selectedMood,
                symptoms: symptoms.isEmpty ? nil : symptoms,
                medications: medications.isEmpty ? nil : medications
            )
            
            if success {
                dismiss()
            } else {
                errorMessage = viewModel.errorMessage ?? "Failed to save entry"
                showError = true
            }
        }
    }
}

#Preview {
    JournalEntryView(viewModel: JournalViewModel())
}