import SwiftUI
import Lottie

struct TClassCard: View {
    var routine: TFilteredRoutine? = nil
    
    var body: some View {
        Group {
            if let routine = routine {
                    // Class exists
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center) {
                        Text("\(routine.startTime) - \(routine.endTime)")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundStyle(.teal.opacity(0.9))
                            .brightness(-0.2)
                        
                        Spacer()
                        
                        Text(routine.duration)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                    }
                    
                    OverflowingText(text: routine.courseTitle)
                    
                    HStack {
                        HStack(alignment: .center, spacing: 10) {
                            Text("Section:")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text(routine.section)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        HStack(alignment: .center, spacing: 20) {
                            Text("Course:")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Text(routine.courseCode)
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    
                    HStack(alignment: .center, spacing: 10) {
                        Text("Room:")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        Text(routine.room)
                            .lineLimit(1)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .lineLimit(1)
                .padding(15)
                
            } else {
                    // Free day (empty state)
                VStack(alignment: .center, spacing: 4) {
                    LottieAnimation(animationName: "medi.json")
                        .frame(maxWidth: .infinity, maxHeight: 250)
                    Text("Looks like you've got a free day!")
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                    Text("Take it easy and explore new opportunities!")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                        .padding(.horizontal, 16)
                }
                .frame(height: 350)
                .frame(maxWidth: .infinity)
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
    VStack(spacing: 20) {
            // Preview empty state
        TClassCard(routine: nil)
        
            // Preview with sample data
        TClassCard(
            routine: TFilteredRoutine(
                courseCode: "CSE333",
                room: "KT-503 (COM LAB)",
                teacher: "MJZ",
                startTime: "08:30",
                endTime: "10:00",
                section: "61_N",
                day: "Sunday",
                courseTitle: "Computer Architecture and Organization",
                courseCredits: 3.0,
                teacherName: "Dr. Mohammad Jashim Uddin",
                teacherCell: "01234567890",
                teacherEmail: "mjz@diu.edu.bd",
                teacherDesignation: "Professor",
                teacherImage: "",
                teacherRoom: "Unknown"
            )
        )
    }
    .padding(.horizontal, 16)
    .background(.black)
}
