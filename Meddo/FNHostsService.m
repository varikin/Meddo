//
//  FNHostsController.m
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNHostsService.h"
#include <arpa/inet.h>


@interface FNHostsService()

- (NSArray *) tokenize:(NSString *)line;
- (BOOL) isIPAddress:(NSString *)string;

@end

@implementation FNHostsService

@synthesize _hosts = hosts;

+ (FNHostsService *) sharedInstance {
    static FNHostsService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FNHostsService alloc] init];
    });
    return sharedInstance;
}


- (void) write {
    // TODO: Implement!
}

- (void) read {
    NSError *error;
    NSString *allTheLines = [NSString stringWithContentsOfFile:kHostFile
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if (error != nil) {
        NSLog(@"Some freaking error: %@", error);
        return;
    }
    

    NSArray *lines = [allTheLines componentsSeparatedByCharactersInSet:
                      [NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        NSArray *tokens = [self tokenize:line];
        
        // If the first token starts with a #, it is either:
        // 1. A comment
        // 2. A commented out host entry
        
        
        if ([tokens count] > 1) {
            NSString *first = [tokens objectAtIndex:0];
            if ([first characterAtIndex:0] == '#') {
                NSString *second = [tokens objectAtIndex:1];
                if ([self isIPAddress:second]) {
                    
                }
                
            }
        }
    }
}

- (NSArray *) tokenize:(NSString *)line {
    // Trimming
    line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Bug out early!
    if ([line length] == 0) {
        return nil;
    }
    
    // Splitting into tokens
    NSArray *tokens = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // Removing any empty tokesn
    tokens = [tokens filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.length > 0"]];
    
    // Should NEVER happen since there was something in the line, but why take chances
    if ([tokens count] == 0) {
        return nil;
    }
    
    // Separate first token into two if it starts with a octothrope
    NSString *first = [tokens objectAtIndex:0];
    if ([first length] > 1 && [first characterAtIndex:0] == '#') {
        // Create the new first and second tokens
        NSString *second = [first substringFromIndex:1];
        first = @"#";
        
        // Create a new array for said tokens
        NSMutableArray *validTokens = [NSMutableArray arrayWithCapacity:[tokens count] + 1];
        [validTokens addObject:first];
        [validTokens addObject:second];
        
        // Slice the first token off the original array
        NSRange range = NSMakeRange(1, [tokens count] - 1);
        [validTokens addObjectsFromArray:[tokens subarrayWithRange:range]];
        
        // Remake the array
        tokens = [NSArray arrayWithArray:validTokens];
    }
    
    return tokens;
}

- (BOOL) isIPAddress:(NSString *)string {
    
    // Using the awesome ARPANET!
    // Some BSD library that needs cStrings
    const char *cString = [string UTF8String];
    int success;
    
    // Check for ipv4 address
    struct in_addr ipv4;
    success = inet_pton(AF_INET, cString, &ipv4);
    
    // Check for ipv6 address
    if (success != 1) {
        struct in6_addr ipv6;
        success = inet_pton(AF_INET6, cString, &ipv6);
    }
    
    return success == 1;
}

@end
