//
//  ContentView.swift
//  resumeInterface
//
//  Created by Lauren Meintzer on 6/3/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ResumeUploader: View {
    @State private var fileURL: URL?
    @State private var score: Int?

    var body: some View {
        VStack(spacing: 20) {
            if let score = score {
                Text("Resume Score: \(score)")
                    .font(.title)
            }

            Button("Select Resume") {
                showFilePicker = true
            }

            if let fileURL = fileURL {
                Text("Selected: \(fileURL.lastPathComponent)")
                Button("Upload Resume") {
                    uploadResume(fileURL: fileURL)
                }
            }
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [UTType.plainText, UTType(filenameExtension: "docx")!],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                fileURL = urls.first
            case .failure(let error):
                print("File selection failed: \(error.localizedDescription)")
            }
        }
        .padding()
    }

    @State private var showFilePicker = false

    func uploadResume(fileURL: URL) {
        var request = URLRequest(url: URL(string: "http://127.0.0.1:5000/upload")!)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()
        let filename = fileURL.lastPathComponent
        guard let fileData = try? Data(contentsOf: fileURL) else { return }

        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        URLSession.shared.uploadTask(with: request, from: data) { responseData, _, _ in
            if let data = responseData,
               let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let score = response["score"] as? Int {
                DispatchQueue.main.async {
                    self.score = score
                }
            }
        }.resume()
    }
}

#Preview {
    ResumeUploader()
}

