import SwiftUI
import SwiftData

struct TeacherListView: View {
    @Query private var teachers: [TeacherModel]
    
    var body: some View {
        List(teachers) { teacher in
            NavigationLink(destination: TeacherDetailView(teacher: teacher)) {
                HStack {
                    if let urlString = teacher.imageUrl,
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 40, height: 40)
                            .overlay(Text((teacher.name ?? "N/A").prefix(1))) // ✅ fixed
                    }
                    
                    VStack(alignment: .leading) {
                        Text(teacher.name ?? "Unknown") // ✅ fixed
                            .font(.headline)
                        Text(teacher.designation ?? "N/A") // ✅ fixed
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Teachers")
    }
}

struct TeacherDetailView: View {
    let teacher: TeacherModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let urlString = teacher.imageUrl,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Text(teacher.name ?? "Unknown") // ✅ fixed
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(teacher.designation ?? "N/A"), \(teacher.department ?? "N/A")") // ✅ fixed
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    if let faculty = teacher.faculty, !faculty.isEmpty {
                        Text("Faculty: \(faculty)")
                    }
                    if let email = teacher.email, !email.isEmpty {
                        Text("Email: \(email)")
                    }
                    if let phone = teacher.phone, !phone.isEmpty {
                        Text("Phone: \(phone)")
                    }
                    if let cell = teacher.cellPhone, !cell.isEmpty {
                        Text("Cell: \(cell)")
                    }
                    if let website = teacher.personalWebsite, !website.isEmpty {
                        Text("Website: \(website)")
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Teacher Info")
    }
}
