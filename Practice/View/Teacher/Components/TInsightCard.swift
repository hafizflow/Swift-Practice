import SwiftUI

struct TInsightCard: View {
    @ObservedObject var teacherManager: TeacherManager
    
    var body: some View {
        VStack {
                // Teacher Contact Information Card
            if let teacherInfo = getTeacherInfo() {
                VStack(alignment: .leading, spacing: 10) {
                        // Name
                    Text(teacherInfo.name)
                        .lineLimit(1)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(.teal.opacity(0.9))
                        .brightness(-0.2)
                        .padding(.bottom, 0)
                    
                    Divider()
                        .frame(width: 150, height: 1)
                        .background(.gray.opacity(0.45))
                        .padding(.bottom, 4)
                    
                    HStack {
                            // Profile Image with loading indicator
                        AsyncImage(url: URL(string: teacherInfo.image.isEmpty ? "https://via.placeholder.com/55" : teacherInfo.image)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 55, height: 55)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.teal.opacity(0.2), lineWidth: 2)
                                )
                        } placeholder: {
                                // Loading indicator inside circle
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 55, height: 55)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                )
                        }.padding(.trailing, 4)
                        
                        VStack(alignment: .leading, spacing: 10) {
                                // Designation
                            HStack(alignment: .center, spacing: 0) {
                                Text("Desig: ")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                                
                                Text(teacherInfo.designation)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            
                            HStack(alignment: .center, spacing: 0) {
                                Text("Phone: ")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.gray)
                                
                                if teacherInfo.phone != "N/A" && !teacherInfo.phone.isEmpty {
                                    Link(teacherInfo.phone, destination: URL(string: "tel:\(teacherInfo.phone)")!)
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.teal.opacity(0.8))
                                } else {
                                    Text("Not Available")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                    // Copy button for cell number (only if available)
                                if teacherInfo.phone != "N/A" && !teacherInfo.phone.isEmpty {
                                    Button(action: {
                                        UIPasteboard.general.string = teacherInfo.phone
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                        impactFeedback.impactOccurred()
                                    }) {
                                        Image(systemName: "square.on.square")
                                            .foregroundColor(.teal.opacity(0.9))
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                        }
                    }
                    
                        // Email with copy functionality
                    HStack (alignment: .center, spacing: 0){
                        Text("Email: ")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        if teacherInfo.email != "N/A" && !teacherInfo.email.isEmpty {
                            Text(AttributedString(stringLiteral: teacherInfo.email))
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                                .textSelection(.enabled)
                        } else {
                            Text("Not Available")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                            // Copy button for email (only if available)
                        if teacherInfo.email != "N/A" && !teacherInfo.email.isEmpty {
                            Button(action: {
                                UIPasteboard.general.string = teacherInfo.email
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                            }) {
                                Image(systemName: "square.on.square")
                                    .foregroundColor(.teal.opacity(0.9))
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    
                        // Room
                    HStack (alignment: .center, spacing: 0){
                        Text("Room: ")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        Text(teacherInfo.room)
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(15)
                .frame(maxWidth: .infinity)
                .cornerRadius(12)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.testBg)
                        .shadow(color: .gray.opacity(0.75), radius: 2)
                }.padding(.bottom, 8)
            }
            
                // Course Statistics Card
            VStack(alignment: .leading, spacing: 8) {
                Text("Provided Courses")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.teal.opacity(0.9))
                    .brightness(-0.2)
                    .padding(.bottom, 6)
                
                    // Show provided courses dynamically
                VStack(spacing: 8) {
                    ForEach(Array(teacherManager.courseStatistics.prefix(5)), id: \.id) { course in
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
                    
                        // Show "and X more" if there are more courses
                    if teacherManager.courseStatistics.count > 5 {
                        Text("... and \(teacherManager.courseStatistics.count - 5) more")
                            .font(.system(size: 14))
                            .fontWeight(.medium)
                            .foregroundStyle(.gray.opacity(0.8))
                            .italic()
                    }
                }
                .padding(.bottom, 16)
                
                Divider()
                    .frame(height: 1)
                    .background(.gray.opacity(0.45))
                    .padding(.bottom, 16)
                
                    // Statistics Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ], spacing: 16) {
                    
                        // Total courses provided
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.testBg)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.gray.opacity(0.45), lineWidth: 1)
                            )
                        
                        Text("Total Courses Provided: \(teacherManager.totalCoursesProvided)")
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
                        
                        Text("Total Weekly Classes: \(teacherManager.totalWeeklyClasses)")
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .lineSpacing(4)
                    }
                    
                        // Weekly class hours
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.testBg)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.gray.opacity(0.45), lineWidth: 1)
                            )
                        
                        Text("Weekly Class Hours: \(String(format: "%.1f", teacherManager.totalWeeklyHours))")
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
                
                    // Second row of statistics
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ], spacing: 16) {
                    
                        // Holidays
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.testBg)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.gray.opacity(0.45), lineWidth: 1)
                            )
                        
                        Text(holidayText)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .lineSpacing(4)
                    }
                    
                        // Active Days
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.testBg)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.gray.opacity(0.45), lineWidth: 1)
                            )
                        
                        Text("Active Days: \(teacherManager.dailyClassCounts.filter { $0.totalClasses > 0 }.count)")
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                            .fontWeight(.bold)
                            .padding(.horizontal, 8)
                            .lineSpacing(4)
                    }
                    
                        // Download PDF
                    ZStack {
                        Button(action: {
                                // Download Code - you can implement this
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
            .padding(15)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.testBg)
                    .shadow(color: .gray.opacity(0.75), radius: 2)
            }
        }
    }
    
        // Helper function to get teacher information
    private func getTeacherInfo() -> TContactInfo? {
        guard !teacherManager.selectedTeacher.isEmpty,
              let teacher = teacherManager.teacher(for: teacherManager.selectedTeacher) else {
            return nil
        }
        
        return TContactInfo(
            name: teacher.name ?? "Unknown Teacher",
            teacher: teacher.teacher ?? teacherManager.selectedTeacher,
            designation: teacher.designation ?? "Unknown",
            phone: teacher.cellPhone ?? "N/A",
            email: teacher.email ?? "N/A",
            room: "Unknown", // You might want to add room info to your TeacherModel
            image: teacher.imageUrl ?? ""
        )
    }
    
        // Holiday text computation
    var holidayText: String {
        let allDays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        let activeDays = Set(teacherManager.filteredAndGroupedRoutines.keys.filter { day in
            if let routines = teacherManager.filteredAndGroupedRoutines[day] {
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
    TInsightCard(teacherManager: TeacherManager())
}
