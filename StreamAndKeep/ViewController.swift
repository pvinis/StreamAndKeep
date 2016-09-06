//
//  ViewController.swift
//  StreamAndKeep
//
//  Created by Pavlos Vinieratos on 04/09/16.
//  Copyright © 2016 Pavlos Vinieratos. All rights reserved.
//

import UIKit
import AVFoundation

import lf

struct StreamInfo {
	let uri: String
	let key: String
}

class ViewController: UIViewController {

	@IBOutlet private var cameraView: UIView!
	private let lfView: GLLFView! = GLLFView(frame: CGRectZero)

	@IBOutlet private var startButton: UIButton!
	@IBOutlet private var stopButton: UIButton!

	@IBOutlet private var streamingLabel: UILabel!
	@IBOutlet private var recordingLabel: UILabel!

	private let rtmpConnection: RTMPConnection = RTMPConnection()
	private var rtmpStream: RTMPStream!
	private let streamInfo: StreamInfo = StreamInfo(uri: "rtmp://ip/live", key: "streamName")

	override func viewDidLoad() {
		super.viewDidLoad()

		rtmpStream = RTMPStream(rtmpConnection: rtmpConnection)
		rtmpStream.syncOrientation = true

		rtmpStream.attachAudio(AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio))
		rtmpStream.attachCamera(DeviceUtil.deviceWithPosition(.Front))

		rtmpStream.captureSettings = [
			"sessionPreset": AVCaptureSessionPreset1280x720,
			"continuousAutofocus": true,
			"continuousExposure": true,
		]
		rtmpStream.videoSettings = [
			"width": 1280,
			"height": 720,
		]

		lfView.attachStream(rtmpStream)
		streamingLabel.hidden = true
		recordingLabel.hidden = true

		cameraView.addSubview(lfView)
		lfView.bindFrameToSuperviewBounds()
	}

	@IBAction private func startButtonTapped(sender: UIButton) {
		UIApplication.sharedApplication().idleTimerDisabled = true

		rtmpConnection.addEventListener(Event.RTMP_STATUS, selector:#selector(rtmpStatusHandler), observer: self)
		rtmpConnection.connect(streamInfo.uri)

		streamingLabel.hidden = false
		recordingLabel.hidden = false
	}

	@IBAction private func stopButtonTapped(sender: UIButton) {
		UIApplication.sharedApplication().idleTimerDisabled = false

		rtmpConnection.addEventListener(Event.RTMP_STATUS, selector:#selector(rtmpStatusHandler), observer: self)
		rtmpConnection.close()

		streamingLabel.hidden = true
		recordingLabel.hidden = true

	}

	@objc private func rtmpStatusHandler(notification: NSNotification) {
		let e: Event = Event.from(notification)
		guard let d = e.data else { return }
		guard let data = d as? ASObject else { return }
		guard let c = data["code"] else { return }
		guard let code = c as? String else { return }

		switch code {
			case RTMPConnection.Code.ConnectSuccess.rawValue:
				rtmpStream!.publish(streamInfo.key)
			default:
				break
		}
	}
}
