import SwiftUI

    // Supporting structure for teacher suggestions
struct TeacherSuggestion: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let designation: String?
    
    var displayText: String {
        return "\(code) - \(name)"
    }
}

struct TExpandableSearchBar: View {
    @EnvironmentObject var manager: TeacherManager
    @Binding var isSearching: Bool
    @FocusState private var isTextFieldFocused: Bool
    @State var searchText: String = ""
    
        // State for suggestions
    @State private var showSuggestions: Bool = false
    @State private var suggestions: [TeacherSuggestion] = []
    @State private var searchTask: Task<Void, Never>?
    
        // Cache all teacher suggestions once
    @State private var allTeacherSuggestions: [TeacherSuggestion] = []
    @State private var hasBuiltCache = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isSearching && showSuggestions {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(suggestions, id: \.id) { suggestion in
                            Button {
                                searchText = suggestion.code
                                performSearchWithImmediateDismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(suggestion.displayText)
                                            .foregroundColor(.white.opacity(0.9))
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        if let designation = suggestion.designation, !designation.isEmpty {
                                            Text(designation)
                                                .foregroundColor(.white.opacity(0.6))
                                                .font(.system(size: 12))
                                        }
                                    }
                                    
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
                            
                            if suggestion.id != suggestions.last?.id {
                                Divider()
                                    .background(.gray.opacity(0.3))
                            }
                        }
                    }
                }
                .frame(
                    maxHeight: min(CGFloat(suggestions.count) * 60, 180)
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
                                performDebouncedSearch(query: newValue)
                            }
                            .onTapGesture {
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
            .onTapGesture { }
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
                
                    // Build cache when first opening
                if !hasBuiltCache {
                    buildTeacherCache()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isTextFieldFocused = true
                }
            } else {
                isTextFieldFocused = false
                showSuggestions = false
                searchTask?.cancel()
            }
        }
        .onChange(of: manager.routines) { _, _ in
                // Rebuild cache when data changes
            hasBuiltCache = false
        }
    }
    
        // Build cache of all teacher suggestions once
    private func buildTeacherCache() {
        let allTeacherCodes = Set(manager.routines.compactMap { $0.teacher })
        
        allTeacherSuggestions = allTeacherCodes.compactMap { teacherCode in
            let teacherModel = manager.teacher(for: teacherCode)
            let teacherName = teacherModel?.name ?? "Unknown"
            
            return TeacherSuggestion(
                code: teacherCode,
                name: teacherName,
                designation: teacherModel?.designation
            )
        }.sorted { $0.code < $1.code }
        
        hasBuiltCache = true
    }
    
        // Debounced search with 300ms delay
    private func performDebouncedSearch(query: String) {
            // Cancel previous search
        searchTask?.cancel()
        
            // If query is empty, hide suggestions immediately
        guard !query.isEmpty else {
            showSuggestions = false
            suggestions = []
            return
        }
        
            // Start new debounced search
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms delay
            
                // Check if task was cancelled
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                filterSuggestions(query: query)
            }
        }
    }
    
        // Fast filtering from cached data
    private func filterSuggestions(query: String) {
        let searchUpper = query.uppercased()
        
        let filtered = allTeacherSuggestions.filter { suggestion in
            let codeMatches = suggestion.code.uppercased().contains(searchUpper) ||
            suggestion.code.uppercased().hasPrefix(searchUpper)
            let nameMatches = suggestion.name.uppercased().contains(searchUpper) ||
            suggestion.name.uppercased().hasPrefix(searchUpper)
            return codeMatches || nameMatches
        }
        
            // Sort by relevance
        let sorted = filtered.sorted { first, second in
            let firstCodeExact = first.code.uppercased() == searchUpper
            let secondCodeExact = second.code.uppercased() == searchUpper
            
            if firstCodeExact && !secondCodeExact { return true }
            if !firstCodeExact && secondCodeExact { return false }
            
            let firstCodePrefix = first.code.uppercased().hasPrefix(searchUpper)
            let secondCodePrefix = second.code.uppercased().hasPrefix(searchUpper)
            
            if firstCodePrefix && !secondCodePrefix { return true }
            if !firstCodePrefix && secondCodePrefix { return false }
            
            return first.code < second.code
        }
        
        suggestions = Array(sorted.prefix(10))
        showSuggestions = !suggestions.isEmpty
    }
    
        // Immediate dismiss function
    private func performSearchWithImmediateDismiss() {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else { return }
        
            // Cancel any pending search tasks
        searchTask?.cancel()
        
            // IMMEDIATE: Dismiss keyboard and UI first
        isTextFieldFocused = false
        showSuggestions = false
        isSearching = false
        
            // Hide keyboard immediately
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
            // Update the manager with the search
        let upperCaseTeacher = trimmedText.uppercased()
        manager.selectedTeacher = upperCaseTeacher
    }
}

#Preview {
    TExpandableSearchBar(isSearching: .constant(true))
        .padding(.horizontal, 16)
        .environmentObject(TeacherManager())
}
