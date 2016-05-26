/**
 * Created by Marlon on 16/5/24.
 */
var cordova = require('cordova');


function ShareSDK() {
  this.isRunning = false;         //是否正在与本地进行交互
  this.isDebug = true;            //是否打开调试
  this.isSendInitRequest = false; //是否已经发送初始化请求
  this.initCallbackFuncs = [];    //初始化回调方法
  this.apiCaller = null;          //API调用器

  this.seqId = 0;
  this.firstRequest = null;
  this.lastRequest = null;
  this.jsLog = null;
  this.PLATFORM_SHARE = null;


  /**
   * SDK方法名称
   * @type {object}
   */
  this.ShareSDKMethodName =
  {
    "InitSDKAndSetPlatfromConfig": "initSDKAndSetPlatfromConfig",
    "Authorize": "authorize",
    "CancelAuthorize": "cancelAuthorize",
    "IsAuthorizedValid": "isAuthorizedValid",
    "IsClientValid": "isClientValid",

    "GetUserInfo": "getUserInfo",
    "GetAuthInfo": "getAuthInfo",
    "ShareContent": "shareContent",
    "OneKeyShareContent": "oneKeyShareContent",
    "ShowShareMenu": "showShareMenu",

    "ShowShareView": "showShareView",
    "GetFriendList": "getFriendList",
    "AddFriend": "addFriend",
    "CloseSSOWhenAuthorize": "closeSSOWhenAuthorize"
  };


  /**
   * 平台类型
   * @type {object}
   */
  this.PlatformID = {
    Unknown: 0,
    SinaWeibo: 1,			//Sina Weibo
    TencentWeibo: 2,		//Tencent Weibo
    DouBan: 5,				//Dou Ban
    QZone: 6, 				//QZone
    Renren: 7,				//Ren Ren
    Kaixin: 8,				//Kai Xin
    Pengyou: 9,			//Friends
    Facebook: 10,			//Facebook
    Twitter: 11,			//Twitter
    Evernote: 12,			//Evernote
    Foursquare: 13,		//Foursquare
    GooglePlus: 14,		//Google+
    Instagram: 15,			//Instagram
    LinkedIn: 16,			//LinkedIn
    Tumblr: 17,			//Tumblr
    Mail: 18, 				//Mail
    SMS: 19,				//SMS
    Print: 20, 			//Print
    Copy: 21,				//Copy
    WeChat: 22,		    //WeChat Friends
    WeChatMoments: 23,	    //WeChat Timeline
    QQ: 24,				//QQ
    Instapaper: 25,		//Instapaper
    Pocket: 26,			//Pocket
    YouDaoNote: 27, 		//You Dao Note
    Pinterest: 30, 		//Pinterest
    Flickr: 34,			//Flickr
    Dropbox: 35,			//Dropbox
    VKontakte: 36,			//VKontakte
    WeChatFavorites: 37,	//WeChat Favorited
    YiXinSession: 38, 		//YiXin Session
    YiXinTimeline: 39,		//YiXin Timeline
    YiXinFav: 40,			//YiXin Favorited
    MingDao: 41,          	//明道
    Line: 42,             	//Line
    WhatsApp: 43,         	//Whats App
    KakaoTalk: 44,         //KakaoTalk
    KakaoStory: 45,        //KakaoStory
    FacebookMessenger: 46, //FacebookMessenger
    Bluetooth: 48,         //Bluetooth
    Alipay: 50,            //Alipay
    KakaoPlatform: 995,    //Kakao Series
    EvernotePlatform: 996, //Evernote Series
    WechatPlatform: 997,   //Wechat Series
    QQPlatform: 998,		//QQ Series
    Any: 999 				//Any Platform
  };

  /**
   * 回复状态
   * @type {object}
   */
  this.ResponseState = {
    Begin: 0,              //开始
    Success: 1,             //成功
    Fail: 2,               //失败
    Cancel: 3               //取消
  };

  /**
   * 内容分享类型
   * @type {object}
   */
  this.ContentType = {
    Auto: 0,
    Text: 1,
    Image: 2,
    WebPage: 4,
    Music: 5,
    Video: 6,
    App: 7,
    File: 8,
    Emoji: 9
  };

};

/**
 * iOS接口调用器
 */
function IOSAPICaller() {
  this.requestes = {};
};

IOSAPICaller.prototype = {
  constructor: IOSAPICaller,

  /**
   * 返回回调
   * @param response      回复数据
   *
   * response结构
   * {
         *   "seqId" : "111111",
         *   "platform" : 1,
         *   "state" : 1,
         *   "data" : "user or share response"
         *   "callback" : "function string"
         *   "error" :
         *   {
         *      "error_code" : 11,
         *      "error_msg" : "adsfdsaf",
         *   }
         * }
   */
  callback: function (response) {
    if (response.callback) {
      var callbackFunc = eval(response.callback);
      if (callbackFunc) {
        var method = response.method;
        switch (method) {
          case this.ShareSDKMethodName.Authorize:
            callbackFunc(response.seqId, response.platform, response.state, response.error);
            break;
          case this.ShareSDKMethodName.GetUserInfo:
            callbackFunc(response.seqId, response.platform, response.state, response.data, response.error);
            break;
          case this.ShareSDKMethodName.IsAuthorizedValid:
            callbackFunc(response.seqId, response.platform, response.data);
            break;
          case this.ShareSDKMethodName.IsClientValid:
            callbackFunc(response.seqId, response.platform, response.data);
            break;
          case this.ShareSDKMethodName.ShareContent:
          case this.ShareSDKMethodName.OneKeyShareContent:
          case this.ShareSDKMethodName.ShowShareMenu:
          case this.ShareSDKMethodName.ShowShareView:
            callbackFunc(response.seqId, response.platform, response.state, response.data, response.error);
            break;
          case this.ShareSDKMethodName.GetFriendList:
            callbackFunc(response.seqId, response.platform, response.state, response.data, response.error);
            break;
          case this.ShareSDKMethodName.AddFriend:
            callbackFunc(response.seqId, response.platform, response.state, response.error);
            break;
          case this.ShareSDKMethodName.GetAuthInfo:
            callbackFunc(response.seqId, response.platform, response.data);
            break;
        }
      }
    }
  },

  getParams: function (seqId) {
    var paramsStr = null;
    var request = this.requestes[seqId];

    if (request && request.params) {
      paramsStr = ObjectToJsonString(request.params);
    }

    this.requestes[seqId] = null;
    delete this.requestes[seqId];
    return paramsStr;
  },

  /**
   * 调用方法
   * @param request    请求信息
   */
  callMethod: function (request) {
    this.requestes[request.seqId] = request;

    cordova.exec(this.callback, function (err) {
      alert('原生代码调用返回错误');
    }, "ShareSDKCDV", "dispatcher", ['call', request.method, request.seqId, this.getParams(request.seqId)]);

  }

}

/**
 * Android接口调用器
 * @constructor
 */
function AndroidAPICaller() {

};
AndroidAPICaller.prototype = {
  constroctor: AndroidAPICaller,
  /**
   * 调用方法
   * @param request       请求信息
   */
  callMethod: function (request) {
    if (this.isDebug) {
      this.jsLog.log("js request: " + request.method);
      this.jsLog.log("seqId = " + request.seqId.toString());
      this.jsLog.log("api = " + request.method);
      this.jsLog.log("data = " + ObjectToJsonString(request.params));
    }

    //java接口
    window.JSInterface.jsCallback(request.seqId.toString(), request.method, ObjectToJsonString(request.params), "$sharesdk.callback");
  },

  /**
   * 返回回调
   * @param response      回复数据
   *
   * response结构
   * {
         *   "seqId" : "111111",
         *   "platform" : 1,
         *   "state" : 1,
         *   "data" : "user or share response"
         *   "callback" : "function string"
         *   "error" :
         *   {
         *      "error_code" : 11,
         *      "error_msg" : "adsfdsaf",
         *   }
         * }
   */
  callback: function (response) {
    var logMsg = "java returns: " + JSON.stringify(response);
    if (this.isDebug) {
      this.jsLog.log(logMsg);
    }
    if (response.callback) {
      var callbackFunc = eval(response.callback);

      if (callbackFunc) {
        var method = response.method;

        switch (method) {
          case this.ShareSDKMethodName.Authorize:
            callbackFunc(response.seqId, response.platform, response.state, response.error);
            break;
          case this.ShareSDKMethodName.GetUserInfo:
            callbackFunc(response.seqId, response.platform, response.state, response.data, response.error);
            break;
          case this.ShareSDKMethodName.IsAuthorizedValid:
            callbackFunc(response.seqId, response.platform, response.data);
            break;
          case this.ShareSDKMethodName.IsClientValid:
            callbackFunc(response.seqId, response.platform, response.data);
            break;
          case this.ShareSDKMethodName.ShareContent:
          case this.ShareSDKMethodName.OneKeyShareContent:
          case this.ShareSDKMethodName.ShowShareMenu:
          case this.ShareSDKMethodName.ShowShareView:
            isShare = true;
            callbackFunc(response.seqId, response.platform, response.state, response.data, response.error);
            break;
          case this.ShareSDKMethodName.GetFriendList:
            callbackFunc(response.seqId, response.platform, response.state, response.data, response.error);
            break;
          case this.ShareSDKMethodName.AddFriend:
            callbackFunc(response.seqId, response.platform, response.state, response.error);
            break;
          case this.ShareSDKMethodName.GetAuthInfo:
            callbackFunc(response.seqId, response.platform, response.data);
            break;
        }
      }
    }
  }
};

/**
 * 请求信息
 * @param seqId         流水号
 * @param method        方法
 * @param params        参数集合
 * @constructor
 */

function RequestInfo(seqId, method, params) {
  this.seqId = seqId;
  this.method = method;
  this.params = params;
  this.nextRequest = null;
};


ShareSDK.prototype = {
  constructor: ShareSDK,

  /**
   * JSON字符串转换为对象
   * @param string        JSON字符串
   * @returns {Object}    转换后对象
   */
  JsonStringToObject: function (string) {
    try {
      return eval("(" + string + ")");
    }
    catch (err) {
      return null;
    }
  },



  /**
   * 初始化SDK (由系统调用)
   * @param platform  平台类型，1 安卓 2 iOS
   * @private
   */
  initSDK: function (platform) {
    switch (platform) {
      case 1:
        this.jsLog = {
          log: function (msg) {
            window.JSInterface.this.jsLog(msg);
          }
        };
        if (this.isDebug) {
          this.jsLog.log("found platform type: Android");
        }
        this.apiCaller = new AndroidAPICaller();
        break;
      case 2:
        this.jsLog = {
          log: function (msg) {
          }
        };

        this.apiCaller =  new IOSAPICaller();
        break;
    }

    //派发回调
    for (var i = 0; i < this.initCallbackFuncs.length; i++) {
      var obj = this.initCallbackFuncs[i];
      obj.callback(obj.method, obj.params);
    }
    this.initCallbackFuncs.splice(0);
  },

  /**
   * 检测是否已经初始化
   * @param callback  回调方法
   * @private
   */
  CheckInit: function (method, params, callback) {
    if (this.apiCaller == null) {
      this.initCallbackFuncs.push({
        "method": method,
        "params": params,
        "callback": callback
      });

      if (!this.isSendInitRequest) {
        this.initSDK(this.PLATFORM_SHARE);
        this.isSendInitRequest = true;
      }
    }
    else {
      if (callback) {
        callback(method, params);
      }
    }
  },

  /**
   * 调用方法
   * @param method        方法
   * @param params        参数
   * @private
   */
  CallMethod: function (method, params) {
    var self = this;
    this.CheckInit(method, params, function (method, params) {
      self.seqId++;
      var req = new RequestInfo(self.seqId, method, params);

      if (self.firstRequest == null) {
        self.firstRequest = req;
        self.lastRequest = self.firstRequest;
      }
      else {
        self.lastRequest.nextRequest = req;
        self.lastRequest = req;
      }

      self.SendRequest();
    });
    return self.seqId;
  },

  /**
   * 发送请求
   * @private
   */
  SendRequest: function () {
    if (!this.isRunning && this.firstRequest) {
      this.isRunning = true;
      this.apiCaller.callMethod(this.firstRequest);
      var self = this;
      setTimeout(function () {

        self.isRunning = false;
        //直接发送下一个请求
        self.NextRequest();
        self.SendRequest();

      }, 50);
    }
  },

  /**
   * 下一个请求
   * @private
   */
  NextRequest: function () {
    if (this.firstRequest == this.lastRequest) {
      this.firstRequest = null;
      this.lastRequest = null;
      this.isRunning = false;
    }
    else {
      this.firstRequest = this.firstRequest.nextRequest;
    }
  },


  /**
   * 回调方法 (由系统调用)
   * @param response  回复数据
   * @private
   */
  callback: function (response) {
    this.apiCaller.callback(response);
  },

  /**
   * 获取参数
   * @param seqId
   * @returns {*}
   * @private
   */
  getParams: function (seqId) {
    return this.apiCaller.getParams(seqId);
  },

  /**
   * 设置平台配置
   * @param platform          平台类型
   * @param config            配置信息
   */
  initSDKAndSetPlatfromConfig: function (appKey, platformConfig) {
    var params =
    {
      "appKey": appKey,
      "platformConfig": platformConfig
    };
    this.CallMethod(this.ShareSDKMethodName.InitSDKAndSetPlatfromConfig, params);
  },

  /**
   * 用户授权
   * @param platform          平台类型
   * @param callback          回调方法
   */
  authorize: function (platform, callback) {
    var params =
    {
      "platform": platform,
      "callback": "(" + callback.toString() + ")"
    };

    return this.CallMethod(this.ShareSDKMethodName.Authorize, params);
  },

  /**
   * 取消用户授权
   * @param platform          平台类型
   */
  cancelAuthorize: function (platform) {
    var params =
    {
      "platform": platform
    };

    this.CallMethod(this.ShareSDKMethodName.CancelAuthorize, params);
  },

  /**
   * 是否授权
   * @param platform          平台类型
   * @param callback          回调方法
   *
   */
  isAuthorizedValid: function (platform, callback) {
    var params =
    {
      "platform": platform,
      "callback": "(" + callback.toString() + ")"
    };

    return this.CallMethod(this.ShareSDKMethodName.IsAuthorizedValid, params);
  },

  /**
   * 客户端是否可用
   * @param platform          平台类型
   * @param callback          回调方法
   *
   */
  isClientValid: function (platform, callback) {
    var params =
    {
      "platform": platform,
      "callback": "(" + callback.toString() + ")"
    };

    return this.CallMethod(this.ShareSDKMethodName.IsClientValid, params);
  },

  /**
   * 获取用户信息
   * @param platform          平台类型
   * @param callback          回调方法
   */
  getUserInfo: function (platform, callback) {
    var params =
    {
      "platform": platform,
      "callback": "(" + callback.toString() + ")"
    };

    return this.CallMethod(this.ShareSDKMethodName.GetUserInfo, params);
  },

  /**
   * 获取授权信息
   * @param platform          平台类型
   * @param callback          回调方法
   */
  getAuthInfo: function (platform, callback) {
    var params =
    {
      "platform": platform,
      "callback": "(" + callback.toString() + ")"
    };

    return this.CallMethod(this.ShareSDKMethodName.GetAuthInfo, params);
  },

  /**
   * 分享内容
   * @param platform          平台类型
   * @param shareParams       分享内容
   * @param callback          回调方法
   */
  shareContent: function (platform, shareParams, callback) {
    var params =
    {
      "platform": platform,
      "shareParams": shareParams,
      "callback": "(" + callback.toString() + ")"
    };

    return this.CallMethod(this.ShareSDKMethodName.ShareContent, params);
  },

  /**
   * 一键分享
   * @param platforms         分享的目标平台类型集合
   * @param shareParams       分享内容
   * @param callback          回调方法
   */
  oneKeyShareContent: function (platforms, shareParams, callback) {
    var params =
    {
      "platforms": platforms,
      "shareParams": shareParams,
      "callback": "(" + callback.toString() + ")"
    };

    return this.CallMethod(this.ShareSDKMethodName.OneKeyShareContent, params);
  },

  /**
   * 显示分享菜单
   * @param platforms         分享的目标平台类型集合
   * @param shareParams       分享内容
   * @param x                 弹出菜单的原点横坐标（仅用于iPad）
   * @param y                 弹出菜单的原点纵坐标（仅用于iPad）
   * @param callback          回调方法
   */
  showShareMenu: function (platforms, shareParams, x, y, callback) {
    var params =
    {
      "platforms": platforms,
      "shareParams": shareParams,
      "x": x,
      "y": y,
      "theme": "skyblue",
      "callback": "(" + callback.toString() + ")"
    };

    return this.CallMethod(this.ShareSDKMethodName.ShowShareMenu, params);
  },

  /**
   * 显示分享视图
   * @param platform
   * @param shareParams
   * @param callback
   */
  showShareView: function (platform, shareParams, callback) {
    var params =
    {
      "platform": platform,
      "shareParams": shareParams,
      "callback": "(" + callback.toString() + ")"
    };

    return this.CallMethod(this.ShareSDKMethodName.ShowShareView, params);
  },

  /**
   * 获取朋友列表
   * @param platform
   * @param page
   * @param count
   * @param account
   * @param callback
   */
  getFriendList: function (platform, page, count, account, callback) {
    var params =
    {
      "platform": platform,
      "page": page,
      "count": count,
      "account": account,
      "callback": "(" + callback.toString() + ")"
    };
    return this.CallMethod(this.ShareSDKMethodName.GetFriendList, params);
  },

  /**
   * 关注好友
   * @param platform
   * @param friendName
   * @param callback
   */
  addFriend: function (platform, friendName, callback) {
    var params =
    {
      "platform": platform,
      "friendName": friendName,
      "callback": "(" + callback.toString() + ")"
    }
    return this.CallMethod(this.ShareSDKMethodName.AddFriend, params);
  },

  /**
   * 设置平台配置（这个接口仅对Android有效果）
   * @param platform          平台类型
   * @param config            配置信息
   */
  closeSSOWhenAuthorize: function (disableSSO) {
    var params =
    {
      "disableSSO": disableSSO
    };

    this.CallMethod(this.ShareSDKMethodName.CloseSSOWhenAuthorize, params);
  }
};


/**
 * 对象转JSON字符串
 * @param obj           对象
 * @returns {string}    JSON字符串
 */
function ObjectToJsonString(obj) {
  var S = [];
  var J = null;

  var type = Object.prototype.toString.apply(obj);

  if (type === '[object Array]') {
    for (var i = 0; i < obj.length; i++) {
      S.push(ObjectToJsonString(obj[i]));
    }
    J = '[' + S.join(',') + ']';
  }
  else if (type === '[object Date]') {
    J = "new Date(" + obj.getTime() + ")";
  }
  else if (type === '[object RegExp]'
    || type === '[object Function]') {
    J = obj.toString();
  }
  else if (type === '[object Object]') {
    for (var key in obj) {
      var value = ObjectToJsonString(obj[key]);
      if (value != null) {
        S.push('"' + key + '":' + value);
      }
    }
    J = '{' + S.join(',') + '}';
  }
  else if (type === '[object String]') {
    J = '"' + obj.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '') + '"';
  }
  else if (type === '[object Number]') {
    J = obj;
  }
  else if (type === '[object Boolean]') {
    J = obj;
  }

  return J;
}



window.$sharesdk = new ShareSDK();
