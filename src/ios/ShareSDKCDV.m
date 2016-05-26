//
//  ShareSDKCDV.m
//  imageshare
//
//  Created by Marlon Chan on 16/5/24.
//
//

#import "ShareSDKCDV.h"
#import <ShareSDK/ShareSDK.h>
#import <MOBFoundation/MOBFoundation.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <ShareSDKUI/ShareSDKUI.h>

#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDK/NSMutableDictionary+SSDKShare.h>
#import <ShareSDK/SSDKFriendsPaging.h>

#define IMPORT_SINA_WEIBO_LIB               //导入新浪微博库，如果不需要新浪微博客户端分享可以注释此行
#define IMPORT_QZONE_QQ_LIB                 //导入腾讯开发平台库，如果不需要QQ空间分享、SSO或者QQ好友分享可以注释此行
#define IMPORT_WECHAT_LIB                   //导入微信库，如果不需要微信分享可以注释此行

#ifdef IMPORT_SINA_WEIBO_LIB
#import "WeiboSDK.h"
#endif

#ifdef IMPORT_QZONE_QQ_LIB
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#endif


#ifdef IMPORT_WECHAT_LIB
#import "WXApi.h"
#endif


static NSString *const initSDKAndSetPlatfromConfig = @"initSDKAndSetPlatfromConfig";
static NSString *const authorize = @"authorize";
static NSString *const cancelAuthorize = @"cancelAuthorize";
static NSString *const isAuthorizedValid = @"isAuthorizedValid";
static NSString *const isClientValid = @"isClientValid";

static NSString *const getUserInfo = @"getUserInfo";
static NSString *const getAuthInfo = @"getAuthInfo";
static NSString *const shareContent = @"shareContent";
static NSString *const oneKeyShareContent = @"oneKeyShareContent";
static NSString *const showShareMenu = @"showShareMenu";

static NSString *const showShareView = @"showShareView";
static NSString *const getFriendList = @"getFriendList";
static NSString *const addFriend = @"addFriend";

static UIView *_refView = nil;



@implementation ShareSDKCDV

-(void) dispatcher:(CDVInvokedUrlCommand *)command {
    NSString* type = [command.arguments objectAtIndex:0];


    if([type isEqualToString:@"init"]) {

    }else if([type isEqualToString:@"call"]) {
        NSString *methodName = [command.arguments objectAtIndex:1];
        NSString *seqId = [command.arguments objectAtIndex:2];
        NSDictionary *paramsDict = nil;
        NSString *paramsStr = [command.arguments objectAtIndex:3];
        if (paramsStr)
        {
            paramsDict = [MOBFJson objectFromJSONString:paramsStr];
        }

        [self.commandDelegate runInBackground:^{
            if ([methodName isEqualToString:initSDKAndSetPlatfromConfig])
            {
                //初始化和设置平台信息
                [self openWithSeqId:seqId
                             params:paramsDict command:command];
            }
            else if ([methodName isEqualToString:authorize])
            {
                //授权
                [self authorizeWithSeqId:seqId
                                  params:paramsDict
                                 command:command];
            }
            else if ([methodName isEqualToString:cancelAuthorize])
            {
                //取消授权
                [self cancelAuthWithSeqId:seqId
                                   params:paramsDict
                                  command:command];
            }
            else if ([methodName isEqualToString:isAuthorizedValid])
            {
                //是否授权
                [self hasAuthWithSeqId:seqId
                                params:paramsDict
                               command:command];
            }
            else if([methodName isEqualToString:isClientValid])
            {
                //客户端是否安装
                [self isClientInstalledWithSeqId:seqId
                                          params:paramsDict
                                         command:command];
            }
            else if ([methodName isEqualToString:getUserInfo])
            {
                //获取用户信息
                [self getUserInfoWithSeqId:seqId
                                    params:paramsDict
                                   command:command];
            }
            else if ([methodName isEqualToString:getAuthInfo])
            {
                //获取授权信息
                [self getAuthInfoWithSeqId:seqId
                                    params:paramsDict
                                   command:command];
            }
            else if ([methodName isEqualToString:shareContent])
            {
                //分享内容
                [self shareContentWithSeqId:seqId
                                     params:paramsDict
                                    command:command];
            }
            else if ([methodName isEqualToString:oneKeyShareContent])
            {
                //一键分享
                [self oneKeyShareContentWithSeqId:seqId
                                           params:paramsDict
                                          command:command];
            }
            else if ([methodName isEqualToString:showShareMenu])
            {
                //显示分享菜单
                [self showShareMenuWithSeqId:seqId
                                      params:paramsDict
                                     command:command];
            }
            else if ([methodName isEqualToString:showShareView])
            {
                //显示分享视图
                [self showShareViewWithSeqId:seqId
                                      params:paramsDict
                                     command:command];
            }
            else if ([methodName isEqualToString:getFriendList])
            {
                //获取好友列表
                [self getFriendListWithSeqId:seqId
                                      params:paramsDict
                                     command:command];
            }
            else if ([methodName isEqualToString:addFriend])
            {
                //关注好友
                [self addFriendWithSeqId:seqId
                                  params:paramsDict
                                 command:command];
            }
        }];

    }

}


#pragma mark - Private

/**
 *	@brief	返回数据
 *
 *	@param 	data 	回复数据
 */
- (void)resultWithData:(NSDictionary *)data command:(CDVInvokedUrlCommand *)command
{
    NSString* responseJson = [MOBFJson jsonStringFromObject:data];
    CDVPluginResult* pluginResult = nil;
    if(data[@"error"] ) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:responseJson];

    }
       // The sendPluginResult method is thread-safe.
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


/**
 *	@brief	初始化SDK
 *
 *	@param 	seqId 	流水号
 *	@param 	params 	参数
 *  @param  webView Web视图
 */
- (void)openWithSeqId:(NSString *)seqId params:(NSDictionary *)params command:(CDVInvokedUrlCommand *)command {
    NSMutableDictionary *config = nil;

    NSString *appKey = nil;
    if ([[params objectForKey:@"appKey"] isKindOfClass:[NSString class]])
    {
        appKey = [params objectForKey:@"appKey"];
    }

    if ([[params objectForKey:@"platformConfig"] isKindOfClass:[NSDictionary class]])
    {
        config = [params objectForKey:@"platformConfig"];
    }

    NSArray *plat = [config allKeys];

    //保存成NSNumber类型
    NSMutableArray *activePlatforms = [NSMutableArray array];
    [plat enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSNumber class]])
        {
            NSNumber *platNum = @([[NSString stringWithFormat:@"%@",obj] integerValue]);
            [activePlatforms addObject:platNum];
        }
        else
        {
            [activePlatforms addObject:obj];
        }
    }];

    [ShareSDK registerApp:appKey
          activePlatforms:activePlatforms
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {

#ifdef IMPORT_SINA_WEIBO_LIB
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
#endif

#ifdef IMPORT_QZONE_QQ_LIB
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class]
                            tencentOAuthClass:[TencentOAuth class]];
                 break;
#endif



#ifdef IMPORT_WECHAT_LIB
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                 break;
#endif


             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {

              NSDictionary *dict = [config objectForKey:[NSString stringWithFormat:@"%zi",platformType]];
              [appInfo addEntriesFromDictionary:dict];
              [appInfo setObject:@"both" forKey:@"auth"];

          }];

    //返回
    NSDictionary *responseDict = @{@"seqId": [NSNumber numberWithInteger:[seqId integerValue]],
                                   @"method" : initSDKAndSetPlatfromConfig,
                                   @"state" : [NSNumber numberWithInteger:SSDKResponseStateSuccess]};
    [self resultWithData:responseDict command:command];
}



/**
 *	@brief	设置平台配置
 *
 *	@param 	seqId 	流水号
 *	@param 	params 	参数
 *  @param  webView Web视图
 */
- (void)setPlatformConfigWithSeqId:(NSString *)seqId params:(NSDictionary *)params command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    NSMutableDictionary *config = nil;

    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }
    if ([[params objectForKey:@"config"] isKindOfClass:[NSDictionary class]])
    {
        config = [NSMutableDictionary dictionaryWithDictionary:[params objectForKey:@"config"]];
    }

    switch (type)
    {
        case SSDKPlatformSubTypeWechatSession:
            [config setObject:[NSNumber numberWithInt:0] forKey:@"scene"];
            break;
        case SSDKPlatformSubTypeWechatTimeline:
            [config setObject:[NSNumber numberWithInt:1] forKey:@"scene"];
            break;
        case SSDKPlatformSubTypeWechatFav:
            [config setObject:[NSNumber numberWithInt:2] forKey:@"scene"];
            break;
        default:
            break;
    }

    //返回
    NSDictionary *responseDict = @{@"seqId": [NSNumber numberWithInteger:[seqId integerValue]],
                                   @"method" : initSDKAndSetPlatfromConfig,
                                   @"state" : [NSNumber numberWithInteger:SSDKResponseStateSuccess],
                                   @"platform" : [NSNumber numberWithInteger:type]};
    [self resultWithData:responseDict command:command];
}

/**
 *	@brief	用户授权
 *
 *	@param 	seqId 	流水号
 *	@param 	params 	参数
 *  @param  webView Web视图
 */
- (void)authorizeWithSeqId:(NSString *)seqId params:(NSDictionary *)params command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK authorize:type
               settings:nil
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
             //返回
             NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:[seqId integerValue]],
                                                  @"seqId",
                                                  authorize,
                                                  @"method",
                                                  [NSNumber numberWithInteger:state],
                                                  @"state",
                                                  [NSNumber numberWithInteger:type],
                                                  @"platform",
                                                  callback,
                                                  @"callback",
                                                  nil];
             if (error)
             {
                 [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:[error code]],
                                          @"error_code",
                                          [error userInfo],
                                          @"error_msg",
                                          nil]
                                  forKey:@"error"];
             }

             [self resultWithData:responseDict command:command];
         }];
}

- (void)cancelAuthWithSeqId:(NSString *)seqId params:(NSDictionary *)params command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    [ShareSDK cancelAuthorize:type];

    //返回
    NSDictionary *responseDict = @{@"seqId": [NSNumber numberWithInteger:[seqId integerValue]],
                                   @"method" : cancelAuthorize,
                                   @"state" : [NSNumber numberWithInteger:SSDKResponseStateSuccess],
                                   @"platform" : [NSNumber numberWithInteger:type]};
    [self resultWithData:responseDict command:command];
}

- (void)hasAuthWithSeqId:(NSString *)seqId params:(NSDictionary *)params command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;

    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    BOOL ret = [ShareSDK hasAuthorized:type];

    //返回
    NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:[seqId integerValue]],
                                  @"seqId",
                                  isAuthorizedValid,
                                  @"method",
                                  [NSNumber numberWithInteger:SSDKResponseStateSuccess],
                                  @"state",
                                  [NSNumber numberWithInteger:type],
                                  @"platform",
                                  [NSNumber numberWithBool:ret],
                                  @"data",
                                  callback,
                                  @"callback",
                                  nil];

    [self resultWithData:responseDict command:command];
}

- (void)isClientInstalledWithSeqId:(NSString *)seqId params:(NSDictionary *)params command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    BOOL ret = [ShareSDK isClientInstalled:SSDKPlatformSubTypeWechatTimeline];

    //返回
    NSDictionary *responseDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInteger:[seqId integerValue]],
                                  @"seqId",
                                  isClientValid,
                                  @"method",
                                  [NSNumber numberWithInteger:SSDKResponseStateSuccess],
                                  @"state",
                                  [NSNumber numberWithInteger:type],
                                  @"platform",
                                  [NSNumber numberWithBool:ret],
                                  @"data",
                                  callback,
                                  @"callback",
                                  nil];

    [self resultWithData:responseDict command:command];
}

- (void)getUserInfoWithSeqId:(NSString *)seqId params:(NSDictionary *)params command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK getUserInfo:type
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               //返回
               NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithInteger:[seqId integerValue]],
                                                    @"seqId",
                                                    getUserInfo,
                                                    @"method",
                                                    @(state),
                                                    @"state",
                                                    [NSNumber numberWithInteger:type],
                                                    @"platform",
                                                    callback,
                                                    @"callback",
                                                    nil];
               if (error)
               {
                   [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInteger:[error code]],
                                            @"error_code",
                                            [error userInfo],
                                            @"error_msg",
                                            nil]
                                    forKey:@"error"];
               }

               if ([user rawData])
               {
                   [responseDict setObject:[user rawData] forKey:@"data"];
               }

               [self resultWithData:responseDict command:command];
           }];
}

- (void)getAuthInfoWithSeqId:(NSString *)seqId params:(NSDictionary *)params command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK getUserInfo:type
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
               //返回
               NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithInteger:[seqId integerValue]],
                                                    @"seqId",
                                                    getAuthInfo,
                                                    @"method",
                                                    @(state),
                                                    @"state",
                                                    [NSNumber numberWithInteger:type],
                                                    @"platform",
                                                    callback,
                                                    @"callback",
                                                    nil];
               if (error)
               {
                   [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithInteger:[error code]],
                                            @"error_code",
                                            [error userInfo],
                                            @"error_msg",
                                            nil]
                                    forKey:@"error"];
               }

               NSMutableDictionary *authInfo = [NSMutableDictionary dictionary];

               if (user.credential)
               {
                   if (user.credential.uid)
                   {
                       [authInfo setObject:user.credential.uid forKey:@"uid"];
                   }

                   if (user.credential.token)
                   {
                       [authInfo setObject:user.credential.token forKey:@"access_token"];
                   }

                   if (user.credential.expired)
                   {
                       [authInfo setObject:user.credential.expired forKey:@"expires_in"];
                   }
               }

               if ([user rawData])
               {
                   [responseDict setObject:authInfo forKey:@"data"];
               }

               [self resultWithData:responseDict command:command];
           }];
}


-(NSUInteger)convertJSShareTypeToIOSShareType:(NSUInteger)JSShareType
{
    //    this.ContentType = {
    //        Auto : 0,
    //        Text : 1,
    //        Image : 2,
    //        WebPage : 4,
    //        Music : 5,
    //        Video : 6,
    //        App : 7,
    //        File : 8,
    //        Emoji : 9
    //    };
    switch (JSShareType)
    {
        case 1:
            return SSDKContentTypeText;
        case 2:
        case 9:
            return SSDKContentTypeImage;
        case 4:
            return SSDKContentTypeWebPage;
        case 5:
            return SSDKContentTypeAudio;
        case 6:
            return SSDKContentTypeVideo;
        case 7:
            return SSDKContentTypeApp;
        case 0:
        case 8:
            return SSDKContentTypeAuto;
        default:
            return SSDKContentTypeAuto;
            break;
    }
}

- (NSMutableDictionary *)contentWithDict:(NSDictionary *)dict
{
    NSString *message = nil;
    id image = nil;
    NSString *title = nil;
    NSString *url = nil;
    NSString *desc = nil;
    SSDKContentType type = SSDKContentTypeAuto;
    NSMutableDictionary *para = [NSMutableDictionary dictionary];

    if (dict)
    {
        if ([[dict objectForKey:@"text"] isKindOfClass:[NSString class]])
        {
            message = [dict objectForKey:@"text"];
        }

        if ([dict objectForKey:@"imageUrl"])
        {
            image = [dict objectForKey:@"imageUrl"];
        }

        if ([[dict objectForKey:@"title"] isKindOfClass:[NSString class]])
        {
            title = [dict objectForKey:@"title"];
        }

        if ([[dict objectForKey:@"titleUrl"] isKindOfClass:[NSString class]])
        {
            url = [dict objectForKey:@"titleUrl"];
        }

        if ([[dict objectForKey:@"description"] isKindOfClass:[NSString class]])
        {
            desc = [dict objectForKey:@"description"];
        }

        if ([[dict objectForKey:@"type"] isKindOfClass:[NSNumber class]])
        {
            type = [self convertJSShareTypeToIOSShareType:[[dict objectForKey:@"type"] unsignedIntegerValue]];
        }
    }

    [para SSDKSetupShareParamsByText:message
                              images:image
                                 url:[NSURL URLWithString:url]
                               title:title
                                type:type];

    if (dict)
    {
        NSString *siteUrlStr = nil;
        NSString *siteStr = nil;

        NSString *siteUrl = [dict objectForKey:@"siteUrl"];
        if ([siteUrl isKindOfClass:[NSString class]])
        {
            siteUrlStr = siteUrl;
        }

        NSString *site = [dict objectForKey:@"site"];
        if ([site isKindOfClass:[NSString class]])
        {
            siteStr = site;
        }

        //        if (siteUrlStr || siteStr)
        //        {
        //            [para SSDKSetupQQParamsByText:message
        //                                    title:title
        //                                      url:[NSURL URLWithString:url]
        //                               thumbImage:
        //                                    image:image
        //                                     type:type
        //                       forPlatformSubType:<#(SSDKPlatformType)#>];
        //        }
    }

    return para;
}

- (void)shareContentWithSeqId:(NSString *)seqId
                       params:(NSDictionary *)params
                      command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;

    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    NSMutableDictionary *content = nil;
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        content = [self contentWithDict:[params objectForKey:@"shareParams"]];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK share:type
         parameters:content
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {

         //返回
         NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInteger:[seqId integerValue]],
                                              @"seqId",
                                              shareContent,
                                              @"method",
                                              [NSNumber numberWithInteger:state],
                                              @"state",
                                              [NSNumber numberWithInteger:type],
                                              @"platform",
                                              callback,
                                              @"callback",
                                              nil];
         if (error)
         {
             [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:[error code]],
                                      @"error_code",
                                      [error userInfo],
                                      @"error_msg",
                                      nil]
                              forKey:@"error"];
         }

         if ([contentEntity rawData])
         {
             [responseDict setObject:[contentEntity rawData] forKey:@"data"];
         }

         [self resultWithData:responseDict command:command];
     }];
}

- (void)oneKeyShareContentWithSeqId:(NSString *)seqId
                             params:(NSDictionary *)params
                            command:(CDVInvokedUrlCommand *)command
{
    NSArray *types = nil;
    if ([[params objectForKey:@"platforms"] isKindOfClass:[NSArray class]])
    {
        types = [params objectForKey:@"platforms"];
    }

    NSMutableDictionary *content = nil;
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        content = [self contentWithDict:[params objectForKey:@"shareParams"]];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [SSEShareHelper oneKeyShare:types
                     parameters:content
                 onStateChanged:^(SSDKPlatformType platformType, SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                     //返回
                     NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                          [NSNumber numberWithInteger:[seqId integerValue]],
                                                          @"seqId",
                                                          oneKeyShareContent,
                                                          @"method",
                                                          [NSNumber numberWithInteger:state],
                                                          @"state",
                                                          [NSNumber numberWithInteger:platformType],
                                                          @"platform",
                                                          [NSNumber numberWithBool:end],
                                                          @"end",
                                                          callback,
                                                          @"callback",
                                                          nil];
                     if (error)
                     {
                         [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:[error code]],
                                                  @"error_code",
                                                  [error userInfo],
                                                  @"error_msg",
                                                  nil]
                                          forKey:@"error"];
                     }

                     if ([contentEntity rawData])
                     {
                         [responseDict setObject:[contentEntity rawData] forKey:@"data"];
                     }

                     [self resultWithData:responseDict command:command];
                 }];
}

- (void)showShareMenuWithSeqId:(NSString *)seqId
                        params:(NSDictionary *)params
                       command:(CDVInvokedUrlCommand *)command
{
    NSArray *types = nil;
    if ([[params objectForKey:@"platforms"] isKindOfClass:[NSArray class]])
    {
        types = [params objectForKey:@"platforms"];
    }

    NSMutableDictionary *content = nil;
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        content = [self contentWithDict:[params objectForKey:@"shareParams"]];
    }

    CGFloat x = 0;
    if ([[params objectForKey:@"x"] isKindOfClass:[NSNumber class]])
    {
        x = [[params objectForKey:@"x"] floatValue];
    }

    CGFloat y = 0;
    if ([[params objectForKey:@"y"] isKindOfClass:[NSNumber class]])
    {
        y = [[params objectForKey:@"y"] floatValue];
    }

    UIViewController *vc = [MOBFViewController currentViewController];
    if ([MOBFDevice isPad])
    {
        if (!_refView)
        {
            _refView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 1, 1)];
        }
        else
        {
            _refView.frame = CGRectMake(x, y, 1, 1);
        }

        [vc.view addSubview:_refView];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK showShareActionSheet:_refView
                             items:types
                       shareParams:content
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   //返回
                   NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                        [NSNumber numberWithInteger:[seqId integerValue]],
                                                        @"seqId",
                                                        showShareMenu,
                                                        @"method",
                                                        [NSNumber numberWithInteger:state],
                                                        @"state",
                                                        [NSNumber numberWithInteger:platformType],
                                                        @"platform",
                                                        [NSNumber numberWithBool:end],
                                                        @"end",
                                                        callback,
                                                        @"callback",
                                                        nil];
                   if (error)
                   {
                       [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [NSNumber numberWithInteger:[error code]],
                                                @"error_code",
                                                [error userInfo],
                                                @"error_msg",
                                                nil]
                                        forKey:@"error"];
                   }

                   if ([contentEntity rawData])
                   {
                       [responseDict setObject:[contentEntity rawData] forKey:@"data"];
                   }

                   [self resultWithData:responseDict command:command];

                   if (_refView)
                   {
                       [_refView removeFromSuperview];
                   }
               }];
}

- (void)showShareViewWithSeqId:(NSString *)seqId
                        params:(NSDictionary *)params
                       command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    NSMutableDictionary *content = nil;
    if ([[params objectForKey:@"shareParams"] isKindOfClass:[NSDictionary class]])
    {
        content = [self contentWithDict:[params objectForKey:@"shareParams"]];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK showShareEditor:type
           otherPlatformTypes:nil
                  shareParams:content
          onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {

              //返回
              NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithInteger:[seqId integerValue]],
                                                   @"seqId",
                                                   showShareView,
                                                   @"method",
                                                   [NSNumber numberWithInteger:state],
                                                   @"state",
                                                   @(platformType),
                                                   @"platform",
                                                   [NSNumber numberWithBool:end],
                                                   @"end",
                                                   callback,
                                                   @"callback",
                                                   nil];
              if (error)
              {
                  [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInteger:[error code]],
                                           @"error_code",
                                           [error userInfo],
                                           @"error_msg",
                                           nil]
                                   forKey:@"error"];
              }

              if ([contentEntity rawData])
              {
                  [responseDict setObject:[contentEntity rawData] forKey:@"data"];
              }

              [self resultWithData:responseDict command:command];
          }];
}

- (void)getFriendListWithSeqId:(NSString *)seqId
                        params:(NSDictionary *)params
                       command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    NSUInteger page = 1;
    if ([params objectForKey:@"page"])
    {
        page = [[params objectForKey:@"page"] unsignedIntegerValue];
    }

    NSUInteger count = 10;
    if ([params objectForKey:@"count"])
    {
        count = [[params objectForKey:@"count"] unsignedIntegerValue];
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK getFriends:type
                  cursor:page
                    size:count
          onStateChanged:^(SSDKResponseState state, SSDKFriendsPaging *paging, NSError *error) {

              //返回
              NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   [NSNumber numberWithInteger:[seqId integerValue]],
                                                   @"seqId",
                                                   getFriendList,
                                                   @"method",
                                                   [NSNumber numberWithInteger:state],
                                                   @"state",
                                                   [NSNumber numberWithInteger:type],
                                                   @"platform",
                                                   callback,
                                                   @"callback",
                                                   nil];
              if (error)
              {
                  [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithInteger:[error code]],
                                           @"error_code",
                                           [error userInfo],
                                           @"error_msg",
                                           nil]
                                   forKey:@"error"];
              }

              if (paging.users)
              {
                  [responseDict setObject:paging.users forKey:@"data"];
              }

              [self resultWithData:responseDict command:command];
          }];
}

- (void)addFriendWithSeqId:(NSString *)seqId
                    params:(NSDictionary *)params
                   command:(CDVInvokedUrlCommand *)command
{
    SSDKPlatformType type = SSDKPlatformTypeAny;
    if ([[params objectForKey:@"platform"] isKindOfClass:[NSNumber class]])
    {
        type = [[params objectForKey:@"platform"] unsignedIntegerValue];
    }

    SSDKUser *user = [[SSDKUser alloc] init];

    if ([[params objectForKey:@"friendName"] isKindOfClass:[NSString class]])
    {
        if (type == SSDKPlatformTypeTencentWeibo)
        {
            user.nickname = [params objectForKey:@"friendName"];
        }
        else
        {
            user.uid = [params objectForKey:@"friendName"];
        }
    }

    NSString *callback = nil;
    if ([[params objectForKey:@"callback"] isKindOfClass:[NSString class]])
    {
        callback = [params objectForKey:@"callback"];
    }

    [ShareSDK addFriend:type
                   user:user
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
             //返回
             NSMutableDictionary *responseDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:[seqId integerValue]],
                                                  @"seqId",
                                                  addFriend,
                                                  @"method",
                                                  [NSNumber numberWithInteger:state],
                                                  @"state",
                                                  [NSNumber numberWithInteger:type],
                                                  @"platform",
                                                  callback,
                                                  @"callback",
                                                  nil];
             if (error)
             {
                 [responseDict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:[error code]],
                                          @"error_code",
                                          [error userInfo],
                                          @"error_msg",
                                          nil]
                                  forKey:@"error"];
             }

             if (user.rawData)
             {
                 [responseDict setObject:user.rawData forKey:@"data"];
             }

             [self resultWithData:responseDict command:command];
         }];
}



@end
