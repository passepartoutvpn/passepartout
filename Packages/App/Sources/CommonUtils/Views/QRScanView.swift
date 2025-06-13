//
//  QRScanView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/8/25.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
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

#if os(iOS)

import AVFoundation
import SwiftUI
import UIKit
import Vision

public struct QRScanView: UIViewControllerRepresentable {
    public final class Coordinator: NSObject {

        @Binding
        private var isAvailable: Bool

        fileprivate init(_ view: QRScanView) {
            _isAvailable = view._isAvailable
        }

        fileprivate func didLoad(withError error: Error?) {
            isAvailable = error == nil
        }
    }

    @Binding
    private var isAvailable: Bool

    private let onLoad: (Error?) -> Void

    private let onDetect: (String) -> Void

    public init(
        isAvailable: Binding<Bool>,
        onLoad: @escaping (Error?) -> Void,
        onDetect: @escaping (String) -> Void
    ) {
        _isAvailable = isAvailable
        self.onLoad = onLoad
        self.onDetect = onDetect
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let vc = QRScanViewController(
            onLoad: {
                context.coordinator.didLoad(withError: $0)
            },
            onDetect: onDetect
        )
        return vc
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

final class QRScanViewController: UIViewController {
    private struct QRScanError: Error {
    }

    private let queue = DispatchQueue(label: "QRScanViewController")

    private let session = AVCaptureSession()

    private let once: Bool

    private let onLoad: ((Error?) -> Void)?

    private var onDetect: ((String) -> Void)?

    private var didLoad = false

    required init?(coder: NSCoder) {
        fatalError()
    }

    init(
        once: Bool = true,
        onLoad: ((Error?) -> Void)? = nil,
        onDetect: @escaping (String) -> Void
    ) {
        self.once = once
        self.onLoad = onLoad
        self.onDetect = onDetect
        super.init(nibName: nil, bundle: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard !didLoad else {
            return
        }
        didLoad = true

        let input: AVCaptureDeviceInput
        do {
            guard let device = AVCaptureDevice.default(for: .video) else {
                NSLog("QR: Unable to get video device")
                throw QRScanError()
            }
            input = try AVCaptureDeviceInput(device: device)
            session.beginConfiguration()
            session.sessionPreset = .high
            session.addInput(input)

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: queue)
            session.addOutput(output)

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            session.commitConfiguration()
            queue.async { [weak self] in
                self?.session.startRunning()
            }
            onLoad?(nil)
        } catch {
            onLoad?(error)
        }
    }
}

extension QRScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            NSLog("QR: Unable to get image buffer")
            return
        }
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            if let error {
                NSLog("QR: Unable to detect: \(error)")
                return
            }
            guard let results = request.results as? [VNBarcodeObservation] else {
                NSLog("QR: Unable to get results as [VNBarcodeObservation]")
                return
            }
            for result in results where result.symbology == .qr {
                guard let payload = result.payloadStringValue else {
                    NSLog("QR: Missing payload")
                    continue
                }
                DispatchQueue.main.sync { [weak self] in
                    guard let self else {
                        return
                    }
                    onDetect?(payload)
                    if once {
                        onDetect = nil
                    }
                }
                self?.queue.async { [weak self] in
                    self?.session.stopRunning()
                }
            }
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            NSLog("QR: Unable to perform image request: \(error)")
        }
    }
}

#Preview {
    QRScanView(
        isAvailable: .constant(true),
        onLoad: { _ in },
        onDetect: { _ in }
    )
}

#endif
