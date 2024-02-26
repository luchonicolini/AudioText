//
//  AudioTextView.swift
//  AudioText
//
//  Created by Luciano Nicolini on 26/02/2024.
//

import SwiftUI
import AVKit

struct AudioTextView: View {
    @StateObject private var transcriber = AudioTranscriber()
    @State private var isRecording = false

    var body: some View {
        VStack {
            HStack {
                if transcriber.isAuthorized {
                    Button(action: {
                        if isRecording {
                            transcriber.stopTranscribing()
                        } else {
                            transcriber.startTranscribing()
                        }
                        isRecording.toggle()
                    }) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                    }
                } else {
                    Text("El reconocimiento de voz no está autorizado")
                        .foregroundColor(.red)
                }

                Spacer()

                if isRecording {
                    Button(action: {
                        transcriber.stopTranscribing() // Stop button
                        isRecording = false
                    }) {
                        Text("Detener")
                    }
                }
            }

            if isRecording {
                Text("Transcribiendo...")
                    .foregroundColor(.gray)
            }

            ScrollView {
                Text(transcriber.transcription)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                    .lineLimit(nil) // Remove line limit to accommodate long transcriptions
            }
        }
        .onAppear(perform: transcriber.requestSpeechAuthorization)
       
    }
}





#Preview {
    AudioTextView()
}




//.onChange(of: transcriber.error) { oldValue, newValue  in
//showError = newValue != nil
