//
//  VisualThemeManager.m
//  Curbside
//
//  Created by Greg Walker on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VisualThemeManager.h"
#import "Constants.h"


const int BackgroundViewTag = 99;


@interface VisualThemeManager ()
-(void) buildTheme;
@end

@implementation VisualThemeManager

@synthesize labelFontColor;
@synthesize labelFontBackgroundColor;
@synthesize labelFontShadowColor;
@synthesize labelShadowOffset;
@synthesize buttonFontColor;
@synthesize buttonBackground;
@synthesize buttonAlpha;
@synthesize viewBackgroundA;
@synthesize viewBackgroundB;
@synthesize viewBackgroundC;
@synthesize viewBackgroundD;
@synthesize logoImage;

@dynamic currentTheme;
-(VisualTheme) currentTheme {
    return currentTheme;
}
-(void) setCurrentTheme: (VisualTheme)value {
    if (currentTheme != value) {
        currentTheme = value;
        // Build the theme.
        [self buildTheme];
    }
}

-(id) init {
    self = [super init];
    if (self) {
        currentTheme = NULL_THEME;
        // Build the theme.
        [self buildTheme];
    }
    return self;
}

-(void) buildTheme {
    switch (currentTheme) {
        case SCRUBS_THEME:
            self.labelFontColor = [UIColor whiteColor];
            self.buttonFontColor = [UIColor colorWithRed:0.207843 green:0.301961 blue:0.388235 alpha:1.0]; // Navy Blue (0x354D63)
            self.labelFontBackgroundColor = [UIColor clearColor];
            self.labelFontShadowColor = labelFontBackgroundColor;
            self.labelShadowOffset = CGSizeMake(0.0, 0.0);
            self.buttonBackground = [UIImage imageNamed:imgWhiteButtonGradient];
            self.buttonAlpha = 1.0;
            self.viewBackgroundA = [UIImage imageNamed:imgScrubsBackground2];
            self.viewBackgroundB = [UIImage imageNamed:imgScrubsBackground1];
            self.viewBackgroundC = [UIImage imageNamed:imgScrubsBackground3];
            self.viewBackgroundD = [UIImage imageNamed:imgScrubsBackground4];
//            self.viewBackgroundA = [UIColor colorWithPatternImage:[UIImage imageNamed:imgScrubsBackground2]];
//            self.viewBackgroundB = [UIColor colorWithPatternImage:[UIImage imageNamed:imgScrubsBackground1]];
//            self.viewBackgroundC = [UIColor colorWithPatternImage:[UIImage imageNamed:imgScrubsBackground3]];
//            self.viewBackgroundD = [UIColor colorWithPatternImage:[UIImage imageNamed:imgScrubsBackground4]];
            self.logoImage = [UIImage imageNamed:imgLogoBag];
            break;
            
        case WOOD_THEME:
            self.labelFontColor = [UIColor colorWithRed:0.796875 green:0.59765625 blue:0.3984375 alpha:1.0]; // Tan (0xCC9966)
            self.labelFontBackgroundColor = [UIColor clearColor];
            self.labelFontShadowColor = labelFontBackgroundColor;
            self.labelShadowOffset = CGSizeMake(0.0, 0.0);
            self.buttonFontColor = [UIColor colorWithRed:0.415686 green:0.290196 blue:0.047059 alpha:1.0]; // Dark Brown (0x6A4A0C)
            self.buttonBackground = [UIImage imageNamed:imgTanButtonGradient];
            self.buttonAlpha = 1.0;
            self.viewBackgroundA = [UIImage imageNamed:imgWoodBackground2];
            self.viewBackgroundB = [UIImage imageNamed:imgWoodBackground1];
//                self.viewBackgroundA = [UIColor colorWithPatternImage:[UIImage imageNamed:imgWoodBackground2]];
//                self.viewBackgroundB = [UIColor colorWithPatternImage:[UIImage imageNamed:imgWoodBackground1]];
            self.viewBackgroundC = viewBackgroundA;
            self.viewBackgroundD = viewBackgroundB;
            self.logoImage = [UIImage imageNamed:imgLogoBag];
            break;
            
        case LEATHER_THEME:
            self.labelFontColor = [UIColor colorWithRed:1.0 green:0.796875 blue:0.59765625 alpha:1.0]; // Beige (0xFFCC99)
            self.labelFontBackgroundColor = [UIColor clearColor];
            self.labelFontShadowColor = labelFontBackgroundColor;
            self.labelShadowOffset = CGSizeMake(0.0, 0.0);
            self.buttonFontColor = [UIColor colorWithRed:0.376471 green:0.2 blue:0.054902 alpha:1.0]; // Dark Brown (0x60330E)
            self.buttonBackground = [UIImage imageNamed:imgBrownButtonGradient];
            self.buttonAlpha = 1.0;
            self.viewBackgroundA = [UIImage imageNamed:imgLeatherBackground1];
//                self.viewBackgroundA = [UIColor colorWithPatternImage:[UIImage imageNamed:imgLeatherBackground1]];
            self.viewBackgroundB = viewBackgroundA;
            self.viewBackgroundC = viewBackgroundA;
            self.viewBackgroundD = viewBackgroundA;
            self.logoImage = [UIImage imageNamed:imgLogoBag];
            break;
            
        case PILLS_THEME:
            self.labelFontColor = [UIColor whiteColor];
            self.labelFontBackgroundColor = [UIColor clearColor];
            self.labelFontShadowColor = [UIColor colorWithRed:0.172549 green:0.2156863 blue:0.3215686 alpha:1.0]; // Charcoal (0x2C3752)
            self.labelShadowOffset = CGSizeMake(0.8, 1.5);
            self.buttonFontColor = [UIColor whiteColor];
            self.buttonBackground = [UIImage imageNamed:imgBlackButtonGradient];
            self.buttonAlpha = 1.0;
            self.viewBackgroundA = [UIImage imageNamed:imgPillsBackground1];
            self.viewBackgroundB = [UIImage imageNamed:imgPillsBackground2];
            self.viewBackgroundC = [UIImage imageNamed:imgPillsBackground3];
            self.viewBackgroundD = [UIImage imageNamed:imgPillsBackground4];
//                self.viewBackgroundA = [UIColor colorWithPatternImage:[UIImage imageNamed:imgPillsBackground1]];
//                self.viewBackgroundB = [UIColor colorWithPatternImage:[UIImage imageNamed:imgPillsBackground2]];
//                self.viewBackgroundC = [UIColor colorWithPatternImage:[UIImage imageNamed:imgPillsBackground3]];
//                self.viewBackgroundD = [UIColor colorWithPatternImage:[UIImage imageNamed:imgPillsBackground4]];
            self.logoImage = [UIImage imageNamed:imgLogoBag];
            break;
            
        case XRAY_THEME:
            self.labelFontColor = [UIColor whiteColor];
            self.labelFontBackgroundColor = [UIColor clearColor];
            self.labelFontShadowColor = [UIColor colorWithRed:0.172549 green:0.2156863 blue:0.3215686 alpha:1.0]; // Charcoal (0x2C3752)
            self.labelShadowOffset = CGSizeMake(0.8, 1.5);
            self.buttonFontColor = [UIColor blackColor];
            self.buttonBackground = [UIImage imageNamed:imgWhiteButtonGradient];
            self.buttonAlpha = 0.65;
            self.viewBackgroundA = [UIImage imageNamed:imgXrayBackground1];
            self.viewBackgroundB = [UIImage imageNamed:imgXrayBackground2];
            self.viewBackgroundC = [UIImage imageNamed:imgXrayBackground3];
            self.viewBackgroundD = [UIImage imageNamed:imgXrayBackground4];
//                self.viewBackgroundA = [UIColor colorWithPatternImage:[UIImage imageNamed:imgXrayBackground1]];
//                self.viewBackgroundB = [UIColor colorWithPatternImage:[UIImage imageNamed:imgXrayBackground2]];
//                self.viewBackgroundC = [UIColor colorWithPatternImage:[UIImage imageNamed:imgXrayBackground3]];
//                self.viewBackgroundD = [UIColor colorWithPatternImage:[UIImage imageNamed:imgXrayBackground4]];
            self.logoImage = [UIImage imageNamed:imgBorderedLogoBag];
            break;
            
        default:
            self.labelFontColor = [UIColor blackColor];
            self.labelFontBackgroundColor = [UIColor clearColor];
            self.labelFontShadowColor = labelFontBackgroundColor;
            self.labelShadowOffset = CGSizeMake(0.0, 0.0);
            self.buttonFontColor = [UIColor blackColor];
            self.buttonAlpha = 1.0;
            self.buttonBackground = nil;
            self.viewBackgroundA = nil;
            self.viewBackgroundB = nil;
            self.viewBackgroundC = nil;
            self.viewBackgroundD = nil;
            self.logoImage = [UIImage imageNamed:imgLogoBag];
            break;
    }
}

-(void) dealloc {
    self.labelFontColor = nil;
    self.labelFontBackgroundColor = nil;
    self.labelFontShadowColor = nil;
    self.buttonFontColor = nil;
    self.buttonBackground = nil;
    self.viewBackgroundA = nil;
    self.viewBackgroundB = nil;
    self.viewBackgroundC = nil;
    self.viewBackgroundD = nil;
    self.logoImage = nil;
    
    [super dealloc];
}

-(void) applyThemeToLabel: (UILabel *)label {
    if (label) {
        label.textColor = self.labelFontColor;
        label.shadowColor = self.labelFontShadowColor;
        label.shadowOffset = self.labelShadowOffset;
        label.backgroundColor = self.labelFontBackgroundColor;
    }
}

-(void) applyThemeToLogoImage:(UIImageView *)logo {
    if (logo) {
        logo.image = self.logoImage;
    }
}

-(void) applyThemeToButton: (UIButton *)button {
    if (button) {
        [button setTitleColor: self.buttonFontColor forState:UIControlStateNormal];
        [button setBackgroundImage: self.buttonBackground forState:UIControlStateNormal];
        [button setAlpha: self.buttonAlpha];
    }
}

-(void) applyThemeToView: (UIView *)view withOption: (ThemeOption)option {
    if (view) {
        UIImage *image = nil;
        switch (option) {
            case THEME_OPTION_A:
                image = self.viewBackgroundA;
                // This doesn't work with Retina displays.
                //view.backgroundColor = self.viewBackgroundA;
                break;
                
            case THEME_OPTION_B:
                image = self.viewBackgroundB;
                // This doesn't work with Retina displays.
                //view.backgroundColor = self.viewBackgroundB;
                break;
                
            case THEME_OPTION_C:
                image = self.viewBackgroundC;
                // This doesn't work with Retina displays.
                //view.backgroundColor = self.viewBackgroundC;
                break;
                
            case THEME_OPTION_D:
                image = self.viewBackgroundD;
                // This doesn't work with Retina displays.
                //view.backgroundColor = self.viewBackgroundD;
                break;
                
            default:
                break;
        }
        
        if (image) {
            UIImageView *background = nil;
            for (UIView *v in view.subviews) {
                if ([v isKindOfClass:[UIImageView class]] && v.tag == BackgroundViewTag) {
                    background = (UIImageView *)v;
                    background.image = image;
                    break;
                }
            }
            if (!background) {
                // Now add a new UIImageView to hold the background and be sure to send to the back of the view.
                background = [[UIImageView alloc] initWithImage:image];
                [background setFrame: CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height)];
                background.tag = BackgroundViewTag;
                [view addSubview:background];
                [view sendSubviewToBack:background];
            }
        }
    }
}

@end
