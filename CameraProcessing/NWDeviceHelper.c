//
//  NWDeviceHelper.c
//  CameraProcessing
//
//  Created by Nicholas Winters on 4/27/13.
//  Copyright (c) 2013 Nicholas Winters. All rights reserved.
//

#include <stdlib.h>
#include <string.h>
#include <sys/sysctl.h>

#include "NWDeviceHelper.h"

int NWIsDeviceIPadMini() {
    // Code originally from http://stackoverflow.com/a/13367455/2775
    int result = 0;
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size + 1);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    machine[size] = 0;

    // See device list on http://theiphonewiki.com/wiki/Models
    if (strcmp(machine, "iPad2,5") == 0 ||
        strcmp(machine, "iPad2,6") == 0 ||
        strcmp(machine, "iPad2,7") == 0) {
        /* iPad mini */
        result = 1;
    }

    free(machine);
    return result;
}