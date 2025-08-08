#import "Calculator.h"
#import <SDL2/SDL2_gfxPrimitives.h>

@implementation Calculator

- (BOOL)setup {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        fprintf(stderr, "SDL_Init error: %s\n", SDL_GetError());
        return NO;
    }
    if (TTF_Init() != 0) {
        fprintf(stderr, "TTF_Init error: %s\n", TTF_GetError());
        return NO;
    }

    window = SDL_CreateWindow("Calculator", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIN_W, WIN_H, SDL_WINDOW_SHOWN);
    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    char *base_path = SDL_GetBasePath();
    if (!base_path) {
        fprintf(stderr, "SDL_GetBasePath failed: %s\n", SDL_GetError());
        return NO;
    }

    char font_path[512];
    snprintf(font_path, sizeof(font_path), "%s/src/font/IosevkaNerdFontMono-Thin.ttf", base_path);
    SDL_free(base_path);

    font = TTF_OpenFont(font_path, 24);
    if (!font) {
        fprintf(stderr, "TTF_OpenFont error: %s\n", TTF_GetError());
        return NO;
    }

    input = [[NSMutableString alloc] init];
    output = [[NSMutableString alloc] init];
    buttons = [[NSMutableArray alloc] init];

    int paddingX = 10;
    int paddingY = 100;
    int buttonW = 70;
    int buttonH = 50;

    const char *labels[] = {
        "AC", "+/-", "%", "/",
        "7", "8", "9", "*",
        "4", "5", "6", "-",
        "1", "2", "3", "+",
        "0", ".", "="
    };

    int labelCount = sizeof(labels)/sizeof(labels[0]);
    for (int i = 0; i < labelCount; i++) {
        CalcButton *btn = [[CalcButton alloc] init];
        NSString *labelStr = [NSString stringWithUTF8String:labels[i]];

        if ([labelStr isEqualToString:@"0"]) {
            btn.rect = (SDL_Rect){paddingX, paddingY + 4 * 60, buttonW * 2 + 10, buttonH};
        } else if ([labelStr isEqualToString:@"."]) {
            btn.rect = (SDL_Rect){paddingX + (2 * (buttonW + 10)), paddingY + 4 * 60, buttonW, buttonH};
        } else if ([labelStr isEqualToString:@"="]) {
            btn.rect = (SDL_Rect){paddingX + (3 * (buttonW + 10)), paddingY + 4 * 60, buttonW, buttonH};
        } else {
            int row = i / 4;
            int col = i % 4;
            btn.rect = (SDL_Rect){paddingX + col * (buttonW + 10), paddingY + row * 60, buttonW, buttonH};
        }

        btn.label = labelStr;
        btn.isOperator = [[NSArray arrayWithObjects:@"/", @"*", @"-", @"+", @"=", nil] containsObject:labelStr];
        [buttons addObject:btn];
    }

    return YES;
}

- (void)handleInput:(NSString *)label {
    if ([label isEqualToString:@"AC"]) {
        [input setString:@""];
        [output setString:@""];
    } else if ([label isEqualToString:@"="]) {
        double r = [self eval:input];
        [output setString:[NSString stringWithFormat:@"%.6g", r]];
    } else {
        if ([[NSArray arrayWithObjects:@"+", @"-", @"*", @"/", nil] containsObject:label]) {
            [input appendFormat:@" %@ ", label];
        } else {
            [input appendString:label];
        }
    }
}

/* - (double)eval:(NSString *)expr {
    double a, b; char op;
    if (sscanf([expr UTF8String], "%lf %c %lf", &a, &op, &b) == 3) {
        switch(op) {
            case '+': return a + b;
            case '-': return a - b;
            case '*': return a * b;
            case '/': return b != 0 ? a / b : 0;
        }
    }
    return 0;
}*/
- (double)eval:(NSString *)expr {
    double a, b;
    char op;
    if (sscanf([expr UTF8String], "%lf %c %lf", &a, &op, &b) == 3) {
        switch(op) {
            case '+': return a + b;
            case '-': return a - b;
            case '*': return a * b;
            case '/': return b != 0 ? a / b : 0;
        }
    }
    return 0;
}
- (void)drawRoundedButton:(CalcButton *)btn {
    SDL_Color color = btn.isOperator ? (SDL_Color){255, 149, 0, 255} :
                      [btn.label isEqualToString:@"AC"] ? (SDL_Color){192, 192, 192, 255} :
                                                          (SDL_Color){80, 80, 80, 255};

    roundedBoxRGBA(renderer,
                   btn.rect.x, btn.rect.y,
                   btn.rect.x + btn.rect.w, btn.rect.y + btn.rect.h,
                   BUTTON_RADIUS, color.r, color.g, color.b, color.a);

    SDL_Color white = {255, 255, 255, 255};
    int tw, th;
    TTF_SizeUTF8(font, btn.label.UTF8String, &tw, &th);
    int tx = btn.rect.x + (btn.rect.w - tw) / 2;
    int ty = btn.rect.y + (btn.rect.h - th) / 2;

    SDL_Surface *surf = TTF_RenderUTF8_Blended(font, btn.label.UTF8String, white);
    SDL_Texture *tex = SDL_CreateTextureFromSurface(renderer, surf);
    SDL_Rect dst = {tx, ty, surf->w, surf->h};
    SDL_RenderCopy(renderer, tex, NULL, &dst);
    SDL_FreeSurface(surf);
    SDL_DestroyTexture(tex);
}

- (void)drawTextWithFont:(TTF_Font *)f text:(NSString *)text atX:(int)x y:(int)y {
    if (!f || text.length == 0) return;
    SDL_Color white = {255, 255, 255, 255};
    SDL_Surface *surf = TTF_RenderUTF8_Blended(f, text.UTF8String, white);
    SDL_Texture *tex = SDL_CreateTextureFromSurface(renderer, surf);
    SDL_Rect dst = {x, y, surf->w, surf->h};
    SDL_RenderCopy(renderer, tex, NULL, &dst);
    SDL_FreeSurface(surf);
    SDL_DestroyTexture(tex);
}

- (void)handleKeyboardEvent:(SDL_KeyboardEvent)keyEvent {
    SDL_Keycode key = keyEvent.keysym.sym;
    NSString *keyStr = nil;

    if (key >= SDLK_0 && key <= SDLK_9) {
        unichar c = key - SDLK_0 + '0';
        keyStr = [NSString stringWithFormat:@"%c", c];
    } else {
        switch (key) {
            case SDLK_KP_0: keyStr = @"0"; break;
            case SDLK_KP_1: keyStr = @"1"; break;
            case SDLK_KP_2: keyStr = @"2"; break;
            case SDLK_KP_3: keyStr = @"3"; break;
            case SDLK_KP_4: keyStr = @"4"; break;
            case SDLK_KP_5: keyStr = @"5"; break;
            case SDLK_KP_6: keyStr = @"6"; break;
            case SDLK_KP_7: keyStr = @"7"; break;
            case SDLK_KP_8: keyStr = @"8"; break;
            case SDLK_KP_9: keyStr = @"9"; break;
            case SDLK_PLUS:
            case SDLK_KP_PLUS: keyStr = @"+"; break;
            case SDLK_MINUS:
            case SDLK_KP_MINUS: keyStr = @"-"; break;
            case SDLK_ASTERISK:
            case SDLK_KP_MULTIPLY: keyStr = @"*"; break;
            case SDLK_SLASH:
            case SDLK_KP_DIVIDE: keyStr = @"/"; break;
            case SDLK_RETURN:
            case SDLK_KP_ENTER: keyStr = @"="; break;
            case SDLK_PERIOD:
            case SDLK_KP_DECIMAL: keyStr = @"."; break;
            case SDLK_ESCAPE: keyStr = @"AC"; break;
            case SDLK_BACKSPACE:
                if (input.length > 0) {
                    [input deleteCharactersInRange:NSMakeRange(input.length - 1, 1)];
                }
                return;
            default:
                return;
        }
    }

    if (keyStr) {
        [self handleInput:keyStr];
    }
}

- (void)run {
    BOOL quit = NO;
    SDL_Event e;

    while (!quit) {
        while (SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) quit = YES;
            if (e.type == SDL_MOUSEBUTTONDOWN) {
                int mx = e.button.x, my = e.button.y;
                for (CalcButton *btn in buttons) {
                    if (mx >= btn.rect.x && mx <= btn.rect.x + btn.rect.w &&
                        my >= btn.rect.y && my <= btn.rect.y + btn.rect.h) {
                        [self handleInput:btn.label];
                    }
                }
            } else if (e.type == SDL_KEYDOWN) {
                [self handleKeyboardEvent:e.key];
            }
        }

        SDL_SetRenderDrawColor(renderer, 20, 20, 20, 255);
        SDL_RenderClear(renderer);
        [self drawTextWithFont:font text:input atX:20 y:20];
        if (output.length > 0) {
            [self drawTextWithFont:font text:output atX:WIN_W - 120 y:60];
        }

        for (CalcButton *btn in buttons) {
            [self drawRoundedButton:btn];
        }

        SDL_RenderPresent(renderer);
        SDL_Delay(16);
    }
}

- (void)cleanup {
    if (font) TTF_CloseFont(font);
    if (renderer) SDL_DestroyRenderer(renderer);
    if (window) SDL_DestroyWindow(window);
    TTF_Quit();
    SDL_Quit();
}

@end

