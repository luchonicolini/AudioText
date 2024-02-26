//
//  AudioTranscriber.swift
//  AudioText
//
//  Created by Luciano Nicolini on 26/02/2024.
//

import Foundation
import Speech

class AudioTranscriber: ObservableObject {
    @Published var isAuthorized = false
    @Published var transcription = ""
    @Published var error: String?
    
    private var recognitionTask: SFSpeechRecognitionTask? // Añade una variable para la tarea de reconocimiento

    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.isAuthorized = true
                default:
                    self.isAuthorized = false
                }
            }
        }
    }

    func transcribeAudio() {
        // Aquí debes proporcionar la URL del archivo de audio que deseas transcribir
        guard let audioURL = Bundle.main.url(forResource: "lucho", withExtension: "m4a") else {
            self.error = "No se pudo encontrar el archivo de audio"
            return
        }

        // Establece el locale del reconocedor a español
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
        let request = SFSpeechURLRecognitionRequest(url: audioURL)

        recognitionTask = recognizer?.recognitionTask(with: request) { (result, error) in
            if let error = error {
                self.error = "Hubo un error: \(error.localizedDescription)"
            } else if let result = result {
                self.transcription = result.bestTranscription.formattedString
            }
        }
    }
    
    func stopTranscribing() {
        recognitionTask?.cancel() // Detiene la tarea de reconocimiento
        recognitionTask = nil
        transcription = "" // Restablece la transcripción a cero
    }
}



