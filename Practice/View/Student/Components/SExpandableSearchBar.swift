import SwiftUI

struct SExpandableSearchBar: View {
    @EnvironmentObject var manager: RoutineManager
    @Binding var isSearching: Bool
    @FocusState private var isTextFieldFocused: Bool
    @State var searchText: String = ""
    
        // State for suggestions
    @State private var showSuggestions: Bool = false
    
        // Computed property for section suggestions
    private var sectionSuggestions: [String] {
        guard !searchText.isEmpty else { return [] }
        
        let allSections = Set(manager.routines.compactMap { $0.section?.uppercased() })
        let searchUpper = searchText.uppercased()
        
            // Filter to get only parent sections (those without numbers at the end)
        let parentSections = allSections.filter { section in
                // Check if the section ends with a letter (parent) or number (child)
            let lastChar = section.last
            return lastChar?.isLetter == true
        }
        
        let filtered = parentSections.filter { section in
            section.contains(searchUpper) || section.hasPrefix(searchUpper)
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
                        ForEach(sectionSuggestions, id: \.self) { suggestion in
                            Button {
                                searchText = suggestion
                                performSearch()
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
                            
                            if suggestion != sectionSuggestions.last {
                                Divider()
                                    .background(.gray.opacity(0.3))
                            }
                        }
                    }
                }
                .frame(
                    maxHeight: min(CGFloat(sectionSuggestions.count) * 44, 160) // ✅ auto height with max cap
                )
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBackground)
                        .stroke(.gray.opacity(0.4), lineWidth: 1)
                }
                .padding(.bottom, 5)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(1) // Ensure suggestions are above other content
            }
            
                // Main search bar
            ZStack {
                if isSearching {
                    HStack(spacing: 0) {
                        TextField("Section (61_N)", text: $searchText)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 24)
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                performSearch()
                            }
                            .onChange(of: searchText) { _, newValue in
                                    // Only update suggestions, no real-time search
                                showSuggestions = !newValue.isEmpty && !sectionSuggestions.isEmpty
                            }
                        Spacer()
                        
                        DropdownMenu(dropdownAlignment: .center, fromTop: true, options: [
                            DropdownOption(title: "CSE", action: {}),
                            DropdownOption(title: "SWE", action: {}),
                        ])
                        .offset(x: -10)
                    }
                }
                
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.gray.opacity(0.65))
                    .frame(maxWidth: isSearching ? .infinity : 60, maxHeight: 50)
                    .overlay(alignment: .trailing) {
                        Button {
                            if isSearching {
                                performSearch()
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
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 5)
        .animation(.easeInOut(duration: 0.4), value: isSearching)
        .animation(.easeInOut(duration: 0.2), value: showSuggestions)
        .onChange(of: isSearching) { _, newValue in
            if newValue {
                if !manager.selectedSection.isEmpty {
                    searchText = manager.selectedSection
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
        .onTapGesture {
            if showSuggestions {
                showSuggestions = false
            }
        }
    }
    
    private func performSearch() {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedText.isEmpty else {
                // Don't close search if text is empty
            return
        }
        
            // Update the manager with the search
        let upperCaseSection = trimmedText.uppercased()
        manager.selectedSection = upperCaseSection
        
            // Close the search bar and hide suggestions
        withAnimation {
            isSearching = false
            showSuggestions = false
        }
    }
}

#Preview {
    SExpandableSearchBar(isSearching: .constant(true))
        .padding(.horizontal, 16)
        .environmentObject(RoutineManager())
}
