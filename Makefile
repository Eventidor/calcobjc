# Makefile for GNUstep + SDL2 Objective-C project

APP_NAME = calc
OBJC_FILES = main.m Calculator.m CalcButton.m

# Get the necessary GNUstep flags
GNU_OBJC_CFLAGS = `gnustep-config --objc-flags`
GNU_LDFLAGS = `gnustep-config --gui-libs`

SDL_CFLAGS = `sdl2-config --cflags`
SDL_LDFLAGS = `sdl2-config --libs` -lSDL2_ttf -lSDL2_gfx

CFLAGS = -Wall -g -std=c11
OBJCFLAGS = -fobjc-exceptions -Wall -g

all: $(APP_NAME)

$(APP_NAME): $(OBJC_FILES)
	clang $(OBJC_FILES) $(CFLAGS) $(OBJCFLAGS) $(GNU_OBJC_CFLAGS) $(SDL_CFLAGS) -o $(APP_NAME) $(SDL_LDFLAGS) $(GNU_LDFLAGS) -lobjc

clean:
	rm -f $(APP_NAME)

