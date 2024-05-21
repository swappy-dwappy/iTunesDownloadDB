//
//  Download.swift
//  iTunes
//
//  Created by Sonkar, Swapnil on 15/05/24.
//

import Foundation

class Download: NSObject {
    
    let url: URL
    var downloadSession: URLSession
    
    var handleCompletedFile: ((Event)-> Void)?
    private var resumeData: Data?
    private var task: URLSessionDownloadTask!

    func startDownload() {
        let task = downloadSession.downloadTask(with: url)
        task.delegate = self
        self.task = task
        task.resume()
    }
    
    func resumeDownload() {
        guard let resumeData else { return }
        let task = downloadSession.downloadTask(withResumeData: resumeData)
        task.delegate = self
        self.task = task
        task.resume()
    }
    
    init(url: URL, downloadSession: URLSession) {
        self.url = url
        self.downloadSession = downloadSession
    }
    
    var isDownloading: Bool {
        task.state == .running
    }
    
    func pause() {
        task.cancel { [weak self] data in
            self?.resumeData = data
        }
    }
    
    func resume() {
        if let _ = resumeData {
            resumeDownload()
        } else {
            startDownload()
        }
    }
}

extension Download: URLSessionDownloadDelegate, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        handleCompletedFile?(.progress(currentBytes: totalBytesWritten, totalBytes: totalBytesExpectedToWrite))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        handleCompletedFile?(.success(url: location))
        task.cancel()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else {
            // Handle success case.
            return
        }
        let userInfo = (error as NSError).userInfo
        if let resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            self.resumeData = resumeData
        }
        handleCompletedFile?(.failed(error: error))
    }

}

extension Download {
    enum Event {
        case progress(currentBytes: Int64, totalBytes: Int64)
        case success(url: URL)
        case failed(error: Error)
    }
}
