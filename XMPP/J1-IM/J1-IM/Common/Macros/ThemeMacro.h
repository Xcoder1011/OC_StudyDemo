//
//  ThemeMacro.h
//  J1-IM
//
//  Created by wushangkun on 16/1/22.
//  Copyright © 2016年 J1. All rights reserved.
//

#ifndef ThemeMacro_h
#define ThemeMacro_h

#define colorTheme    [UIColor orangeColor]
#define colorThemelightGrayColor [UIColor lightGrayColor]
#define colorThemegrayColor  [UIColor grayColor]

#define knavBJColor  @"#1cc4ad"
#define kviewBJColor @"#f0eff4"
#define KcolorWhite  @"#ffffff"
#define kcolorTheme  @"#4fc9a2"
#define kcolorBJTheme    @"#fdfdfd"
#define kcolorBJ_f0eff4  @"#f0eff4"
#define kcolorViewBJ_f8f8f8 @"#f8f8f8"
#define kcolorViewBJ_f0eff4 @"#f0eff4"
#define kcolorLine     [UIColor colorWithHexString:@"#dddddd"]


#define kbtnColorBJNormalState        @"#1cc4ad"
#define kbtnColorBJHighlightedState   @"#18b09c"
#define kbtnWhiteColorBJHighlightedState   @"#f3f3f3"
#define kc00_1bc4ac      @"#1bc4ac"
#define kc00_b89d83      @"#b89d83"
#define kc00_ff7e00      @"#ff7e00"
#define kc00_2c2c2c      @"#2c2c2c"
#define kc00_999999      @"#999999"
#define kc00_666666      @"#666666"
#define kc00_f5f5f5      @"#f5f5f5"
#define kc00_1cc4ad      @"#1cc4ad"
#define kc00_da9317      @"#da9317"
#define kc00_35a6f2      @"#35a6f2"
#define kc00_007aff      @"#007aff"
#define kc00_256ad0      @"#256ad0"
#define kc00_df1a1a      @"#df1a1a"


#define UIColorFromRGB(r,g,b) [UIColor \
colorWithRed:r/255.0 \
green:g/255.0 \
blue:b/255.0 alpha:1]

#define UIColorFromAlphaRGB(r,g,b,alp) [UIColor \
colorWithRed:r/255.0 \
green:g/255.0 \
blue:b/255.0 alpha:alp]

#define IOS8  [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0
#define IOS7  [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define NSStringFromInt(intValue) [NSString stringWithFormat:@"%d",intValue]
#define DeviceRect   [UIScreen mainScreen].bounds
#define DeviceHeight [UIScreen mainScreen].bounds.size.height
#define DeviceWidth  [UIScreen mainScreen].bounds.size.width
#define kBuild       [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define kVersion     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define kAPPDisplayName     [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define kBundleIdentifier   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]


#define themeFont(x) [UIFont systemFontOfSize:x]
#define themeFont20  [UIFont systemFontOfSize:20.0f]
#define themeFont19  [UIFont systemFontOfSize:19.0f]
#define themeFont18  [UIFont systemFontOfSize:18.0f]
#define themeFont17  [UIFont systemFontOfSize:17.0f]
#define themeFont16  [UIFont systemFontOfSize:16.0f]
#define themeFont15  [UIFont systemFontOfSize:15.0f]
#define themeFont14  [UIFont systemFontOfSize:14.0f]
#define themeFont13  [UIFont systemFontOfSize:13.0f]
#define themeFont12  [UIFont systemFontOfSize:12.0f]
#define themeFont11  [UIFont systemFontOfSize:11.0f]
#define themeFont10  [UIFont systemFontOfSize:10.0f]
#define themeFont9   [UIFont systemFontOfSize:9.0f]

#define themescaleFont(size) [UIFont systemFontOfSize:size*DeviceWidth/320.0]

#define themeBoldFont(x)  [UIFont boldSystemFontOfSize:x]
#define themeBoldFont17   [UIFont boldSystemFontOfSize:17.0f]
#define themeBoldFont16   [UIFont boldSystemFontOfSize:16.0f]
#define themeBoldFont15   [UIFont boldSystemFontOfSize:15.0f]
#define themeBoldFont14   [UIFont boldSystemFontOfSize:14.0f]
#define themeBoldFont13   [UIFont boldSystemFontOfSize:13.0f]
#define themeFontSize(size) [UIFont systemFontOfSize:size]
#define kscaleDeviceWidth(width)  (width*DeviceWidth)/320.0
#define kscaleDeviceHeight(height)  (height*DeviceWidth)/320.0
#define kscaleDeviceLength(length)  ((length)*DeviceWidth)/320.0

#endif /* ThemeMacro_h */
