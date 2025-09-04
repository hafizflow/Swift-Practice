import SwiftUI

struct SInsightCard: View {
    @ObservedObject var routineManager: RoutineManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enrolled Course")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(.teal.opacity(0.9))
                .brightness(-0.2)
                .padding(.bottom, 6)
            
                // Show enrolled courses dynamically
            VStack(spacing: 8) {
                ForEach(Array(routineManager.courseStatistics), id: \.id) { course in
                    HStack(alignment: .center) {
                        Text(course.courseTitle)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        Spacer()
                        Text(course.courseCode)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .padding(.bottom, 16)
            
            Divider()
                .frame(height: 1)
                .background(.gray.opacity(0.45))
                .padding(.bottom, 16)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 16) {
                
                    // Total courses enrolled
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.testBg)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
                    Text("Total Course Enrolled: \(routineManager.totalCoursesEnrolled)")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
                
                    // Total weekly classes
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.testBg)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
                    Text("Total Weekly Classes: \(routineManager.totalWeeklyClasses)")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
                
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.testBg)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
                    Text("Weekly Class Hours: \(String(format: "%.1f", routineManager.totalWeeklyHours))")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
            }
            .padding(.bottom, 8)
            
            
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
            ], spacing: 16) {
                    // Weekend Class Hours
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.testBg)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
//                    Text("Holidays: \(routineManager.weeklyHolidays)")
                    Text(holidayText)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
                
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.testBg)
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.gray.opacity(0.45), lineWidth: 1)
                        )
                    
                    Text("Active Days: \(routineManager.dailyClassCounts.filter { $0.totalClasses > 0 }.count)")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.8))
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .lineSpacing(4)
                }
                
                    // Download PDF (smaller width)
                ZStack {
                    Button(action: {
                            // Download Code
                    }) {
                        ZStack(alignment: .center) {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.teal.opacity(0.1))
                                .frame(height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(.gray.opacity(0.45), lineWidth: 1)
                                )
                            
                            VStack(alignment: .center, spacing: 4) {
                                Image(systemName: "arrow.down.app.fill")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Text("PDF")
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.8))
                                    .fontWeight(.bold)
                            }
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
    
    
    var holidayText: String {
        let allDays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        let activeDays = Set(routineManager.filteredAndGroupedRoutines.keys.filter { day in
            if let routines = routineManager.filteredAndGroupedRoutines[day] {
                return !routines.isEmpty
            }
            return false
        })
        
        let holidayDays = allDays.filter { !activeDays.contains($0) }
        
        if holidayDays.isEmpty {
            return "No Holidays"
        } else if holidayDays.count > 3 {
            return "\(holidayDays.count) Holidays"
        } else {
            return "Holidays: \(holidayDays.joined(separator: ", "))"
        }
    }
}

#Preview {
    SInsightCard(routineManager: RoutineManager())
}
