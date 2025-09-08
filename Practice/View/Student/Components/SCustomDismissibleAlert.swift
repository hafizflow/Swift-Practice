import SwiftUI


@MainActor
    // MARK: - ObservableObject for Global Contact State
class ContactManager: ObservableObject {
    @Published var contact = TContactInfo(
        name: "",
        teacher: "",
        designation: "",
        phone: "",
        email: "",
        room: "",
        image: ""
    )
}


    // MARK: - Custom Dismissible Alert
struct SCustomDismissibleAlert: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var manager: ContactManager
    
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
                    Text(manager.contact.name)
                        .lineLimit(1)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(.teal.opacity(0.9))
                        .brightness(-0.2)
                    
                        // Designation
                    HStack(spacing: 0) {
                        Text("Desig: ")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        Text(manager.contact.designation)
                            .lineLimit(1)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                        // Phone with copy
                    HStack(spacing: 0) {
                        Text("Phone: ")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        Link(manager.contact.phone, destination: URL(string: "tel:\(manager.contact.phone)")!)
                            .lineLimit(1)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.teal.opacity(0.8))
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = manager.contact.phone
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        } label: {
                            Image(systemName: "square.on.square")
                                .foregroundColor(.teal.opacity(0.9))
                                .font(.system(size: 16))
                        }
                    }
                    
                        // Email with copy
                    HStack(spacing: 0) {
                        Text("Email: ")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        Text(AttributedString(stringLiteral: manager.contact.email))
                            .lineLimit(1)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                            .textSelection(.enabled)
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = manager.contact.email
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                        } label: {
                            Image(systemName: "square.on.square")
                                .foregroundColor(.teal.opacity(0.9))
                                .font(.system(size: 16))
                        }
                    }
                    
                        // Room
                    HStack(spacing: 0) {
                        Text("Room: ")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        Text(manager.contact.room)
                            .lineLimit(1)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color("mainBackground")) // replace with your color
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


    // Alternative implementation with ViewModifier for reusability
struct SCustomAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                SCustomDismissibleAlert(isPresented: $isPresented)
            }
        }
    }
}

extension View {
    func ScustomAlert(isPresented: Binding<Bool>) -> some View {
        self.modifier(SCustomAlertModifier(isPresented: isPresented))
    }
}

    //     Example using the ViewModifier
struct SExampleView: View {
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
        .ScustomAlert(isPresented: $showAlert)
    }
}

#Preview {
    SExampleView()
}
