#import <Foundation/Foundation.h>
#import "Calculator.h"
#import <GNUstepBase/GNUstep.h>
int main(int argc, char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    Calculator *calc = [[Calculator alloc] init];
    if (![calc setup]) {
        NSLog(@"Setup failed");
        [pool release];
        return 1;
    }

    [calc run];
    [calc cleanup];

    [pool release];
    return 0;
}

