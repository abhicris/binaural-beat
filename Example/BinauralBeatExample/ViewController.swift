/*
 MIT License
 
 Copyright (c) 2016 Agustin Prats
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */
import UIKit

class ViewController: UIViewController {
    
    let binauralBeat = BinauralBeat()
    
    @IBOutlet weak var baseFreqSlider: UISlider!
    @IBOutlet weak var beatFreqSlider: UISlider!
    @IBOutlet weak var baseFreqValueLabel: UILabel!
    @IBOutlet weak var beatFreqValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        binauralBeat.baseFrequency = baseFreqSlider.value
        binauralBeat.beatFrequency = beatFreqSlider.value
    }

    @IBAction func baseFreqSliderValueChanged() {
        baseFreqValueLabel.text = String(Int(baseFreqSlider.value))
        binauralBeat.baseFrequency = baseFreqSlider.value
    }
    
    @IBAction func beatFreqSliderValueChanged() {
        beatFreqValueLabel.text = String(Int(beatFreqSlider.value))
        binauralBeat.beatFrequency = beatFreqSlider.value
    }
    
    @IBAction func playButtonPressed() {
        binauralBeat.playing ? binauralBeat.stop() : binauralBeat.play()
    }
}

