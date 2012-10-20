//
//  FNMessageService.m
//  Meddo
//
//  Created by John Shimek on 10/18/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNMessageService.h"
#import "FNSecurityService.h"
#import "Constants.h"

@implementation FNMessageService

+ (FNMessageService *)sharedInstance {
    static FNMessageService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FNMessageService alloc] init];
    });
    return sharedInstance;
}

- (void) sendMessage:(NSString *)message {
    [[FNSecurityService sharedInstance] ensureHelperInstalled];
    
    xpc_connection_t connection = xpc_connection_create_mach_service([kHelper UTF8String], NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    
    if (!connection) {
        NSLog(@"Failed to create XPC connection.");
        return;
    }
    
    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        xpc_type_t type = xpc_get_type(event);
        if (type == XPC_TYPE_ERROR) {
            if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
                NSLog(@"XPC connection interupted.");
                
            } else if (event == XPC_ERROR_CONNECTION_INVALID) {
                NSLog(@"XPC connection invalid, releasing.");
                xpc_release(connection);
            } else {
                NSLog(@"Unexpected XPC connection error.");
            }
            
        } else {
            NSLog(@"Unexpected XPC connection event.");
        }
    });
    
    xpc_object_t xpc_message = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(xpc_message, "hosts", [message UTF8String]);
    NSLog(@"Sending request: %@", message);
    xpc_connection_resume(connection);
    xpc_connection_send_message_with_reply(connection, xpc_message, dispatch_get_main_queue(), ^(xpc_object_t event) {
        const char* response = xpc_dictionary_get_string(event, "status");
        NSLog(@"Received response: %s.", response);
    });
}


@end
