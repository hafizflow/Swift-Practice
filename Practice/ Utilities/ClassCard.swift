import SwiftUI
import Lottie

struct ClassCard: View {
    var isEmpty: Bool = false
    var body: some View {
        Group {
            if isEmpty {
                VStack(alignment: .center, spacing: 8) {
                    LottieAnimation(animationName: "sloth.json")
                        .frame(width: .infinity, height: 200)
                    Text("Looks like you've got a free day!")
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
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text("(1 hour 30 mins)")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text("Data Structure (CSE333)")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                            .brightness(-0.2)
                            .padding([.top, .bottom], 8)
                            .lineLimit(1)
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
                        }
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 20) {
                            Text("Teacher:")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text("MMA")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                                .brightness(-0.2)
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
                    }
                }
                .lineLimit(1)
                .padding(15)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.background)
                .shadow(color: .black.opacity(0.55), radius: 2)
        }
    }
}

#Preview {
    ClassCard()
        .padding(.horizontal, 16)
}
