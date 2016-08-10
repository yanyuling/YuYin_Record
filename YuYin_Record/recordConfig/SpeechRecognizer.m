//
//  SpeechRecognizer.m
//  YuYin_Record
//
//  Created by yanyuling on 16/7/11.
//  Copyright © 2016年 yanyuling. All rights reserved.
//

#import "SpeechRecognizer.h"

@implementation SpeechRecognizer
SpeechRecognizer* staticRecognizer;

+(id)defaultRecognizer{
    if (!staticRecognizer) {
        staticRecognizer = [[SpeechRecognizer alloc] init];
    }
    return staticRecognizer;
}


-(IFlySpeechRecognizer*)iFlySpeechRecognizer{
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer =  [IFlySpeechRecognizer sharedInstance];
    }
    return _iFlySpeechRecognizer;
}

-(void)stopCallback{
    [_iFlySpeechRecognizer stopListening];
    NSLog(@"停止录制");
}

-(void)startRecorgnizeWithFilePath:(NSString*)filePath{
    
    NSLog(@"recordCallback:  %s[IN]",__func__);
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
    [_iFlySpeechRecognizer setParameter:filePath forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    BOOL ret = [_iFlySpeechRecognizer startListening];
    
    if (ret) {
        NSLog(@"启动识别服务....");
    }else{
        NSLog(@"启动识别服务失败，请稍后重试");
    }
    
}




-(void)initRecognizer
{
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
-(void)audioStreamRecorgnizeWithFilePath:(NSString*)filePath{
    
    if(!_iFlySpeechRecognizer)
    {
        [self initRecognizer];
    }
    
    if( [_iFlySpeechRecognizer isListening])
    {
        //        [_popUpView showText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束，暂不支持多路并发
        return;
    }
    [self setCurFilePath:filePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if(!filePath || [filePath length] == 0) {
        return;
    }
    
    if (![fm fileExistsAtPath:filePath]) {
        NSLog(@"文件不存在");
        return;
    }
    [_iFlySpeechRecognizer setDelegate:self];
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
//    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];
    [_iFlySpeechRecognizer setParameter: @"audio_source"  forKey:IFLY_AUDIO_SOURCE_STREAM];
    [_iFlySpeechRecognizer setParameter: @"asr_audio_path"  forKey:@"123"];


    //设置音频数据模式为音频流
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

-(void)setCurFilePath:(NSString*)filePath{
    _curFilePath = [NSString stringWithString:filePath];
}
/**
 写入音频流线程
 ****/
- (void)sendAudioThread
{
    NSLog(@"%s[IN]",__func__);
    NSData *data = [NSData dataWithContentsOfFile:_curFilePath];    //从文件中读取音频
    
    int count = 10;
    unsigned long audioLen = data.length/count;
    
    
    for (int i =0 ; i< count-1; i++) {    //分割音频
        char * part1Bytes = malloc(audioLen);
        NSRange range = NSMakeRange(audioLen*i, audioLen);
        [data getBytes:part1Bytes range:range];
        NSData * part1 = [NSData dataWithBytes:part1Bytes length:audioLen];
        
        [self.iFlySpeechRecognizer startListening];
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


#pragma mark speechRecordDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"in pcmPlayer audioPlayerDidFinishPlaying");
}

#pragma mark - IFlySpeechRecognizerDelegate
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

//音量回调函数volume 0－30
- (void) onVolumeChanged: (int)volume
{
    
}

//开始识别回调
- (void) onBeginOfSpeech
{
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


#pragma --AVAudioRecorderDelegate

//- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
//    
//}

@end
