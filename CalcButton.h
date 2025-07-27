#import <Foundation/Foundation.h>
#import <SDL2/SDL.h>

@interface CalcButton : NSObject {
    SDL_Rect _rect;
    NSString *_label;
    BOOL _isOperator;
}
@property SDL_Rect rect;
@property (retain) NSString *label;
@property BOOL isOperator;
@end

