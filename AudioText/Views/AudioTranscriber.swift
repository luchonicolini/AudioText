//
//  AudioTranscriber.swift
//  AudioText
//
//  Created by Luciano Nicolini on 26/02/2024.
//

import Foundation
import Speech
import SwiftUI


class AudioTranscriber: ObservableObject {
  @Published var isAuthorized = false
  @Published var transcription = ""
  @Published var error: String?
  @State private var isRecording = false

  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  private let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale(identifier: "es-ES"))
  private let request = SFSpeechAudioBufferRecognitionRequest()
  private var audioRecorder: AVAudioRecorder?

  var audioURL: URL? {
    audioRecorder?.url
  }

  func requestSpeechAuthorization() {
    SFSpeechRecognizer.requestAuthorization { authStatus in
      DispatchQueue.main.async {
        self.isAuthorized = authStatus == .authorized
      }
    }
  }

  func startTranscribing() {
    guard let recognizer = speechRecognizer, recognizer.isAvailable else {
      self.error = "El reconocimiento de voz no está disponible"
      return
    }

    do {
      let inputNode = audioEngine.inputNode
      let recordingFormat = inputNode.outputFormat(forBus: 0)
      inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
        self?.request.append(buffer)
      }

      audioEngine.prepare()
      try audioEngine.start()

      recognitionTask = recognizer.recognitionTask(with: request) { [weak self] (result, error) in
        guard let self = self else { return }
        if let error = error {
          self.error = "Hubo un error: \(error.localizedDescription)"
        } else if let result = result {
          self.transcription = result.bestTranscription.formattedString
        }
      }

      // Inicia la grabación de audio
      let audioFilename = self.getDocumentsDirectory().appendingPathComponent("recording.m4a")
      let settings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
      ]
      audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
      audioRecorder?.record()
    } catch {
      self.error = "Hubo un error: \(error.localizedDescription)"
    }
  }

  func stopTranscribing() {
    audioEngine.stop()
    audioEngine.inputNode.removeTap(onBus: 0)
    recognitionTask?.cancel()
    recognitionTask = nil
    request.endAudio()
    transcription = "" // Restablece la transcripción a cero

    // Detiene la grabación de audio
    audioRecorder?.stop()
  }

  func cancelTranscribing() {
    isRecording = false
    stopTranscribing()
  }

  private func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}





