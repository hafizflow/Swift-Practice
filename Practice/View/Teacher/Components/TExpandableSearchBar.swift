//import SwiftUI
//
//struct TExpandableSearchBar: View {
//    @State var searchText: String = ""
//    @Binding var isSearching: Bool
//    @FocusState private var isTextFieldFocused: Bool
//    
//    var body: some View {
//        ZStack {
//            if isSearching {
//                HStack(spacing: 0) {
//                    TextField("Teacher Initial (MJZ)", text: $searchText)
//                        .foregroundStyle(.white.opacity(0.9))
//                        .padding(.horizontal, 24)
//                        .focused($isTextFieldFocused)
//                    
//                    Spacer()
//                }
//                
//            }
//            
//            HStack (spacing: 0) {
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(lineWidth: 1)
//                    .foregroundStyle(.gray.opacity(0.65))
//                    .frame(maxWidth: isSearching ? .infinity : 60, maxHeight: 50)
//                    .overlay(alignment: .trailing) {
//                        Button {
//                            withAnimation {
//                                isSearching.toggle()
//                            }
//                        } label: {
//                            Image(systemName: "magnifyingglass")
//                                .tint(.white)
//                                .padding(.trailing, 20)
//                        }
//                    }
//            }
//        }
//        .background {
//            RoundedRectangle(cornerRadius: 10)
//                .fill(.mainBackground)
//        }
//        .padding(.horizontal, 20)
//        .padding(.bottom, 5)
//        .animation(.easeInOut(duration: 0.4), value: isSearching)
//        .onChange(of: isSearching) { _, newValue in
//            if newValue {
//                    // Small delay to ensure the animation completes before focusing
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//                    isTextFieldFocused = true
//                }
//            } else {
//                isTextFieldFocused = false
//            }
//        }
//    }
//}
//
//#Preview {
//    TExpandableSearchBar(isSearching: .constant(true))
//        .padding(.horizontal, 16)
//}





import SwiftUI

struct TExpandableSearchBar: View {
    @EnvironmentObject var manager: TeacherManager
    @Binding var isSearching: Bool
    @FocusState private var isTextFieldFocused: Bool
    @State var searchText: String = ""
    
        // State for suggestions
    @State private var showSuggestions: Bool = false
    
        // Computed property for teacher suggestions
    private var teacherSuggestions: [String] {
        guard !searchText.isEmpty else { return [] }
        
        let allTeachers = Set(manager.routines.compactMap { $0.teacher?.uppercased() })
        let searchUpper = searchText.uppercased()
        
        let filtered = allTeachers.filter { teacher in
            teacher.contains(searchUpper) || teacher.hasPrefix(searchUpper)
        }
        
            // Sort by relevance: exact matches first, then prefix matches, then contains
        let sorted = filtered.sorted { first, second in
            let firstExact = first == searchUpper
            let secondExact = second == searchUpper
            
            if firstExact && !secondExact { return true }
            if !firstExact && secondExact { return false }
            
            let firstPrefix = first.hasPrefix(searchUpper)
            let secondPrefix = second.hasPrefix(searchUpper)
            
            if firstPrefix && !secondPrefix { return true }
            if !firstPrefix && secondPrefix { return false }
            
            return first < second
        }
        
        return Array(sorted.prefix(10))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isSearching && showSuggestions {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(teacherSuggestions, id: \.self) { suggestion in
                            Button {
                                searchText = suggestion
                                performSearchWithImmediateDismiss()
                            } label: {
                                HStack {
                                    Text(suggestion)
                                        .foregroundColor(.white.opacity(0.9))
                                        .font(.system(size: 16))
                                    Spacer()
                                    Image(systemName: "arrow.down.left")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            
                            if suggestion != teacherSuggestions.last {
                                Divider()
                                    .background(.gray.opacity(0.3))
                            }
                        }
                    }
                }
                .frame(
                    maxHeight: min(CGFloat(teacherSuggestions.count) * 44, 160)
                )
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBackground)
                        .stroke(.gray.opacity(0.4), lineWidth: 1)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                .padding(.bottom, 5)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(1)
                    // Block parent tap gestures from reaching suggestions
                .onTapGesture { }
            }
            
                // Main search bar
            ZStack {
                if isSearching {
                    HStack(spacing: 0) {
                        TextField("Teacher Initial (MJZ)", text: $searchText)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 24)
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                performSearchWithImmediateDismiss()
                            }
                            .onChange(of: searchText) { _, newValue in
                                    // Only update suggestions, no real-time search
                                showSuggestions = !newValue.isEmpty && !teacherSuggestions.isEmpty
                            }
                            // Prevent parent gestures from affecting text field
                            .onTapGesture {
                                    // Force focus when tapping the text field
                                isTextFieldFocused = true
                            }
                        
                        Spacer()
                    }
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.gray.opacity(0.65))
                    .frame(maxWidth: isSearching ? .infinity : 60, maxHeight: 50)
                    .overlay(alignment: .trailing) {
                        Button {
                            if isSearching {
                                performSearchWithImmediateDismiss()
                            } else {
                                    // Just expand the search bar
                                withAnimation {
                                    isSearching.toggle()
                                }
                            }
                        } label: {
                            Image(systemName: isSearching ? "arrow.right" : "magnifyingglass")
                                .tint(.white)
                                .padding(.trailing, 20)
                        }
                    }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.mainBackground)
            }
                // Block parent tap gestures from reaching the entire search bar
            .onTapGesture {
                    // Do nothing - this blocks the parent gesture
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 5)
        .animation(.easeInOut(duration: 0.4), value: isSearching)
        .animation(.easeInOut(duration: 0.2), value: showSuggestions)
        .onChange(of: isSearching) { _, newValue in
            if newValue {
                if !manager.selectedTeacher.isEmpty {
                    searchText = manager.selectedTeacher
                }
                
                    // Small delay to ensure the animation completes before focusing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isTextFieldFocused = true
                }
            } else {
                isTextFieldFocused = false
                showSuggestions = false
            }
        }
    }
    
        // Immediate dismiss function
    private func performSearchWithImmediateDismiss() {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else {
                // Don't close search if text is empty
            return
        }
        
            // IMMEDIATE: Dismiss keyboard and UI first
        isTextFieldFocused = false
        showSuggestions = false
        isSearching = false
        
            // Hide keyboard immediately
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
            // THEN: Update the manager with the search (after UI dismisses)
        let upperCaseTeacher = trimmedText.uppercased()
        manager.selectedTeacher = upperCaseTeacher
    }
}

#Preview {
    TExpandableSearchBar(isSearching: .constant(true))
        .padding(.horizontal, 16)
        .environmentObject(TeacherManager())
}
