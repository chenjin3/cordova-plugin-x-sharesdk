
Cordova ShareSDK Plugin
=================================

[ShareSDK](http://sharesdk.mob.com/#/sharesdk) 是为iOS和Android的App提供社会化功能的一个组件，帮助开发者轻松实现社会化分享、登录、关注、获得用户资料、获取好友列表等主流的社会化功能。本插件弥补了ShareSDK不支持Cordova平台的问题，为iOS Hybird应用提供主流社交平台登录和分享功能。


### 功能
- 微信，新浪微博，QQ等社交平台授权登录
- 社交平台分享

### 支持平台
- iOS

### 安装
#### 1. 下载ShareSDK
Cordova ShareSDK插件依赖ShareSDK for iOS。集成ShareSDK for iOS,可参考[官方文档](https://github.com/MobClub/ShareSDK-JavaScript-Wiki-for-iOS-CN)。

#### 2. 安装ShareSDK Cordova插件

```
cordova plugin add https://github.com/chenjin3/cordova-plugin-x-sharesdk.git
```

### 应用示例

#### 1、 添加初始化代码
```
  function init()
  {
        //1、配置平台信息，有开放平台账号系统的平台需要自行去申请账号
        var platformConfig = {};
        
        //以下是示例
        //新浪微博
        var sinaConf = {};
        sinaConf["app_key"] = "568898243";
        sinaConf["app_secret"] = "38a4f8204cc784f81f9f0daaf31e02e3";
        sinaConf["redirect_uri"] = "http://www.sharesdk.cn";
        platformConfig[$sharesdk.PlatformID.SinaWeibo] = sinaConf;
        
        //微信
        var weixinConf = {};
        weixinConf["app_id"] = "wx4868b35061f87885";
        weixinConf["app_secret"] = "64020361b8ec4c99936c0e3999a9f249";
        platformConfig[$sharesdk.PlatformID.WechatPlatform] = weixinConf;

        //QQ
        var qqConf = {};
        qqConf["app_id"] = "100371282";
        qqConf["app_key"] = "aed9b0303e3ed1e27bae87c33761161d";
        platformConfig[$sharesdk.PlatformID.QQPlatform] = qqConf;

        //腾讯微博
        var tencentWeiboConf = {};
        tencentWeiboConf["app_key"] = "801307650";
        tencentWeiboConf["app_secret"] = "ae36f4ee3946e1cbb98d6965b0b2ff5c";
        tencentWeiboConf["redirect_uri"] = "http://www.sharesdk.cn";
        platformConfig[$sharesdk.PlatformID.TencentWeibo] = tencentWeiboConf;
               
        //Mail
        var mailConf = {};
        platformConfig[$sharesdk.PlatformID.Mail] = mailConf;

        //2、初始化ShareSDK
        $sharesdk.initSDKAndSetPlatfromConfig("iosv1101", platformConfig);
        
        //设置平台为iOS
        $sharesdk.PLATFORM_SHARE = 2;
}
```

#### 2、 授权登录接口调用
```
	$sharesdk.authorize($sharesdk.PlatformID.SinaWeibo, function (response) {
	    alert("state = " + response.state + "\n user = " + JSON.stringify(response.data));
	      if (response.state == $sharesdk.ResponseState.Success) {
	        sessionStorage.setItem('user', JSON.stringify(response.data));
	      } else if (response.state == $sharesdk.ResponseState.Cancel) {
	        alert('取消登录');
	      } else if (response.state == $sharesdk.ResponseState.Fail) {
	        alert('登录失败');
	      }
	 }); 
```

#### 3、 获取原生代码缓存的用户信息

```
  cordova.exec(function (data) {
        alert("user:" + JSON.stringify(data));
  }, function (err) {
        alert('您尚未登录，请使用社交账号登录');
  }, "ShareSDK", "getLocalUserInfo", []);
```

#### 4、 弹出分享菜单
```
	var params = {
	   "text" : "",
	   "imageUrl" :"",
	   "title" : "分享标题",
	   "titleUrl" : "",
	   "description" : "测试的描述",
	   "site" : "GitHub",
	   "siteUrl" : "https://github.com/",
	   "type" : $sharesdk.ContentType.Auto
	 };
	
	$sharesdk.showShareMenu(null, params, 100, 100, function (res) {
	   console.log(JSON.stringify(res));
	});
```



 

