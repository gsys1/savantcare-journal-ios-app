//
//  ContentView.swift
//  savantcare-journal-ios-app
//
//  Created by raj on 07/01/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = AuthService.shared.isLoggedIn
    
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            // Refresh login state when view appears
            isLoggedIn = AuthService.shared.isLoggedIn
            print("✅ App started. Logged in: \(isLoggedIn)")
            if let userId = AuthService.shared.currentUserId {
                print("✅ User ID: \(userId)")
            }
        }
    }
}

struct MainTabView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        TabView {
            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
            
            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(AuthService.shared.currentUserEmail ?? "")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("User ID")
                        Spacer()
                        Text(AuthService.shared.currentUserId ?? "")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: {
                        AuthService.shared.logout()
                        isLoggedIn = false
                    }) {
                        HStack {
                            Spacer()
                            Text("Logout")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ContentView()
}
