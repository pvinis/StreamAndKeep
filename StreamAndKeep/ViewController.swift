//
//  ViewController.swift
//  StreamAndKeep
//
//  Created by Pavlos Vinieratos on 04/09/16.
//  Copyright © 2016 Pavlos Vinieratos. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

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
	@IBOutlet private var recordSwitch: UISwitch!

	@IBOutlet private var streamingLabel: UILabel!
	@IBOutlet private var recordingLabel: UILabel!

	private let rtmpConnection: RTMPConnection = RTMPConnection()
	private var rtmpRecStream: RTMPStream!
	private let streamInfo: StreamInfo = StreamInfo(uri: "rtmp://130.211.53.17:1935/live", key: "myStream")

	private var isRecording = true

	override func viewDidLoad() {
		super.viewDidLoad()

		rtmpRecStream = RTMPStream(rtmpConnection: rtmpConnection)
		rtmpRecStream.syncOrientation = true
		rtmpRecStream.recorderDelegate = RecorderDelegate()

		rtmpRecStream.attachAudio(AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio))
		rtmpRecStream.attachCamera(DeviceUtil.deviceWithPosition(.Front))
		rtmpRecStream.captureSettings = [
			"sessionPreset": AVCaptureSessionPreset1280x720,
			"continuousAutofocus": true,
			"continuousExposure": true,
		]
		rtmpRecStream.videoSettings = [
			"width": 1280,
			"height": 720,
		]
		rtmpRecStream.audioSettings = [
			"muted": false, // mute audio
			"bitrate": 32 * 1024,
		]
		rtmpRecStream.recorderSettings = [
			AVMediaTypeAudio: [
				AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
				AVSampleRateKey: 0,
				AVNumberOfChannelsKey: 0,
			],
			AVMediaTypeVideo: [
				AVVideoCodecKey: AVVideoCodecH264,
				AVVideoHeightKey: 0,
				AVVideoWidthKey: 0,
			],
		]

		lfView.attachStream(rtmpRecStream)

		streamingLabel.hidden = true
		recordingLabel.hidden = true

		cameraView.addSubview(lfView)
		lfView.bindFrameToSuperviewBounds()
	}

	@IBAction private func startButtonTapped(sender: UIButton) {
		UIApplication.sharedApplication().idleTimerDisabled = true

		isRecording = recordSwitch.on

		rtmpConnection.addEventListener(Event.RTMP_STATUS, selector:#selector(rtmpStatusHandler), observer: self)
		rtmpConnection.connect(streamInfo.uri)

		streamingLabel.hidden = false
		if isRecording {
			recordingLabel.hidden = false
		}
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
				rtmpRecStream!.publish(streamInfo.key, type: (isRecording ? .LiveAndRecord : .Live))
			default:
				break
		}
	}
}

class RecorderDelegate: DefaultAVMixerRecorderDelegate {
	override func didFinishWriting(recorder: AVMixerRecorder) {
		super.didFinishWriting(recorder)

		let moviesDirectoryContents = try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(moviesDirectory, includingPropertiesForKeys: nil, options: [])
		guard let lastMovie = moviesDirectoryContents.last else { return }

		PHPhotoLibrary.sharedPhotoLibrary().performChanges({
			PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(lastMovie)
			}, completionHandler: { (success, error) in
				if success {
					try! NSFileManager.defaultManager().removeItemAtURL(lastMovie)
				} else {
					print(error)
				}
		})
	}
}
