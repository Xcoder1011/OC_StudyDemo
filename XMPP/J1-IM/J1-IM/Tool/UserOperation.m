//
//  UserOperation.m
//  J1-IM
//
//  Created by liang on 16/1/23.
//  Copyright © 2016年 J1. All rights reserved.
//

#import "UserOperation.h"

@implementation UserOperation

SingletonM(user);

- (void)setUsername:(NSString *)username{
    [MyDefaults setObject:username forKey:LoginUserNameKey];
    [MyDefaults synchronize];
}

- (void)setPassword:(NSString *)password{
    [MyDefaults setObject:password forKey:LoginPasswordKey];
    [MyDefaults synchronize];
}

- (void)setHostUrl:(NSString *)hostUrl{
    [MyDefaults setObject:hostUrl forKey:LoginHostnameKey];
    [MyDefaults synchronize];
}

- (void)setLoginStatus:(BOOL)loginStatus{
    [MyDefaults setBool:loginStatus forKey:LoginloginStatus];
    [MyDefaults synchronize];
}

- (NSString *)username{
    return [MyDefaults objectForKey:LoginUserNameKey];
}

- (NSString *)password{
    return [MyDefaults objectForKey:LoginPasswordKey];
}

- (NSString *)hostUrl{
    return [MyDefaults objectForKey:LoginHostnameKey];
}

- (BOOL)loginStatus{
    return [MyDefaults boolForKey:LoginloginStatus];
}


-(NSString *)jid {

    return [NSString stringWithFormat:@"%@@%@",self.username,[UserOperation shareduser].hostUrl];
}


@end
