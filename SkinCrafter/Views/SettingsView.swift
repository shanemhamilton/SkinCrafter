import SwiftUI

struct SettingsView: View {
    @Binding var currentMode: ContentView.EditorMode
    @AppStorage("preferredMode") private var preferredMode = "express"
    @AppStorage("userAgeGroup") private var userAgeGroup = "under13"
    
    var body: some View {
        NavigationView {
            List {
                Section("Preferences") {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Preferred Mode")
                                .font(.headline)
                            Text("Default mode when opening app")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Picker("Mode", selection: $preferredMode) {
                            Text("Express").tag("express")
                            Text("Studio").tag("studio")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Age Group")
                                .font(.headline)
                            Text("Helps optimize interface")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Picker("Age", selection: $userAgeGroup) {
                            Text("Under 13").tag("under13")
                            Text("13+").tag("teen")
                            Text("Adult").tag("adult")
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Version")
                                .font(.headline)
                            Text("1.0.0 Beta")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Developer")
                                .font(.headline)
                            Text("SkinCrafter Team")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        withAnimation(.spring()) {
                            currentMode = .modeSelector
                        }
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(currentMode: .constant(.settings))
    }
}