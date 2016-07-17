//
//  VodioRecordViewController.m
//  YuYin_Record
//
//  Created by yanyuling on 16/7/11.
//  Copyright © 2016年 yanyuling. All rights reserved.
//

#import "VodioRecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SpeechRecognizer.h"
@interface VodioRecordViewController () <AVAudioPlayerDelegate, AVAudioRecorderDelegate>
@property(nonatomic,strong) AVAudioRecorder* recorder;
@property(nonatomic,strong) NSString* tmpFilePath;
@property(nonatomic,strong) UIButton* recordBtn;
@property(nonatomic,strong) UIButton* stopBtn;
@property(nonatomic,strong) UIButton* streamRecognise;
@property(nonatomic,strong) NSDateFormatter* formatter; //格式化日期
@property(nonatomic,strong) NSString* docuMentPath ;
@property(nonatomic,strong) NSString* curFilePath;
@end

@implementation VodioRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    [self initUIParams];
}

-(void)initUIParams{
    if (self.recordBtn == nil) {
        self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.recordBtn.frame = CGRectMake(50, 500, 100, 40);
        [self.recordBtn setTitle:@"开始录制" forState:UIControlStateNormal];
        [self.view addSubview:self.recordBtn];
        [self.recordBtn addTarget:self action:@selector(recordCallback) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.stopBtn == nil) {
        self.stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.stopBtn.frame = CGRectMake(200, 500, 100, 40);
        [self.stopBtn setTitle:@"停止录制" forState:UIControlStateNormal];
        [self.view addSubview:self.stopBtn];
        [self.stopBtn addTarget:self action:@selector(stopCallback) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.streamRecognise == nil) {
        self.streamRecognise = [UIButton buttonWithType:UIButtonTypeCustom];
        self.streamRecognise.frame = CGRectMake(150, 550, 100, 40);
        [self.streamRecognise setTitle:@"音频流识别" forState:UIControlStateNormal];
        [self.view addSubview:self.streamRecognise];
        [self.streamRecognise addTarget:self action:@selector(audioStreamBtnHandler) forControlEvents:UIControlEventTouchUpInside];
    }
    if(!_formatter){
        _formatter =  [[NSDateFormatter alloc] init];
    }
    if (!_docuMentPath) {
        _docuMentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    }
    
}
-(void)recordCallback{
    [self initAudioRecorder];
    
    
}
-(void)stopCallback{
    __weak typeof(self) weakSelf = self;
    [weakSelf.recorder stop];

}
-(void)audioStreamBtnHandler{
//    NSLog(@"_docuMentPath:  %@" ,[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)]);
    NSLog(@"_curFilePath:  %@" ,_curFilePath);

    NSString * tmpPath = [ _curFilePath substringFromIndex:[_docuMentPath length]-10];
    NSLog(@"tmpPath:  %@",tmpPath);
    [[SpeechRecognizer defaultRecognizer] audioStreamRecorgnizeWithFilePath:_curFilePath];
        
}
-(void)initAudioRecorder{
    _recorder = nil;
     //文件存放路径
    NSString *savePath= [NSString stringWithString:_docuMentPath];

    [_formatter setDateFormat:@"yyyy-MM-dd"];
//    [_formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    savePath=[savePath stringByAppendingPathComponent:[_formatter stringFromDate:[NSDate date]]];
    if (![[NSFileManager defaultManager] isExecutableFileAtPath:savePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
     [_formatter setDateFormat:@"HH-mm-ss"];
    savePath=[savePath stringByAppendingString:[NSString stringWithFormat:@"/%@.pcm",[_formatter stringFromDate:[NSDate date]]]];
     NSURL *fileName=[NSURL fileURLWithPath:savePath];
    _curFilePath = [NSString stringWithString:savePath];
     //settingDic
     NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
     //设置录音格式
     [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
     //设置录音采样率，8000是电话采样率，对于一般录音已经够了
     [dicM setObject:@(8000) forKey:AVSampleRateKey];
     //设置通道,这里采用单声道
     [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
     //每个采样点位数,分为8、16、24、32
     [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
     //是否使用浮点数采样
     [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
     
     //error
     NSError* error = nil;
     
     _recorder = [[AVAudioRecorder alloc] initWithURL:fileName settings:dicM error:&error];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error: nil];
    
    __weak typeof(self) weakSelf = self;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            if (1) {
                weakSelf.recorder.delegate = weakSelf;
                weakSelf.recorder.meteringEnabled = YES;
                [weakSelf.recorder record];
//                [weakSelf startUpdateMeter];
                
//                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didAudioRecordStarted:)]) {
//                    [weakSelf.delegate didAudioRecordStarted:weakSelf];
//                }
            }
        }
        else {
            NSLog(@"没有权限");
        }
    }];

    
    
     [_recorder prepareToRecord];
     [_recorder record];
     
    
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)vplayer successfully:(BOOL)flag {
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)vplayer error:(NSError *)error {
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)vplayer {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)vplayer withFlags:(NSUInteger)flags {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)vrecorder successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    NSLog(@"audioRecorderDidFinishRecording :  ");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)vrecorder error:(NSError *)error {
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)vrecorder {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
