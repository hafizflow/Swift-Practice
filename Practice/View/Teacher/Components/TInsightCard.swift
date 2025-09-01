//
//  TInsightCard.swift
//  Practice
//
//  Created by Hafizur Rahman on 24/8/25.
//

import SwiftUI

struct TInsightCard: View {
    var body: some View {
        
        let contact = ContactInfo(
            name: "Hafizur Rahman - HR",
            designation: "Lecturer",
            phone: "01736692184",
            email: "rahman15-5678@diu.edu.bd",
            room: "Unknown"
        )
        
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                    // Name
                Text(contact.name)
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
                    AsyncImage(url: URL(string: "https://raw.githubusercontent.com/shuk29/Routine_Scraper_/refs/heads/main/Images/5.jpg")) { image in
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
                            
                            Text(contact.designation)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        
                        HStack(alignment: .center, spacing: 0) {
                            Text("Phone: ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.gray)
                            
                            Link(contact.phone, destination: URL(string: "tel:\(contact.phone)")!)
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundStyle(.teal.opacity(0.8))
                            
                            Spacer()
                            
                                // Copy button for cell number
                            Button(action: {
                                    // Copy cell number to clipboard
                                UIPasteboard.general.string = contact.phone
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                            }) {
                                    // SF Symbol for copy button
                                Image(systemName: "square.on.square")
                                    .foregroundColor(.teal.opacity(0.9))
                                    .font(.system(size: 16))
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
                    
                    Text(AttributedString(stringLiteral: contact.email))
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))
                        .textSelection(.enabled)
                    
                    Spacer()
                    
                        // Copy button for email
                    Button(action: {
                            // Copy email address to clipboard
                        UIPasteboard.general.string = contact.email
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }) {
                            // SF Symbol for copy button
                        Image(systemName: "square.on.square")
                            .foregroundColor(.teal.opacity(0.9))
                            .font(.system(size: 16))
                    }
                }
                
                
                    // Room
                HStack (alignment: .center, spacing: 0){
                    Text("Room: ")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    
                    Text("Unknown")
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
        
            VStack(alignment: .leading, spacing: 8) {
                Text("Provided Course")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(.teal.opacity(0.9))
                    .brightness(-0.2)
                    .padding(.bottom, 6)
                
                VStack(spacing: 8) {
                    HStack(alignment: .center) {
                        Text("Data Structure & Algorithm")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        Spacer()
                        Text("CSE333")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    HStack(alignment: .center) {
                        Text("System Analysis & Design")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        Spacer()
                        Text("CSE232")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    HStack(alignment: .center) {
                        Text("Software Development Lab")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        Spacer()
                        Text("CSE343")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .padding(.bottom, 16)
                
                Divider()
                    .frame(height: 1)
                    .background(.gray.opacity(0.45))
                    .padding(.bottom, 16)
                
                
                    // Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.fixed(80), spacing: 12),
                ], spacing: 16) {
                    
                    
                        // Total Course Enrolled
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.testBg)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.gray.opacity(0.45), lineWidth: 1)
                            )
                        
                        Text("Total Course Provided: 4")
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                            .fontWeight(.bold)
                            .font(.headline)
                            .padding(.horizontal, 8)
                            .lineSpacing(4)
                    }
                    
                    
                        // Total weekly class
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.testBg)
                            .frame(height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(.gray.opacity(0.45), lineWidth: 1)
                            )
                        
                        Text("Total Weekly Class: 5")
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.8))
                            .fontWeight(.bold)
                            .font(.headline)
                            .padding(.horizontal, 8)
                            .lineSpacing(4)
                    }
                    
                        // Download PDF
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
            .padding(15)
            .cornerRadius(12)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.testBg)
                    .shadow(color: .gray.opacity(0.75), radius: 2)
            }
        }
    }
}


#Preview {
    TInsightCard()
}

