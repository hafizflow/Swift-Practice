import SwiftUI
import Lottie

struct SClassCard: View {
    var isEmpty: Bool = false
    @Binding var showAlert: Bool
    
    var body: some View {
        Group {
            if isEmpty {
                VStack(alignment: .center, spacing: 8) {
                    LottieAnimation(animationName: "sloth.json")
                        .frame(width: .infinity, height: 200)
                    Text("Looks like you've got a free day!")
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                    Text("Take it easy and explore new opportunities!")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center) {
                        Text("08:30 - 10:00")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
                        
                        Spacer()
                        
                        Text("1 hour 30 mins")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text("Data Structure - CSE333")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding([.top, .bottom], 6)
                            .lineLimit(1)
                            .brightness(-0.2)
                        
                    }
                    
                    
                    HStack {
                        HStack(alignment: .center, spacing: 10) {
                            Text("Section:")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text("61_N")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 20) {
                            Text("Teacher:")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            
                            Button(action: {
                                showAlert = true
                            }) {
                                Text("MMA")
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.teal.opacity(0.9))
                                    .brightness(-0.2)
                            }.buttonStyle(.plain)
                        }
                        
                    }
                    
                    HStack(alignment: .center, spacing: 10) {
                        Text("Room:")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        Text("KT-503 (COM LAB)")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .lineLimit(1)
                .padding(15)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.testBg)
                .shadow(color: .gray.opacity(0.75), radius: 2)
        }
    }
}

#Preview {
    SClassCard(showAlert: .constant(false))
        .padding(.horizontal, 16)
}

