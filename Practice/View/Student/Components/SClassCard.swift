import SwiftUI
import Lottie

struct SClassCard: View {
    var routine: FilteredRoutine? = nil  
    @Binding var showAlert: Bool
    
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
                    
                    OverflowingText(text: "\(routine.courseTitle) - \(routine.courseCode)")
                    
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
                            Text("Teacher:")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Button(action: {
                                showAlert = true
                            }) {
                                Text(routine.teacher)
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.teal.opacity(0.9))
                                    .brightness(-0.2)
                            }
                            .buttonStyle(.plain)
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
                    LottieAnimation(animationName: "yogi.json")
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

extension FilteredRoutine {
    var duration: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard
            let start = formatter.date(from: startTime),
            let end = formatter.date(from: endTime)
        else { return "" }
        
        let startHour = Calendar.current.component(.hour, from: start)
        let startMinute = Calendar.current.component(.minute, from: start)
        let endHour = Calendar.current.component(.hour, from: end)
        let endMinute = Calendar.current.component(.minute, from: end)
        
            // Convert to 12-hour format logic
            // Times like 01:00, 02:00, etc. that are <= 07:00 are likely PM (13:00, 14:00, etc.)
            // Times like 08:00, 09:00, 10:00, 11:00, 12:00 are likely AM
        let adjustedStartHour = startHour <= 7 && startHour != 0 ? startHour + 12 : startHour
        let adjustedEndHour = endHour <= 7 && endHour != 0 ? endHour + 12 : endHour
        
        let startTotalMinutes = adjustedStartHour * 60 + startMinute
        let endTotalMinutes = adjustedEndHour * 60 + endMinute
        
        var diff = endTotalMinutes - startTotalMinutes
        
            // Handle case where class goes to next day (shouldn't happen with proper 12-hour logic, but just in case)
        if diff < 0 {
            diff += 24 * 60
        }
        
        let hours = diff / 60
        let mins = diff % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
            // Preview empty state
        SClassCard(routine: nil, showAlert: .constant(false))
        
            // Preview with sample data
        SClassCard(
            routine: FilteredRoutine(
                courseCode: "CSE333",
                room: "KT-503 (COM LAB)",
                teacher: "MMA",
                startTime: "08:30",
                endTime: "10:00",
                section: "61_N",
                day: "Sunday",
                courseTitle: "Data Structure",
                courseCredits: 2,
                teacherName: "MMA",
                teacherCell: "01234",
                teacherEmail: "mma@diu.edu",
                teacherDesignation: "Professor",
                teacherImage: ""
            ),
            showAlert: .constant(false)
        )
    }
    .padding(.horizontal, 16)
    .background(.black)
}
