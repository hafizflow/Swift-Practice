import SwiftUI
import Lottie

struct ExamCard: View {
    @Binding var showAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                Text("08:30 - 10:00")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.teal.opacity(0.9))
                    .brightness(-0.2)
                
                Spacer()
                
                Text("25/05/2025")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundStyle(.teal.opacity(0.7))
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
            .padding(.bottom, 16)
            
                // Wrapping layout for room cards
            HStack(alignment: .firstTextBaseline) {
                    Text("Room:")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    
                    WrappingHStack(spacing: 8) {
                            // First room card
                        RoomCard(roomNumber: "KT-503", studentCount: "34")
                        
                            // Second room card
                        RoomCard(roomNumber: "KT-803", studentCount: "02")
                        
                            // Third room card
                        RoomCard(roomNumber: "KT-801 (B)", studentCount: "14")
                    }
                }
        }
        .lineLimit(2)
        .padding(15)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.testBg)
                .shadow(color: .gray.opacity(0.75), radius: 2)
        }
    }
}

struct RoomCard: View {
    let roomNumber: String
    let studentCount: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
                // Room No
            Text(roomNumber)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
            
                // Student
            Text(studentCount)
                .font(.system(size: 12))
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.teal.opacity(0.3))
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.6), lineWidth: 1)
        }
    }
}

#Preview {
    ExamCard(showAlert: .constant(false)).padding(20)
}



struct WrappingHStack: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return calculateLayout(sizes: sizes, availableWidth: proposal.width ?? .infinity).totalSize
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let layout = calculateLayout(sizes: sizes, availableWidth: bounds.width)
        
        for (index, position) in layout.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }
    
    private func calculateLayout(sizes: [CGSize], availableWidth: CGFloat) -> (positions: [CGPoint], totalSize: CGSize) {
        var positions: [CGPoint] = []
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for size in sizes {
                // Check if we need to wrap to next line
            if currentPosition.x + size.width > availableWidth && !positions.isEmpty {
                    // Move to next line
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(currentPosition)
            
            currentPosition.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxWidth = max(maxWidth, currentPosition.x - spacing)
        }
        
        let totalHeight = currentPosition.y + lineHeight
        let totalSize = CGSize(width: maxWidth, height: totalHeight)
        
        return (positions, totalSize)
    }
}
