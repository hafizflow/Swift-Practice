//import SwiftUI
//import SwiftData
//
//struct ContentViewDemo: View {
//    @Environment(\.modelContext) private var context
//    @Query private var routines: [RoutineModel]
//    @Query private var courses: [CourseModel]
//    @Query private var teachers: [TeacherModel]
//    
//    @State private var inputSection: String = ""
//    @StateObject private var routineManager = RoutineManager()
//    @StateObject private var dataManager = DataManager()
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                    // Search Section
//                HStack {
//                    TextField("Enter Section (e.g., 61_N)", text: $inputSection)
//                        .textFieldStyle(.roundedBorder)
//                        .padding(.leading)
//                    
//                    Button("Search") {
//                        routineManager.selectedSection = inputSection.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                    .padding(.trailing)
//                    .disabled(inputSection.isEmpty)
//                }
//                .padding(.vertical, 4)
//                
//                    // Results Section
//                List {
//                    ForEach(routineManager.filteredRoutinesWithDetails.keys.sorted(), id: \.self) { day in
//                        Section(header: Text(day).font(.headline)) {
//                            ForEach(routineManager.filteredRoutinesWithDetails[day] ?? []) { routine in
//                                VStack(alignment: .leading, spacing: 8) {
//                                        // Course Info
//                                    HStack {
//                                        Text(routine.courseCode)
//                                            .font(.headline)
//                                            .foregroundColor(.primary)
//                                        
//                                        Spacer()
//                                        
//                                        Text("\(routine.startTime) - \(routine.endTime)")
//                                            .font(.caption)
//                                            .foregroundColor(.secondary)
//                                    }
//                                    
//                                    Text(routine.courseTitle)
//                                        .font(.subheadline)
//                                        .foregroundColor(.blue)
//                                    
//                                        // Teacher Info
//                                    HStack {
//                                        AsyncImage(url: URL(string: routine.teacherImage)) { image in
//                                            image
//                                                .resizable()
//                                                .scaledToFill()
//                                        } placeholder: {
//                                            Color.gray.opacity(0.3)
//                                        }
//                                        .frame(width: 40, height: 40)
//                                        .clipShape(Circle())
//                                        
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text(routine.teacherName)
//                                                .font(.subheadline)
//                                                .foregroundColor(.primary)
//                                            
//                                            Text(routine.teacherDesignation)
//                                                .font(.caption)
//                                                .foregroundColor(.gray)
//                                        }
//                                        
//                                        Spacer()
//                                        
//                                        Text("Room: \(routine.room)")
//                                            .font(.caption2)
//                                            .foregroundColor(.gray)
//                                    }
//                                    
//                                    Text("Name: \(routine.teacher)")
//                                        .font(.caption2)
//                                        .foregroundColor(.gray)
//                                    
//                                }
//                                .padding(.vertical, 4)
//                            }
//                        }
//                    }
//                }
//                .listStyle(.insetGrouped)
//                
//                    // Show message if no results
//                if routineManager.selectedSection.isEmpty {
//                    Text("Enter a section to search for routines")
//                        .foregroundColor(.secondary)
//                        .padding()
//                } else if routineManager.filteredRoutinesWithDetails.isEmpty {
//                    VStack(spacing: 8) {
//                        Text("No routines found for section '\(routineManager.selectedSection)'")
//                            .foregroundColor(.secondary)
//                        
//                        Text("Available sections might include different formats")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                        
//                        Button("Debug Info") {
//                            routineManager.debugCurrentState()
//                        }
//                        .font(.caption)
//                        .foregroundColor(.blue)
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Routine Search")
//            .task {
//                if !dataManager.loaded {
//                    await dataManager.loadRoutine(context: context, existingRoutines: routines)
//                    await dataManager.loadCourse(context: context, existingCourses: courses)
//                    await dataManager.loadTeacher(context: context, existingTeachers: teachers)
//                    dataManager.loaded = true
//                    
//                        // Update routine manager with loaded data
//                    routineManager.routines = routines
//                    routineManager.courses = courses
//                    routineManager.teachers = teachers
//                }
//            }
//            .onChange(of: routines) { _, newRoutines in
//                routineManager.routines = newRoutines
//            }
//            .onChange(of: courses) { _, newCourses in
//                routineManager.courses = newCourses
//            }
//            .onChange(of: teachers) { _, newTeachers in
//                routineManager.teachers = newTeachers
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentViewDemo()
//        .modelContainer(for: [RoutineModel.self, CourseModel.self, TeacherModel.self], inMemory: true)
//}
