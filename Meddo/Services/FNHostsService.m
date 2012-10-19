//
//  FNHostsController.m
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNHostsService.h"
#import "FNHost.h"
#import "FNHostLine.h"
#import "FNMessageService.h"
#import "Constants.h"
#include <arpa/inet.h>


@interface FNHostsService()

typedef enum {
    NoLine,
    CommentLine,
    HostLine,
    BlankLine
} LineType;

- (NSArray *) tokenize:(NSString *)line;
- (FNHostLine *) parseHostLine:(NSArray *)tokens;
- (LineType) getLineType:(NSArray *)tokens;
- (BOOL) isIPAddress:(NSString *)token;
- (BOOL) isComment:(NSString *)token;
- (NSString *) guessNameFromHost:(FNHost *)host;
- (FNHost *) saveHost:(FNHost *)host toArray:(NSMutableArray *)hosts;

@end

@implementation FNHostsService

+ (FNHostsService *) sharedInstance {
    static FNHostsService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FNHostsService alloc] init];
    });
    return sharedInstance;
}


- (void) write:(NSString *)hosts {
    [[FNMessageService sharedInstance] sendMessage:@" A message"];
}

#pragma mark - Parse methods

- (NSArray *) read {
    NSError *error;
    NSString *allTheLines = [NSString stringWithContentsOfFile:kHostFile
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if (error != nil) {
        NSLog(@"Some freaking error: %@", error);
        return [NSArray array];
    }

    NSArray *lines = [allTheLines componentsSeparatedByCharactersInSet:
                      [NSCharacterSet newlineCharacterSet]];
    
    
    NSMutableArray *hosts = [NSMutableArray arrayWithCapacity:[lines count]];
    FNHost *host = [[FNHost alloc] init];
    LineType previousType = NoLine;
    LineType currentType;
    
    for (NSString *line in lines) {
        NSArray *tokens = [self tokenize:line];
        currentType = [self getLineType:tokens];
        if (currentType == BlankLine) {
            host = [self saveHost:host toArray:hosts];
        } else if (currentType == CommentLine) {
            if (previousType == HostLine) {
                host = [self saveHost:host toArray:hosts];
            }
            [host addComment:line];
        } else if (currentType == HostLine) {
            FNHostLine *hostline = [self parseHostLine:tokens];
            if (hostline != nil) {
                [host addHostline:hostline];
            }
        }
    }
    [self saveHost:host toArray:hosts];
    return [NSArray arrayWithArray:hosts];
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
    if ([first length] > 1 && [self isComment:first]) {
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

- (FNHostLine *) parseHostLine:(NSArray *)tokens {
    FNHostLine *hostline = [[FNHostLine alloc] init];

    int i = 0;
    NSString *token = [tokens objectAtIndex:i];
    
    // If the first token is a comment, disable the hostline
    // and fetch the next token
    if ([self isComment:token]) {
        [hostline setEnabled:NO];
        i++;
        token = [tokens objectAtIndex:i];
    } else {
        [hostline setEnabled:YES];
    }
    
    // Could be first token still or 2nd, doesn't matter
    // It needs to be an IP address
    // Afterwards, advance i to point at the next token
    if ([self isIPAddress:token]) {
        [hostline setIp:token];
        i++;
    } else {
        return nil;
    }
    
    NSRange range = NSMakeRange(i, [tokens count] - i);
    [hostline setHostnames:[tokens subarrayWithRange:range]];
    return hostline;
}

#pragma mark - Helper methods

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

- (BOOL) isComment:(NSString *)token {
    if ([token characterAtIndex:0] == '#') {
        return YES;
    }
    return NO;
}

// Helper to check the type of the line
- (LineType) getLineType:(NSArray *)tokens {
    if ([tokens count] == 0) {
        return BlankLine;
    }
    
    NSString *first = [tokens objectAtIndex:0];
    if ([self isIPAddress:first]) {
        return HostLine;
    }
    
    // The complicated one, either a comment or disabled hostline
    if ([self isComment:first]) {
        if ([tokens count] > 1) {
            NSString *second = [tokens objectAtIndex:1];
            if ([self isIPAddress:second]) {
                return HostLine;
            }
        }
        return CommentLine; 
    }
    
    // WTF is this?! Not a comment, not a host line
    // Lets ignore it as a blank line
    return BlankLine;
}

// Tries to set a name for a host based on either:
// 1) A comment
// 2) The first host name
- (NSString *) guessNameFromHost:(FNHost *)host {
    NSString *name;
    for (NSString * comment in [host comments]) {
        NSString *cleaned = [[comment stringByReplacingOccurrencesOfString:@"#" withString:@""]
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([cleaned length] > 0) {
            name = cleaned;
            break;
        }
    }
    
    if (name == nil) {
        FNHostLine *hostline = [[host hostlines] objectAtIndex:0];
        name = [[hostline hostnames] objectAtIndex:0];
    }
    
    return name;
}

// Helper to add the host to the list if not empty
// Returns a new (or current empty) host
- (FNHost *) saveHost:(FNHost *)host toArray:(NSMutableArray *)hosts {
    if (![host isEmpty]) {
        [host setName:[self guessNameFromHost:host]];
        [hosts addObject:host];
        host = [[FNHost alloc] init];
    }
    return host;
}

@end
