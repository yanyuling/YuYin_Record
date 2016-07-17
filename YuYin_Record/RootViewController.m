//
//  RootViewController.m
//  YuYin_Record
//
//  Created by yanyuling on 16/7/6.
//  Copyright © 2016年 yanyuling. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import<AVFoundation/AVFoundation.h>

#import "RootViewController.h"
#import "iflyMSC/IFlyMSC.h"
#import "IATConfig.h"
#include "ISRDataHelper.h"

@interface RootViewController () <IFlySpeechRecognizerDelegate,IFlySpeechRecognizerDelegate,AVAudioPlayerDelegate>
@property(nonatomic,strong) UIButton* recordBtn;
@property(nonatomic,strong) UIButton* stopBtn;
@property(nonatomic,strong) UIButton* streamRecognise;
@property(nonatomic,strong) AVAudioPlayer* player;
@property(nonatomic,weak) IFlySpeechRecognizer* iFlySpeechRecognizer;
@property(nonatomic,strong)NSString* pcmFilePath;
@property(nonatomic,assign)BOOL isStop;
@property(nonatomic,strong)NSString* resultStr;
@property(nonatomic,strong) AVAudioRecorder* recorder;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
   
     [self initUIParams];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"%s",__func__);
    
    [_iFlySpeechRecognizer cancel]; //取消识别
    [_iFlySpeechRecognizer setDelegate:nil];
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    [super viewWillDisappear:animated];
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
  
    
}
-(void)initAudioRecorder{
    /*
    //文件存放路径
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *savePath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    savePath=[savePath stringByAppendingPathComponent:[formatter stringFromDate:[NSDate date]]];
    NSLog(@"initAudioRecorder : %@",savePath);
    NSURL *fileName=[NSURL fileURLWithPath:savePath];
    
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
    _recorder.delegate = self;
    [_recorder prepareToRecord];
    [_recorder record];
     */
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IFlySpeechRecognizer*)iFlySpeechRecognizer{
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer =  [IFlySpeechRecognizer sharedInstance];
    }
    return _iFlySpeechRecognizer;
}

-(void)stopCallback{
    [_iFlySpeechRecognizer stopListening];
//    [self audioStreamBtnHandler];
    self.isStop = YES;
    NSLog(@"停止录制");
    //然后开始播放音频
}

-(void)initFileSavePath{
    //demo录音文件保存路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    _pcmFilePath = [NSString stringWithFormat:@"%@",[cachePath stringByAppendingPathComponent:@"asr.pcm"]];
    
    NSLog(@"_pcmFilePath: %@",_pcmFilePath);
   
}
-(void)recordCallback{

    NSLog(@"recordCallback:  %s[IN]",__func__);
    self.isStop = NO;
    [self initFileSavePath];
    if(_iFlySpeechRecognizer == nil)
    {
        [self initRecognizer];
    }
    
    [_iFlySpeechRecognizer cancel];
    
    //设置音频来源为麦克风
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:_pcmFilePath forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_iFlySpeechRecognizer setDelegate:self];
    
    BOOL ret = [_iFlySpeechRecognizer startListening];
    
    if (ret) {
        NSLog(@"启动识别服务....");
    }else{
        NSLog(@"启动识别服务失败，请稍后重试");
    }

    
    
}

/*!
 *  识别结果回调
 *    在进行语音识别过程中的任何时刻都有可能回调此函数，你可以根据errorCode进行相应的处理，
 *  当errorCode没有错误时，表示此次会话正常结束；否则，表示此次会话有错误发生。特别的当调用
 *  `cancel`函数时，引擎不会自动结束，需要等到回调此函数，才表示此次会话结束。在没有回调此函数
 *  之前如果重新调用了`startListenging`函数则会报错误。
 *
 *  @param errorCode 错误描述
 */
- (void) onError:(IFlySpeechError *) errorCode{
    NSLog(@"onError: %@",errorCode.errorDesc);
    NSLog(@"onError: %d",errorCode.errorCode);
    NSLog(@"onError: %d",errorCode.errorType);
}


-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    
    
    //单例模式，无UI的实例
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    }
    _iFlySpeechRecognizer.delegate = self;
    IATConfig *instance = [IATConfig sharedInstance];
    
    //设置最长录音时间
    [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    //设置后端点
    [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
    //设置前端点
    [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
    //网络等待时间
    [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
    
    //设置采样率，推荐使用16K
    [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    if ([instance.language isEqualToString:[IATConfig chinese]]) {
        //设置语言
        [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        //设置方言
        [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
    }else if ([instance.language isEqualToString:[IATConfig english]]) {
        [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
    }
    //设置是否返回标点符号
    [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    
    
    
}


/**
 音频流识别启动
 ****/
- (void)audioStreamBtnHandler {
    
    
    if(_iFlySpeechRecognizer)
    {
        [self initRecognizer];
    }
    
    if( [_iFlySpeechRecognizer isListening])
    {
        //        [_popUpView showText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
        return;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(!_pcmFilePath || [_pcmFilePath length] == 0) {
        return;
    }
    
    if (![fm fileExistsAtPath:_pcmFilePath]) {
        NSLog(@"文件不存在");
        return;
    }
    
    [_iFlySpeechRecognizer setDelegate:self];
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];    //设置音频数据模式为音频流
    BOOL ret  = [_iFlySpeechRecognizer startListening];
    
    
    if (ret) {
        [NSThread detachNewThreadSelector:@selector(sendAudioThread) toTarget:self withObject:nil];
        NSLog(@"识别成功");
    }
    else
    {
        NSLog(@"识别失败");
    }
}


/**
 写入音频流线程
 ****/
- (void)sendAudioThread
{
    NSLog(@"%s[IN]",__func__);
    NSData *data = [NSData dataWithContentsOfFile:_pcmFilePath];    //从文件中读取音频
    
    int count = 10;
    unsigned long audioLen = data.length/count;
    
    
    for (int i =0 ; i< count-1; i++) {    //分割音频
        char * part1Bytes = malloc(audioLen);
        NSRange range = NSMakeRange(audioLen*i, audioLen);
        [data getBytes:part1Bytes range:range];
        NSData * part1 = [NSData dataWithBytes:part1Bytes length:audioLen];
        
       
        [self playAudioWithData:[NSData dataWithData:part1]];
        
        int ret = [self.iFlySpeechRecognizer writeAudio:part1];//写入音频，让SDK识别
        free(part1Bytes);
        
        
        if(!ret) {     //检测数据发送是否正常
            NSLog(@"%s[ERROR]",__func__);
            [self.iFlySpeechRecognizer stopListening];
            
            return;
        }
    }
    
    //处理最后一部分
    unsigned long writtenLen = audioLen * (count-1);
    char * part3Bytes = malloc(data.length-writtenLen);
    NSRange range = NSMakeRange(writtenLen, data.length-writtenLen);
    [data getBytes:part3Bytes range:range];
    NSData * part3 = [NSData dataWithBytes:part3Bytes length:data.length-writtenLen];
    
    [_iFlySpeechRecognizer writeAudio:part3];
    free(part3Bytes);
    [_iFlySpeechRecognizer stopListening];//音频数据写入完成，进入等待状态
    NSLog(@"%s[OUT]",__func__);
}

-(void)playAudioWithData:(NSData*)data{
    if (self.player == nil) {
        NSError *err = [[NSError alloc]init];
        
        self.player = [[AVAudioPlayer alloc]initWithData:data error:&err];
        if (err)
        {
            NSLog(@"%@",err.localizedDescription);
        }
         self.player.delegate = self;
    }
    
    [self.player play];
    
}
#pragma mark speechRecordDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"in pcmPlayer audioPlayerDidFinishPlaying");
}

#pragma mark - IFlySpeechRecognizerDelegate

//音量回调函数volume 0－30
- (void) onVolumeChanged: (int)volume
{
    if (self.isStop == YES) {
        return;
    }
//    NSLog(@"音量：%d",volume);
}

//开始识别回调
- (void) onBeginOfSpeech
{
    _resultStr = [NSString stringWithFormat:@""];
    NSLog(@"onBeginOfSpeech");
}

//停止录音回调
- (void) onEndOfSpeech
{
    NSLog(@"onEndOfSpeech");
}

/**
 无界面，听写结果回调
 resultArray：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }

    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    
   _resultStr = [NSString stringWithFormat:@"%@%@",_resultStr,resultFromJson];
     NSLog(@"resultFromJson=%@",_resultStr);
}

//听写取消回调
- (void) onCancel
{
    NSLog(@"识别取消");
}

-(void) showPopup
{
    NSLog( @"正在上传...");
}

@end


#pragma --AVAudioRecorderDelegate

//- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
//    
//}