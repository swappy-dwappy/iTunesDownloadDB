//
//  EpisodeRow.swift
//  iTunes
//
//  Created by Sonkar, Swapnil on 19/05/24.
//

import SwiftUI

struct EpisodeRow: View {
    
    let episode: Episode?
    let onButtonPressed: ()-> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: onButtonPressed) {
                Image(systemName: buttonImageName)
                    .font(.title3)
                    .frame(width: 24, height: 32)
            }
            .tint(downloadTint)
            .buttonStyle(.borderedProminent)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(episode?.title ?? "Episode Title")
                    .font(.headline)
                
                Text(details ?? "Episode Details")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if progress > 0 && progress < 1.0 {
                    ProgressView(value: progress)
                        .tint(downloadTint)
                }
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .redacted(reason: episode == nil ? .placeholder : [])
    }
}

private extension EpisodeRow {
    var details: String? {
        guard let episode else { return nil }
        return episode.date.formatted(date: .long, time: .omitted)
        + " - " + episode.duration.formatted()
    }
    
    var progress: Double {
        return episode?.progress ?? 0.0
    }
    
    var buttonImageName: String {
        switch (progress, episode?.isDownloading ?? false) {
        case (1.0, _): return "checkmark.circle.fill"
        case (_, true): return "pause.fill"
        case (0.0.nextUp..<1.0, false): return "play.fill"
        default: return "tray.and.arrow.down"
        }
    }
    
    var downloadTint: Color {
        switch (progress, episode?.isDownloading ?? false) {
        case (1.0, _): return .green
        case (_, true): return .yellow
        case (0.0.nextUp..<1.0, false): return .red
        default: return .blue
        }
    }
}

#Preview {
    Text("Swappy")
}
