//
//  FNSecurityService.h
//  Meddo
//
//  Created by John Shimek on 9/14/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHelper @"com.fictitiousnonsense.MeddoHelper"
#define kHelperLocation @"Contents/Library/LaunchServices/"kHelper

@interface FNSecurityService : NSObject

+ (FNSecurityService *) sharedInstance;
- (void) sendMessage:(NSString *)message;



@end
