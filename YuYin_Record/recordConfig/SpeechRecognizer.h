//
//  SpeechRecognizer.h
//  YuYin_Record
//
//  Created by yanyuling on 16/7/11.
//  Copyright © 2016年 yanyuling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import<AVFoundation/AVFoundation.h>
#import "iflyMSC/IFlyMSC.h"
#import "IATConfig.h"
#include "ISRDataHelper.h"
@interface SpeechRecognizer : NSObject <IFlySpeechRecognizerDelegate,IFlySpeechRecognizerDelegate,AVAudioPlayerDelegate>
@property(nonatomic,weak) IFlySpeechRecognizer* iFlySpeechRecognizer;
@property(nonatomic,strong)NSString* curFilePath;
@property(nonatomic,strong)NSString* resultStr;

+(id)defaultRecognizer;
-(void)audioStreamRecorgnizeWithFilePath:(NSString*)filePath;
@end
