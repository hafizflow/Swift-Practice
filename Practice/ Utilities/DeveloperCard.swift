import SwiftUI

    // Developer Card Component
struct DeveloperCard: View {
    let image: String
    let name: String
    let field: String
    let description: String
    let socialLinks: [SocialLink]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 12) {
                        Image(image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 55, height: 55)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(name)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            
                            Text(field)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(.bottom, 4)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 2)
                }
                
                    // Social Links with Asset Images
                HStack(spacing: 8) {
                    ForEach(socialLinks, id: \.platform) { link in
                        Button(action: {
                            if let url = URL(string: link.url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Image(link.iconName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 35, height: 35)
                                .background(.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
        .background(.white.opacity(0.10))
        .cornerRadius(16)
    }
}

    // Updated Social Link Model
struct SocialLink {
    let platform: String
    let iconName: String
    let url: String
    
        // Convenience initializer for asset images
    init(platform: String, assetName: String, url: String) {
        self.platform = platform
        self.iconName = assetName
        self.url = url
    }
}

    // Updated Settings Section for Developer
struct DeveloperSection: View {
    var body: some View {
        SettingsSection(title: "Developer") {
            VStack(alignment: .center, spacing: 16) {
                // Evaan
                DeveloperCard(
                    image: "evaan",
                    name: "Abdullah Rahman Evaan",
                    field: "Web Developer",
                    description: "Full-stack developer passionate about building secure web apps with Django, creating elegant solutions with Laravel, and crafting functional iOS apps with SwiftUI.",
                    socialLinks: [
                        SocialLink(
                            platform: "GitHub",
                            assetName: "github",
                            url: "https://github.com/evaan321"
                        ),
                        SocialLink(
                            platform: "LinkedIn",
                            assetName: "linkedin",
                            url: "https://www.linkedin.com/in/evaan321"
                        ),
                        SocialLink(
                            platform: "Telegram",
                            assetName: "telegram",
                            url: "http://t.me/evaan321"
                        ),
//                        SocialLink(
//                            platform: "Portfolio",
//                            assetName: "portfolio",
//                            url: "mailto:hafizur@example.com"
//                        )
                    ]
                )
                
                // Shukla
                DeveloperCard(
                    image: "shukla",
                    name: "Shukla Ghosh",
                    field: "IOS Developer",
                    description: "Creative iOS Developer dedicated to building intuitive and high-quality apps using Swift & SwiftUI, while ensuring exceptional UI/UX design for seamless user experiences.",
                    socialLinks: [
                        SocialLink(
                            platform: "GitHub",
                            assetName: "github",
                            url: "https://github.com/shuk29"
                        ),
                        SocialLink(
                            platform: "LinkedIn",
                            assetName: "linkedin",
                            url: "https://www.linkedin.com/in/shuk29"
                        ),
                        SocialLink(
                            platform: "Facebook",
                            assetName: "facebook",
                            url: "https://www.facebook.com/shuk.29"
                        ),
                    ]
                )
                
                // Hafiz
                DeveloperCard(
                    image: "hafiz",
                    name: "Hafizur Rahman",
                    field: "Mobile & Backend",
                    description: "Passionate and versatile developer skilled in building elegant web solutions with Laravel, and crafting high-performance, powerful mobile apps using Swift and Flutter.",
                    socialLinks: [
                        SocialLink(
                            platform: "GitHub",
                            assetName: "github",
                            url: "https://github.com/hafizflow"
                        ),
                        SocialLink(
                            platform: "LinkedIn",
                            assetName: "linkedin",
                            url: "https://linkedin.com/in/hafizflow"
                        ),
                        SocialLink(
                            platform: "Telegram",
                            assetName: "telegram",
                            url: "http://t.me/hafizflow45"
                        ),
                        //                        SocialLink(
                        //                            platform: "Portfolio",
                        //                            assetName: "portfolio",
                        //                            url: "mailto:hafizur@example.com"
                        //                        )
                    ]
                )
            }
        }
    }
}



#Preview {
//    DeveloperCard(
//        image: "hafiz",
//        name: "Shukla Ghosh",
//        field: "IOS Developer",
//        description: "Creative iOS Developer dedicated to building intuitive and high-quality apps using Swift & SwiftUI, while ensuring exceptional UI/UX design for seamless user experiences.",
//        socialLinks: [
//            SocialLink(
//                platform: "GitHub",
//                assetName: "github",
//                url: "https://github.com/shuk29"
//            ),
//            SocialLink(
//                platform: "LinkedIn",
//                assetName: "linkedin",
//                url: "https://www.linkedin.com/in/shuk29"
//            ),
//            SocialLink(
//                platform: "Facebook",
//                assetName: "facebook",
//                url: "https://www.facebook.com/shuk.29"
//            ),
//        ]
//    )
    
    DeveloperSection()
}
