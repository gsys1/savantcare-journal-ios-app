import SwiftUI

struct EntryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
    let entry: JournalEntry
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Mood and Title
                HStack {
                    Text(entry.mood)
                        .font(.system(size: 50))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(entry.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let date = entry.createdAt {
                            Text(date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                
                // Content
                VStack(alignment: .leading, spacing: 10) {
                    Text("Journal Entry")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(entry.content)
                        .font(.body)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Symptoms
                if let symptoms = entry.symptoms, !symptoms.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Symptoms", systemImage: "heart.text.square")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(symptoms)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.red.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Medications
                if let medications = entry.medications, !medications.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Medications", systemImage: "pills.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Text(medications)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(12)
                }
                
                // Metadata
                if let createdAt = entry.createdAt {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "clock")
                            Text("Created: \(createdAt.formatted())")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        if let updatedAt = entry.updatedAt, updatedAt != createdAt {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Updated: \(updatedAt.formatted())")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditEntryView(viewModel: viewModel, entry: entry)
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("Are you sure you want to delete this entry? This action cannot be undone.")
        }
    }
    
    private func deleteEntry() {
        guard let entryId = entry.id else { return }
        
        Task {
            let success = await viewModel.deleteEntry(id: entryId)
            if success {
                dismiss()
            }
        }
    }
}

struct EditEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: JournalViewModel
    
    @State private var entry: JournalEntry
    @State private var showError = false
    @State private var errorMessage = ""
    
    let moods = ["😊", "😃", "😢", "😴", "😰", "😡", "🤒", "😷", "🤕", "😌"]
    
    init(viewModel: JournalViewModel, entry: JournalEntry) {
        self.viewModel = viewModel
        _entry = State(initialValue: entry)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entry Details")) {
                    TextField("Title", text: $entry.title)
                    
                    Picker("How are you feeling?", selection: $entry.mood) {
                        ForEach(moods, id: \.self) { mood in
                            Text(mood).tag(mood)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Journal Entry")) {
                    TextEditor(text: $entry.content)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Health Information (Optional)")) {
                    TextField("Symptoms", text: Binding(
                        get: { entry.symptoms ?? "" },
                        set: { entry.symptoms = $0.isEmpty ? nil : $0 }
                    ))
                    TextField("Medications", text: Binding(
                        get: { entry.medications ?? "" },
                        set: { entry.medications = $0.isEmpty ? nil : $0 }
                    ))
                }
            }
            .navigationTitle("Edit Entry")
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
                    .disabled(entry.title.isEmpty || entry.content.isEmpty)
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
            let success = await viewModel.updateEntry(entry)
            
            if success {
                dismiss()
            } else {
                errorMessage = viewModel.errorMessage ?? "Failed to update entry"
                showError = true
            }
        }
    }
}

#Preview {
    NavigationView {
        EntryDetailView(
            viewModel: JournalViewModel(),
            entry: JournalEntry(
                id: 1,
                patientId: "PATIENT_001",
                title: "Feeling Better Today",
                content: "Had a good day with minimal symptoms. Morning walk helped improve my mood.",
                mood: "😊",
                symptoms: "Mild headache",
                medications: "Aspirin 500mg",
                createdAt: Date(),
                updatedAt: Date()
            )
        )
    }
}