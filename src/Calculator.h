#import <Foundation/Foundation.h>
#import <SDL2/SDL.h>
#import <SDL2/SDL_ttf.h>
#import "CalcButton.h"

#define WIN_W 320
#define WIN_H 480
#define BUTTON_RADIUS 20

@interface Calculator : NSObject {
    SDL_Window *window;
    SDL_Renderer *renderer;
    TTF_Font *font;
    NSMutableArray *buttons;
    NSMutableString *input;
    NSMutableString *output;
}

- (BOOL)setup;
- (void)run;
- (void)cleanup;
- (double)eval:(NSString *)expr;
@end

