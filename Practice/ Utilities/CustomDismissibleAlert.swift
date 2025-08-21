import SwiftUI


// Wrapper for UIVisualEffectView to create a blur effect
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct ContactInfo {
    let name: String
    let designation: String
    let phone: String
    let email: String
    let room: String
}

struct CustomDismissibleAlert: View {
    @Binding var isPresented: Bool
    
    let contact = ContactInfo(
        name: "Hafizur Rahman - HR",
        designation: "Lecturer",
        phone: "01736692184",
        email: "rahman15-5678@diu.edu.bd",
        room: "Unknown"
    )
    
    var body: some View {
        ZStack {
            BlurView(style: .dark)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissAlert()
                }
            
            VStack {
                    VStack(alignment: .leading, spacing: 12) {
                            // Name
                        Text(contact.name)
                            .lineLimit(1)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
                        
                            // Designation
                        HStack (alignment: .center, spacing: 0){
                            Text("Desig: ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text(contact.designation)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        HStack (alignment: .center, spacing: 0){
                            Text("Phone: ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text(contact.phone)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.teal.opacity(0.8))
                                .environment(\.openURL, OpenURLAction { url in
                                    if url.scheme == "tel" {
                                        UIApplication.shared.open(url)
                                        return .handled
                                    }
                                    return .discarded
                                })
                            
                            Spacer()
                            
                                // Copy button for cell number
                            Button(action: {
                                    // Copy cell number to clipboard
                                UIPasteboard.general.string = contact.phone
                            }) {
                                    // SF Symbol for copy button
                                Image(systemName: "square.on.square")
                                    .foregroundColor(.teal.opacity(0.9))
                                    .font(.system(size: 16))
                            }
                        }
                        
                        
                            // Email with copy functionality
                        HStack (alignment: .center, spacing: 0){
                            Text("Email: ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text(AttributedString(stringLiteral: contact.email))
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                                .textSelection(.enabled)
                            
                            Spacer()
                            
                                // Copy button for email
                            Button(action: {
                                    // Copy email address to clipboard
                                UIPasteboard.general.string = contact.email
                            }) {
                                    // SF Symbol for copy button
                                Image(systemName: "square.on.square")
                                    .foregroundColor(.teal.opacity(0.9))
                                    .font(.system(size: 16))
                            }
                        }
                        
                        
                            // Room
                        HStack (alignment: .center, spacing: 0){
                            Text("Room: ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text("Unknown")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(.mainBackground)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal, 15)
        }
        .scaleEffect(isPresented ? 1.0 : 0.8)
        .opacity(isPresented ? 1.0 : 0.0)
    }
    
    private func dismissAlert() {
        isPresented = false
    }
}

// MARK: - Usage Example
struct ContentView: View {
    @State private var showAlert = true
    
    var body: some View {
        ZStack {
            VStack {
                Button("Show Alert") {
                    showAlert = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
                // Custom Alert Overlay
            if showAlert {
                CustomDismissibleAlert(isPresented: $showAlert)
            }
        }
    }
}

// Alternative implementation with ViewModifier for reusability
struct CustomAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                CustomDismissibleAlert(isPresented: $isPresented)
            }
        }
    }
}

extension View {
    func customAlert(isPresented: Binding<Bool>) -> some View {
        self.modifier(CustomAlertModifier(isPresented: isPresented))
    }
}

//     Example using the ViewModifier
struct ExampleView: View {
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Button("Show Custom Alert") {
                showAlert = true
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .customAlert(isPresented: $showAlert)
    }
}

#Preview {
    ExampleView()
}
