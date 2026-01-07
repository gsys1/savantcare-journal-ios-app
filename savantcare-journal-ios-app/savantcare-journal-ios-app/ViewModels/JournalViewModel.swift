import Foundation
import SwiftUI
import Combine

@MainActor
class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let apiService = APIService.shared
    
    init() {}
    
    // Get current patient ID from auth service
    var currentPatientId: String {
        return AuthService.shared.currentUserId ?? ""
    }
    
    func loadEntries() async {
        guard !currentPatientId.isEmpty else {
            errorMessage = "No user logged in"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        print("🔵 Loading entries for patient ID: \(currentPatientId)")
        
        do {
            entries = try await apiService.getEntries()
            isLoading = false
            print("✅ Loaded \(entries.count) entries")
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to load entries: \(error.localizedDescription)")
        }
    }
    
    func createEntry(title: String, content: String, mood: String, symptoms: String?, medications: String?) async -> Bool {
        guard !currentPatientId.isEmpty else {
            errorMessage = "No user logged in"
            showError = true
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let newEntry = try await apiService.createEntry(
                title: title,
                content: content,
                mood: mood,
                symptoms: symptoms,
                medications: medications
            )
            entries.insert(newEntry, at: 0)
            isLoading = false
            print("✅ Entry created successfully")
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to create entry: \(error.localizedDescription)")
            return false
        }
    }
    
    func updateEntry(_ entry: JournalEntry) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedEntry = try await apiService.updateEntry(entry)
            if let index = entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                entries[index] = updatedEntry
            }
            isLoading = false
            print("✅ Entry updated successfully")
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to update entry: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteEntry(id: Int) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteEntry(id: id)
            entries.removeAll { $0.id == id }
            isLoading = false
            print("✅ Entry deleted successfully")
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Failed to delete entry: \(error.localizedDescription)")
            return false
        }
    }
    
    func refresh() async {
        await loadEntries()
    }
}