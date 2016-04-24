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
#import "BinauralBeat.h"
#import "WaveGenetor.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

//setup some constants
const Float64 sampleRate = 44100.0;
const int waveformResolution = 1024;
const float initialBeatFrequency = 100.0;
const float initialBaseFrequency = 10.0;

WaveGenetor* oscillatorLeft;
WaveGenetor* oscillatorRight;

//render our output
OSStatus renderAudioOutput(void *inRefCon,
                           AudioUnitRenderActionFlags *ioActionFlags,
                           const AudioTimeStamp *inTimeStamp,
                           UInt32 inBusNumber,
                           UInt32 inNumberFrames,
                           AudioBufferList *ioData){
    
    float* bufferL = (Float32*)ioData->mBuffers[0].mData;
    float* bufferR = (Float32*)ioData->mBuffers[1].mData;
    
    for (UInt32 i =0; i< inNumberFrames; i++) {
        bufferL[i] = [oscillatorLeft getWavetableSample];
        bufferR[i] = [oscillatorRight getWavetableSample];
    }
    
    return noErr;
}

@interface BinauralBeat () {
    AudioComponentInstance _outputUnit;
}
    
@end

@implementation BinauralBeat

-(id)init {
    self = [super init];
    if (self) {
        _beatFrequency = initialBeatFrequency;
        _baseFrequency = initialBaseFrequency;
        [self initAudioController];
        [self createOscillators];
        self.beatFrequency = _beatFrequency;
        self.baseFrequency = _baseFrequency;
    }
    return self;
}

-(void)initAudioController{
    //configure the search parameters to find the default playback output unit
    //kAudioUnitSubType_RemoteIO on iOS, kAudioUnitSubType_DefaultOutput on Mac OS X
    AudioComponentDescription defaultOutputDescription;
    
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;

    
    AudioComponent defaultOutput = AudioComponentFindNext(NULL,
                                                          &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output!");
    
    OSErr err = AudioComponentInstanceNew(defaultOutput, &_outputUnit);
    NSAssert1(_outputUnit, @"Error creating unit: %hd", err);
    
    AURenderCallbackStruct renderCallbackStruct;
    renderCallbackStruct.inputProc = renderAudioOutput; // our audio controller will use our render output function
    renderCallbackStruct.inputProcRefCon = (__bridge void*) self;
    
    err = AudioUnitSetProperty(_outputUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &renderCallbackStruct,
                               sizeof(renderCallbackStruct));
    
    NSAssert1(err == noErr, @"Error setting callback: %hd", err);
    
    const int four_bytes_per_float = 4;
    const int eight_bytes_per_float = 8;
    
    AudioStreamBasicDescription format;
    format.mSampleRate = sampleRate;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    format.mBytesPerPacket = four_bytes_per_float;
    format.mFramesPerPacket = 2;
    format.mBytesPerFrame = four_bytes_per_float;
    format.mChannelsPerFrame = 2; //set up two channels for left and right
    format.mBitsPerChannel = (four_bytes_per_float * eight_bytes_per_float)*2;
    
    err = AudioUnitSetProperty(_outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &format, sizeof(format));
}

-(void)play{
    OSErr err  = AudioUnitInitialize (_outputUnit);
    err = AudioOutputUnitStart (_outputUnit);
    self.playing = true;
}

-(void)stop{
    OSErr err  = AudioUnitUninitialize (_outputUnit);
    err = AudioOutputUnitStop (_outputUnit);
    self.playing = false;
}

-(void)createOscillators{
    oscillatorLeft = [[WaveGenetor alloc] init:sampleRate resolution:waveformResolution];
    oscillatorRight = [[WaveGenetor alloc] init:sampleRate resolution:waveformResolution];
}

-(void)setBeatFrequency:(float)frequency {
    _beatFrequency = frequency;
    oscillatorLeft.frequency = self.baseFrequency - (frequency / 2);
    oscillatorRight.frequency = self.baseFrequency + (frequency / 2);
}

-(void)setBaseFrequency:(float)carrierFrequency {
    _baseFrequency = carrierFrequency;
    oscillatorLeft.frequency = carrierFrequency - (self.beatFrequency /2);
    oscillatorRight.frequency = carrierFrequency + (self.beatFrequency /2);
}

@end
