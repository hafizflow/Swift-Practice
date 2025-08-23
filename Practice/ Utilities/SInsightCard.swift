import SwiftUI

struct SInsightCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enrolled Course")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.teal.opacity(0.9))
                .brightness(-0.2)
                .padding(.bottom, 6)
            
            VStack(spacing: 8) {
                HStack(alignment: .center) {
                    Text("Data Structure & Algorithm")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("CSE333")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                HStack(alignment: .center) {
                    Text("System Analysis & Design")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("CSE232")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                HStack(alignment: .center) {
                    Text("Software Development Lab")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("CSE343")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.bottom, 16)
            
            Divider()
                .frame(height: 1)
                .background(.gray.opacity(0.45))
                .padding(.bottom, 16)
            
            
                // Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                
                
                    // Total Course Enrolled
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.testBg)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
                    Text("Total Course Enrolled: 4")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                        .fontWeight(.bold)
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
                
                
                    // Total weekly class
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.testBg)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
                    Text("Total Weekly Class: 5")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                        .fontWeight(.bold)
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
                
                
                    // Download PDF
                ZStack {
                    Button(action: {
                            // Download Code
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.teal.opacity(0.1))
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
                                )
                            
                            Text("Download PDF")
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.8))
                                .fontWeight(.bold)
                                .font(.headline)
                                .padding(.horizontal, 15)
                                .lineSpacing(4)
                        }
                    }
                }
            }
            
            
        }
        .lineLimit(1)
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.testBg)
                .shadow(color: .gray.opacity(0.75), radius: 2)
        }
    }
}


#Preview {
    SInsightCard()
}
