//
//  main.c
//  MeddoHelper
//
//  Created by John Shimek on 9/16/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#include "MeddoHelper.h"
#include <syslog.h>
#include <xpc/xpc.h>
#include <errno.h>


static void __XPC_Peer_Event_Handler(xpc_connection_t connection, xpc_object_t event) {
    syslog(LOG_NOTICE, "Received event in helper.");
    
    xpc_type_t type = xpc_get_type(event);
    
    if (type == XPC_TYPE_ERROR) {
        if (event == XPC_ERROR_CONNECTION_INVALID) {
            // The client process on the other end of the connection has either
            // crashed or cancelled the connection. After receiving this error,
            // the connection is in an invalid state, and you do not need to
            // call xpc_connection_cancel(). Just tear down any associated state
            // here.
            
        } else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
            // Handle per-connection termination cleanup.
        }
        
    } else {
        xpc_connection_t remote = xpc_dictionary_get_remote_connection(event);
        xpc_object_t reply = xpc_dictionary_create_reply(event);

        const char *hosts = xpc_dictionary_get_string(event, "hosts");
        int result = writeHosts(hosts);
        if (result == 0) {
            xpc_dictionary_set_string(reply, "status", "success");
        } else {
            xpc_dictionary_set_string(reply, "status", "failure");
        }

        xpc_connection_send_message(remote, reply);
        xpc_release(reply);
    }
}

static void __XPC_Connection_Handler(xpc_connection_t connection) {
    syslog(LOG_NOTICE, "Configuring message event handler for helper.");
    
    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        __XPC_Peer_Event_Handler(connection, event);
    });
    
    xpc_connection_resume(connection);
}

int main(int argc, const char *argv[]) {
    xpc_connection_t service = xpc_connection_create_mach_service(kHelper,
                                                                  dispatch_get_main_queue(),
                                                                  XPC_CONNECTION_MACH_SERVICE_LISTENER);
    
    if (!service) {
        syslog(LOG_NOTICE, "Failed to create service.");
        exit(EXIT_FAILURE);
    }
    
    syslog(LOG_NOTICE, "Configuring connection event handler for helper");
    xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {
        __XPC_Connection_Handler(connection);
    });
    
    xpc_connection_resume(service);
    dispatch_main();
    xpc_release(service);
    
    return EXIT_SUCCESS;
}

int writeHosts(const char *hosts) {
    unsigned long length = strlen(hosts);
    unsigned long size = length * sizeof(hosts);
    syslog(LOG_NOTICE, "Writing hosts file; %zd chars total, %zd bytes", length, size);
    
    FILE *fp = fopen(kHostFile, "w");
    if (fp == NULL) {
        syslog(LOG_ERR, "Error opening host file: %s",strerror(errno));
        return 1;
    }
    fprintf(fp, "%s", hosts);
    
    fclose(fp);
    
    return 0;
}



