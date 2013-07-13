//
//  VisualThemeManager.h
//  Curbside
//
//  Created by Greg Walker on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/// The order of values here must match those in Root.plist
typedef enum {
    NULL_THEME,
    LEATHER_THEME,
    PILLS_THEME,
    SCRUBS_THEME,
    WOOD_THEME,
    XRAY_THEME
} VisualTheme;

typedef enum {
    THEME_OPTION_A,
    THEME_OPTION_B,
    THEME_OPTION_C,
    THEME_OPTION_D
} ThemeOption;


@interface VisualThemeManager : NSObject {
    @private
    VisualTheme currentTheme;
    UIImage *buttonBackground;
    CGFloat buttonAlpha;
    UIColor *labelFontColor;
    UIColor *labelFontBackgroundColor;
    UIColor *labelFontShadowColor;
    UIColor *buttonFontColor;
    UIImage *viewBackgroundA;
    UIImage *viewBackgroundB;
    UIImage *viewBackgroundC;
    UIImage *viewBackgroundD;
    UIImage *logoImage;
    CGSize labelShadowOffset;
}

/// The current visual theme.
@property (nonatomic, assign) VisualTheme currentTheme;
@property (nonatomic, retain) UIColor *labelFontColor;
@property (nonatomic, assign) CGFloat buttonAlpha;
@property (nonatomic, retain) UIColor *labelFontBackgroundColor;
@property (nonatomic, retain) UIColor *labelFontShadowColor;
@property (nonatomic, assign) CGSize labelShadowOffset;
@property (nonatomic, retain) UIImage *buttonBackground;
@property (nonatomic, retain) UIColor *buttonFontColor;
@property (nonatomic, retain) UIImage *viewBackgroundA;
@property (nonatomic, retain) UIImage *viewBackgroundB;
@property (nonatomic, retain) UIImage *viewBackgroundC;
@property (nonatomic, retain) UIImage *viewBackgroundD;
@property (nonatomic, retain) UIImage *logoImage;

-(void) applyThemeToLabel: (UILabel *)label;
-(void) applyThemeToButton: (UIButton *)button;
-(void) applyThemeToView: (UIView *)view withOption: (ThemeOption)option;
-(void) applyThemeToLogoImage: (UIImageView *)logo;

@end
