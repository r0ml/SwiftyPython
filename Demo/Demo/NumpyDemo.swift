
import SwiftUI
import AVKit
import Caerbannog

extension Demo {
  static public func runNumpyDemo() {
    let str = """
import numpy as np
fs = 8000 # Hz
T = 1. # second, arbitrary length of tone

# 1 kHz sine wave, 1 second long, sampled at 8 kHz
t = np.arange(0, T, 1/fs)
x = ((np.sin(2*np.pi*1000*t)+np.sin(2*np.pi*1333*t)+np.sin(2*np.pi*800*t))/3).astype(np.float32)
"""
    
    if let hh = Python.run(str, returning: "x") {
    
      let hmx = [Float](numpyArray: hh)!
      DispatchQueue.global().async { self.play(hmx) }
    } else {
      print("numpy demo failed")
    }
  }
  
  static func play(_ snd : [Float]) {

    // pcmFormatInt16 gives me an error? -- apparently not supported
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: Double(snd.count), channels: 1, interleaved: false)

    let buf = AVAudioPCMBuffer.init(pcmFormat: format!, frameCapacity: AVAudioFrameCount(snd.count))!
    buf.frameLength = AVAudioFrameCount(snd.count)
    
    let ab = buf.floatChannelData!.pointee
    
      (0..<snd.count).forEach { ab[$0] =  snd[$0] }
    let audioEngine = AVAudioEngine()
    let playerNode = AVAudioPlayerNode()

    audioEngine.attach(playerNode)
    audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)

    audioEngine.prepare()
    
    
    do {
      try audioEngine.start()
    } catch {
      print("audio engine didn't start \(error.localizedDescription)")
    }
    
    playerNode.play()
    playerNode.scheduleBuffer(buf)

    Thread.sleep(forTimeInterval: 2)
  }
}
