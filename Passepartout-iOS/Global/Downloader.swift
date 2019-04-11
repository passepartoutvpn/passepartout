//
//  Downloader.swift
//  Passepartout-iOS
//
//  Created by Davide De Rosa on 4/10/19.
//  Copyright (c) 2019 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import MBProgressHUD
import SwiftyBeaver
import Passepartout_Core

private let log = SwiftyBeaver.self

class Downloader: NSObject {
    static let shared = Downloader(temporaryURL: GroupConstants.App.cachesURL.appendingPathComponent("downloaded.tmp"))
    
    private let temporaryURL: URL
    
    private var hud: MBProgressHUD?
    
    private var completionHandler: ((URL?, Error?) -> Void)?
    
    init(temporaryURL: URL) {
        self.temporaryURL = temporaryURL
    }
    
    func download(url: URL, in view: UIView, completionHandler: @escaping (URL?, Error?) -> Void) -> Bool {
        guard hud == nil else {
            log.info("Download in progress, skipping")
            return false
        }
        
        log.info("Downloading from: \(url)")
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: AppConstants.Web.timeout)
        let task = session.downloadTask(with: request)

        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = .annularDeterminate
        hud?.progressObject = task.progress

        self.completionHandler = completionHandler
        task.resume()
        return true
    }
}

extension Downloader: URLSessionDelegate, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            log.error("Download failed: \(error)")
            hud?.hide(animated: true)
            hud = nil
            completionHandler?(nil, error)
            completionHandler = nil
            return
        }
        completionHandler = nil
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        log.info("Download complete!")
        if let url = downloadTask.originalRequest?.url {
            log.info("\tFrom: \(url)")
        }
        log.debug("\tTo: \(location)")

        let fm = FileManager.default
        do {
            try? fm.removeItem(at: temporaryURL)
            try fm.copyItem(at: location, to: temporaryURL)
        } catch let e {
            log.error("Failed to copy downloaded file: \(e)")
            return
        }

        hud?.hide(animated: true)
        hud = nil
        completionHandler?(temporaryURL, nil)
        completionHandler = nil
    }
}
