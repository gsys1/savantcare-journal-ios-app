import SwiftUI

struct EntryDetailView: View {
    let entry: JournalEntry
    @ObservedObject var viewModel: JournalViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(entry.mood)
                            .font(.system(size: 60))
                        Spacer()
                        VStack(alignment: .trailing) {
                            if let date = entry.createdAt {
                                Text(date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(date, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Text(entry.title)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                
                // Content Card
                VStack(alignment: .leading, spacing: 12) {
                    Label("Journal Entry", systemImage: "book.fill")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Divider()
                    
                    Text(entry.content)
                        .font(.body)
                        .lineSpacing(6)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.1), radius: 8)
                
                // Symptoms Card
                if let symptoms = entry.symptoms, !symptoms.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Symptoms", systemImage: "cross.case.fill")
                            .font(.headline)
                            .foregroundColor(.orange)
                        
                        Divider()
                        
                        Text(symptoms)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Medications Card
                if let medications = entry.medications, !medications.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Medications", systemImage: "pills.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Divider()
                        
                        Text(medications)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Update timestamp
                if let updatedAt = entry.updatedAt, 
                   let createdAt = entry.createdAt,
                   updatedAt != createdAt {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                        Text("Last updated: \(updatedAt, style: .date) at \(updatedAt, style: .time)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
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
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditEntryView(entry: entry, viewModel: viewModel)
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteEntry(entry)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this journal entry? This action cannot be undone.")
        }
    }
}

struct EditEntryView: View {
    let entry: JournalEntry
    @ObservedObject var viewModel: JournalViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var content: String
    @State private var selectedMood: String
    @State private var symptoms: String
    @State private var medications: String
    @State private var isSaving = false
    
    init(entry: JournalEntry, viewModel: JournalViewModel) {
        self.entry = entry
        self.viewModel = viewModel
        _title = State(initialValue: entry.title)
        _content = State(initialValue: entry.content)
        _selectedMood = State(initialValue: entry.mood)
        _symptoms = State(initialValue: entry.symptoms ?? "")
        _medications = State(initialValue: entry.medications ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("BASIC INFORMATION")) {
                    TextField("Title", text: $title)
                    
                    Picker("Mood", selection: $selectedMood) {
                        ForEach(Constants.Moods.all, id: \.self) { mood in
                            Text(mood).tag(mood)
                        }
                    }
                }
                
                Section(header: Text("JOURNAL ENTRY")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section(header: Text("HEALTH DETAILS (Optional)")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Symptoms", systemImage: "cross.case.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        TextField("Symptoms", text: $symptoms)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Medications", systemImage: "pills.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        TextField("Medications taken", text: $medications)
                    }
                }
                
                Section {
                    Button(action: updateEntry) {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                            } else {
                                Label("Update Entry", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                    }
                    .disabled(title.isEmpty || content.isEmpty || isSaving)
                }
            }
            .navigationTitle("Edit Entry")
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
    
    private func updateEntry() {
        var updatedEntry = entry
        updatedEntry.title = title
        updatedEntry.content = content
        updatedEntry.mood = selectedMood
        updatedEntry.symptoms = symptoms.isEmpty ? nil : symptoms
        updatedEntry.medications = medications.isEmpty ? nil : medications
        updatedEntry.updatedAt = Date()
        
        isSaving = true
        
        Task {
            let success = await viewModel.updateEntry(updatedEntry)
            isSaving = false
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationView {
        EntryDetailView(
            entry: JournalEntry(
                id: 1,
                patientId: "PATIENT_001",
                title: "Feeling Better Today",
                content: "Had a good day with minimal symptoms. Morning walk helped improve my mood.",
                mood: "😊 Happy",
                symptoms: "Mild headache",
                medications: "Aspirin 500mg",
                createdAt: Date(),
                updatedAt: Date()
            ),
            viewModel: JournalViewModel()
        )
    }
}