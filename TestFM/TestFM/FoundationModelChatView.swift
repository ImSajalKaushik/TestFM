//
//  FoundationModelChatView.swift
//  TestFM
//
//  Created by Sajal Kaushik on 27/09/25.
//


import SwiftUI
import FoundationModels

struct FoundationModelChatView: View {
    @State private var langModelSession = LanguageModelSession(
        model: .default,
        tools: [],
        instructions: "You are a helpful AI assistant. Provide clear, concise, and accurate responses to user queries. Be friendly and informative."
    )
    
    @State private var userInput: String = ""
    @State private var isResponding: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    // Common prompt chips
    private let commonPrompts = [
        "Explain this concept",
        "Summarize this text",
        "Write a code example",
        "Create a list",
        "Help me brainstorm",
        "Provide tips",
        "Compare options",
        "Solve this problem"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                LanguageModelAvailabilityView()
                
                // Input Section
                inputSection
                
                // Common Prompts Chips
                promptChipsSection
                
                // Response Display
                NavigationLink {
                    ChatResponseView(
                        langModelSession: langModelSession,
                        userQuery: userInput
                    )
                } label: {
                    HStack {
                        Image(systemName: "brain.head.profile")
                        Text("Start Conversation")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("AI Assistant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var inputSection: some View {
        GroupBox("Your Message") {
            VStack(spacing: 12) {
                TextField(
                    "Type your message here...",
                    text: $userInput,
                    axis: .vertical
                )
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)
                .lineLimit(3...8)
                
                HStack {
                    Button("Clear") {
                        userInput = ""
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .disabled(userInput.isEmpty)
                    
                    Spacer()
                    
                    Text("\(userInput.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var promptChipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Quick Prompts")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(commonPrompts, id: \.self) { prompt in
                        PromptChip(
                            title: prompt,
                            isSelected: userInput.contains(prompt)
                        ) {
                            if userInput.contains(prompt) {
                                userInput = userInput.replacingOccurrences(of: prompt, with: "")
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                            } else {
                                if !userInput.isEmpty && !userInput.hasSuffix(" ") {
                                    userInput += " "
                                }
                                userInput += prompt
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct PromptChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? 
                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [.gray.opacity(0.2)], startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? .clear : .gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct ChatResponseView: View {
    let langModelSession: LanguageModelSession
    let userQuery: String
    
    @State private var response: String = ""
    @State private var isLoading: Bool = false
    @State private var error: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // User Query Display
                GroupBox("Your Question") {
                    Text(userQuery)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                }
                
                // AI Response Display
                GroupBox("AI Response") {
                    VStack(alignment: .leading, spacing: 12) {
                        if isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Thinking...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } else if let error = error {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        } else if response.isEmpty {
                            Text("Response will appear here...")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            Text(response)
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 100)
                    .padding(.vertical, 4)
                }
                
                // Actions
                if !response.isEmpty && !isLoading {
                    HStack {
                        Button("Copy Response") {
                            UIPasteboard.general.string = response
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                        
                        Button("Ask Follow-up") {
                            // Could navigate back or clear for new question
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("AI Response")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateResponse()
        }
    }
    
    private func generateResponse() {
        guard !userQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isLoading = true
        error = nil
        response = ""
        
        Task {
            do {
                let aiResponse = try await langModelSession.respond(
                    to: userQuery,
                    options: GenerationOptions(
                        sampling: .greedy,
                        temperature: 0.7
                    )
                )
                
                await MainActor.run {
                    response = aiResponse.content
                    isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.error = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    FoundationModelChatView()
}

#Preview("Response View") {
    NavigationStack {
        ChatResponseView(
            langModelSession: LanguageModelSession(
                model: .default,
                tools: [],
                instructions: "You are helpful"
            ),
            userQuery: "Explain how SwiftUI works"
        )
    }
}
