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
    @State private var showError = false
    @State private var audioPlayer: AVPlayer? // Añade un reproductor de audio

    var body: some View {
        NavigationView {
            VStack {
                if transcriber.isAuthorized {
                    Image(systemName: isRecording ? "mic.fill" : "mic.slash.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                        .foregroundColor(isRecording ? .blue : .red)
                        .onTapGesture {
                            isRecording.toggle()
                            if isRecording {
                                transcriber.startTranscribing()
                            } else {
                                transcriber.stopTranscribing()
                            }
                        }

                    // Añade un botón de reproducción
                    Button(action: {
                        if let audioURL = transcriber.audioURL {
                            audioPlayer = AVPlayer(url: audioURL)
                            audioPlayer?.play()
                        }
                    }) {
                        Image(systemName: "play.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                            .foregroundColor(.blue)
                    }

                    ScrollView {
                        Text(transcriber.transcription)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding()
                    }
                    .frame(height: 200)
                } else {
                    Text("El reconocimiento de voz no está autorizado")
                        .foregroundColor(.red)
                }
            }
            .onAppear(perform: transcriber.requestSpeechAuthorization)
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(transcriber.error ?? ""), dismissButton: .default(Text("OK")) {
                    transcriber.error = nil
                })
            }
            .onChange(of: transcriber.error) { oldValue, newValue in
                showError = transcriber.error != nil
            }
            .navigationBarTitle("Transcriptor de Audio", displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                // Aquí debes implementar la lógica para importar o exportar archivos de audio
            }) {
                Image(systemName: "square.and.arrow.down")
            })
        }
    }
}







#Preview {
    AudioTextView()
}




//.onChange(of: transcriber.error) { oldValue, newValue  in
//showError = newValue != nil
