//
//  LoaderView.swift
//  iTunesDownloadDB
//
//  Created by Sonkar, Swapnil on 28/05/24.
//

import SwiftUI

struct LoaderView: View {
    let text: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 200, height: 150)
                .foregroundStyle(.ultraThinMaterial)
            
            ProgressView(text)
                .multilineTextAlignment(.center)
        }
            
    }
}

#Preview {
    LoaderView(text: "Loading...")
}
