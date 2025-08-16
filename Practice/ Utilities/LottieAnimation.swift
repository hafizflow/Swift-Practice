import SwiftUI
import Lottie

//struct LottieView: UIViewRepresentable {
//    var url: URL
//    
//    func makeUIView(context: Context) -> UIView {
//            // Create the root view
//        let view = UIView(frame: .zero)
//        
//            // Create the Lottie animation view
//        let animationView = LottieAnimationView()
//        animationView.contentMode = .scaleAspectFit
//        animationView.loopMode = .loop
//        
//            // Add the animation view to the main view
//        view.addSubview(animationView)
//        animationView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
////            animationView.topAnchor.constraint(equalTo: view.topAnchor),
////            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
////            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
////            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//            
//            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
//            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
//        ])
//        
//            // Load the animation from the URL
//        if let animation = LottieAnimation.filepath(url.path) {
//            animationView.animation = animation
//            animationView.play()
//        } else {
//            print("Failed to load animation from URL")
//        }
//        
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//            // Update logic if needed
//    }
//}


struct LottieAnimation: UIViewRepresentable {
    var animationName: String
    func makeUIView(context: Context) -> UIView {
            // Create the root view
        let view = UIView(frame: .zero)
        
            // Create the Lottie animation view
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
            // Add the animation view to the main view
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
            // Play the animation
        animationView.play()
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
            // Update logic if needed
    }
}


#Preview {
    LottieAnimation(animationName: "discover.json")
}
