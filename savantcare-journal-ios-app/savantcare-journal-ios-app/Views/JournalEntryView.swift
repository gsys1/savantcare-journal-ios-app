import SwiftUI

struct JournalEntryView: View {
    @ObservedObject var viewModel: JournalViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood = Constants.Moods.all[0]
    @State private var symptoms = ""
    @State private var medications = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("BASIC INFORMATION")) {
                    TextField("Title", text: $title)
                        .font(.body)
                    
                    Picker("How are you feeling?", selection: $selectedMood) {
                        ForEach(Constants.Moods.all, id: \.self) { mood in
                            Text(mood).tag(mood)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("JOURNAL ENTRY")) {
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Write about your day, feelings, or health concerns...")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                            .opacity(content.isEmpty ? 0.25 : 1)
                    }
                }
                
                Section(header: Text("HEALTH DETAILS (Optional)")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Symptoms", systemImage: "cross.case.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        TextField("e.g., Headache, fatigue, fever", text: $symptoms)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Medications", systemImage: "pills.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        TextField("e.g., Aspirin 500mg, Vitamin D", text: $medications)
                    }
                }
                
                Section {
                    Button(action: saveEntry) {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Label("Save Entry", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || content.isEmpty || isSaving)
                }
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = JournalEntry(
            patientId: Constants.PatientInfo.currentPatientId,
            title: title,
            content: content,
            mood: selectedMood,
            symptoms: symptoms.isEmpty ? nil : symptoms,
            medications: medications.isEmpty ? nil : medications,
            createdAt: Date()
        )
        
        isSaving = true
        
        Task {
            let success = await viewModel.createEntry(entry)
            isSaving = false
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    JournalEntryView(viewModel: JournalViewModel())
}