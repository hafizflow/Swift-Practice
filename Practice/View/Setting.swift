import SwiftUI

    // Settings View
struct SettingsView: View {
    @Binding var isPresented: Bool
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Button {
                            isPresented.toggle()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 32, height: 32)
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 30)
                    .padding(.horizontal, 20)
                    
                    // Settings Content
                    ScrollView {
                        VStack(spacing: 20) {
                                // Preferences Section
                            SettingsSection(title: "Preferences") {
                                SettingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Push notifications") {
                                        // Handle notifications tap
                                }
                                
                                SettingsRow(icon: "moon.fill", title: "Dark Mode", subtitle: "Toggle dark mode") {
                                        // Handle dark mode tap
                                }
                                
                                SettingsRow(icon: "arrow.trianglehead.2.clockwise.rotate.90.page.on.clipboard", title: "Clear Data", subtitle: "Clear Section/TI data") {
                                        // Handle font reset data
                                }
                            }
                            
                                // About Section
                            SettingsSection(title: "About") {
                                SettingsRow(icon: "link", title: "Share app", subtitle: "Share app link with friends") {
                                    shareApp()
                                }
                                
                                SettingsRow(icon: "star.fill", title: "Rate & Feedback", subtitle: "Rate in App Store") {
                                    rateApp()
                                }
                                
                                
                                SettingsRow(icon: "info.circle.fill", title: "App Info", subtitle: "Version 1.0.0") {
                                        // Handle app info tap
                                }
                                
                                SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", subtitle: "Get help") {
                                        // Handle help tap
                                }
                            }
                            
                            DeveloperSection()
                        }
                    }
                    .contentMargins(.all, 20, for: .scrollContent)
                    .contentMargins(.vertical, 20, for: .scrollIndicators)
                    .padding(.bottom, 16)
                    
                    Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.mainBackground)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [
                "Check out this awesome app!",
                URL(string: "https://apps.apple.com/us/app/diu-routine-viewer/id6748752277")!
            ])
            .presentationDetents([.medium])
        }
    }
    
        // Share app function
    func shareApp() {
        showShareSheet = true
    }
    
        // Rate app function
    func rateApp() {
        if let url = URL(string: "https://apps.apple.com/us/app/diu-routine-viewer/id6748752277") {
            UIApplication.shared.open(url)
        }
    }
}

    // Settings Section Helper
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
            
            VStack(spacing: 1) {
                content
            }
            .cornerRadius(16)
        }
    }
}

    // Settings Row Helper
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.white.opacity(0.10))
        }
        .buttonStyle(.plain)
    }
}

    // UIViewControllerRepresentable for UIActivityViewController
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
            // Handle iPad popover
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView(isPresented: .constant(true))
}


