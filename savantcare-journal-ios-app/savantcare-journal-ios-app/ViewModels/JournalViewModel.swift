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
    private let patientId: String
    
    init(patientId: String = Constants.PatientInfo.currentPatientId) {
        self.patientId = patientId
    }
    
    func loadEntries() async {
        isLoading = true
        errorMessage = nil
        
        do {
            entries = try await apiService.fetchJournalEntries(patientId: patientId)
            entries.sort { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Error loading entries: \(error)")
        }
        
        isLoading = false
    }
    
    func createEntry(_ entry: JournalEntry) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let newEntry = try await apiService.createJournalEntry(entry: entry)
            entries.insert(newEntry, at: 0)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Error creating entry: \(error)")
            isLoading = false
            return false
        }
    }
    
    func updateEntry(_ entry: JournalEntry) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedEntry = try await apiService.updateJournalEntry(entry: entry)
            if let index = entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                entries[index] = updatedEntry
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Error updating entry: \(error)")
            isLoading = false
            return false
        }
    }
    
    func deleteEntry(_ entry: JournalEntry) async {
        guard let id = entry.id else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteJournalEntry(id: id)
            entries.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            print("Error deleting entry: \(error)")
        }
        
        isLoading = false
    }
}