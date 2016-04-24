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
#import "WaveGenetor.h"

static const float MAX_PHASE = 2.0;
static const float DEFAULT_FREQUENCY = 100.0;

@interface WaveGenetor () {
    float phase;
    NSMutableArray* waveform;
}

@end

@implementation WaveGenetor

-(id)init:(int)sampleRate resolution:(int)resolution {
    self = [super init];
    if (self) {
        _sampleRate = sampleRate;
        _resolution = resolution;
        self.frequency = DEFAULT_FREQUENCY;
    }
    return self;
}

-(void)updateWaveform{
    waveform = [[NSMutableArray alloc] init];
    
    for (int i=0; i<_resolution; i++) {
        [waveform addObject:[NSNumber numberWithFloat:0.0]];
    }
    
    float waveformStep = (M_PI * MAX_PHASE) / (float)[waveform count];
    for (int i=0; i<[waveform count]; i++){
        [waveform setObject:[NSNumber numberWithFloat:(float)sin(i * waveformStep)] atIndexedSubscript:i];
    }
}

-(float)getWavetableSample{
    int waveformIndex = (int)(phase * [waveform count]) % [waveform count];
    double output = [[waveform objectAtIndex:waveformIndex] floatValue];
    [self updatePhase];
    return output;
}

-(void)updatePhase {
    if (phase >= MAX_PHASE) {
        phase -= MAX_PHASE;
    }
    phase += (MAX_PHASE / (self.sampleRate / self.frequency));
}

-(void)setFrequency:(float)frequency {
    _frequency = frequency;
    [self updateWaveform];
}


@end
