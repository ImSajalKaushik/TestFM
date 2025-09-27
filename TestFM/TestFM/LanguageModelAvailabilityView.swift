//
//  LanguageModelAvailabilityView.swift
//  TestFM
//
//  Created by Sajal Kaushik on 27/09/25.
//


import SwiftUI
import FoundationModels

struct LanguageModelAvailabilityView: View {
    var body: some View {
        switch SystemLanguageModel.default.availability {
        case .available:
            EmptyView()
        case .unavailable(let reason):
            let text = switch reason {
            case .appleIntelligenceNotEnabled:
                "Apple Intelligence is not enabled. Please enable it in Settings."
            case .deviceNotEligible:
                "This device is not eligible for Apple Intelligence. Please use a compatible device."
            case .modelNotReady:
                "The language model is not ready yet. Please try again later."
            @unknown default:
                "The language model is unavailable for an unknown reason."
            }
            ContentUnavailableView(text, systemImage: "apple.intelligence.badge.xmark")
                .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}
