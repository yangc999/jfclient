
local PlatformConstants = {}

PlatformConstants.START_MESSAGE = "message_start"
PlatformConstants.START_LOAD = "load_start"
PlatformConstants.START_INITWX = "initwx_start"
PlatformConstants.START_UPDATE = "update_start"
PlatformConstants.START_LOGIN = "login_start"
PlatformConstants.START_LOGOUT = "logout_start"
PlatformConstants.START_REGISTER = "register_start"
PlatformConstants.START_HALL = "hall_start"
PlatformConstants.START_USERINFO = "userinfo_start"
PlatformConstants.START_GAMELIST = "gamelist_start"
PlatformConstants.START_ROOMLIST = "roomlist_start"
PlatformConstants.START_HORSELAMP = "horselamp_start"
PlatformConstants.START_BENEFITS = "benefits_start"
PlatformConstants.START_DESKLIST = "desklist_start"


PlatformConstants.REQUEST_USERINFO = "userinfo_request"
PlatformConstants.REQUEST_UPDATEUSERWEALTH = "updateuserwealth_request"

PlatformConstants.SHOW_UPDATE = "update_show"
PlatformConstants.SHOW_USERINFO = "userinfo_show"
PlatformConstants.SHOW_GAMELIST = "gamelist_show"
PlatformConstants.SHOW_ROOMLIST = "roomlist_show"
PlatformConstants.SHOW_PRIVATEROOM = "privateroom_show"
PlatformConstants.SHOW_ROOMCREATE = "roomcreate_show"
PlatformConstants.SHOW_ROOMJOIN = "roomjoin_show"
PlatformConstants.SHOW_SIGN = "sign_show"
PlatformConstants.SHOW_BINDPHONENUMBER = "bindphonenumber_show"
PlatformConstants.SHOW_BENEFITS = "benefits_show"
PlatformConstants.SHOW_ASSISTANCE_TIPS = "assistance_tips_show"


PlatformConstants.TEST_NETWORK = "network_test"

PlatformConstants.REQUEST_CONFIG = "config_request"
PlatformConstants.REQUEST_LOGIN = "login_request"
PlatformConstants.REQUEST_LOGINWX = "loginwx_request"
PlatformConstants.REQUEST_LOGOUT = "logout_request"
PlatformConstants.REQUEST_ROOMCFG = "roomconfig_request"
PlatformConstants.REQUEST_ROOMCREATE = "roomcreate_request"
PlatformConstants.REQUEST_HORSELAMP = "horselamp_request"
PlatformConstants.REQUEST_BENEFITS_CONFIG = "benefits_config_request"
PlatformConstants.REQUEST_BENEFITS = "benefits_request"
PlatformConstants.REQUEST_BENEFITS_INFO = "benefits_request_info"
PlatformConstants.REQUEST_TASK_INFO = "task_info_request"
PlatformConstants.REQUEST_DESKLIST = "desklist_request"
PlatformConstants.REQUEST_DESKDETAIL = "deskdetail_request"
PlatformConstants.DISMISS_CREATE_ROOM = "create_room_dismiss"


PlatformConstants.UPDATE_USERNAME = "username_update"
PlatformConstants.UPDATE_NICKNAME = "nickname_update"
PlatformConstants.UPDATE_HEADID = "headid_update"
PlatformConstants.UPDATE_HEADSTR = "headstr_update"
PlatformConstants.UPDATE_GENDER = "gender_update"
PlatformConstants.UPDATE_MOBILE = "mobile_update"
PlatformConstants.UPDATE_SIGNATURE = "sign_update"
PlatformConstants.UPDATE_GOLD = "gold_update"
PlatformConstants.UPDATE_SAFEGOLD = "safegold_update"
PlatformConstants.UPDATE_ROOMCARD = "roomcard_update"
PlatformConstants.UPDATE_DIAMOND = "diamond_update"
PlatformConstants.UPDATE_EXPERIENCE = "exp_update"
PlatformConstants.UPDATE_VIPLEVEL = "viplevel_update"
PlatformConstants.UPDATE_ROOMCFG = "roomconfig_update"
PlatformConstants.UPDATE_ROOMCHC = "roomchoice_update"
PlatformConstants.UPDATE_ROOMSLC = "roomselect_update"
PlatformConstants.UPDATE_ANTICHEATING = "anticheating_update"
PlatformConstants.UPDATE_ROOMKEY = "roomkey_update"
PlatformConstants.UPDATE_PUBGAMELIST = "publicgamelist_update"
PlatformConstants.UPDATE_PRIGAMELIST = "privategamelist_update"
PlatformConstants.UPDATE_HORSELAMP = "horselamp_update"
PlatformConstants.UPDATE_TASKINFO = "taskinfo_update"
PlatformConstants.UPDATE_PASSWORD = "userpassword_update"
PlatformConstants.UPDATE_SAFEPASSWORD = "usersafepassword_update"
PlatformConstants.UPDATE_SETSAFEPASS = "setsafepass_update"
PlatformConstants.UPDATE_SETREALNAME = "setrealname_update"
PlatformConstants.UPDATE_MOBILEBIND = "setmobilebind_update"
PlatformConstants.UPDATE_AGCBELONG = "agcbelong_update"
PlatformConstants.UPDATE_ASSISTANCE_TIMES = "assistance_times_update"
PlatformConstants.UPDATE_MESSAGE = "message_update"
PlatformConstants.UPDATE_ROOMLIST = "roomlist_update"
PlatformConstants.UPDATE_PUBROOM = "publicroom_update"
PlatformConstants.UPDATE_QUICKROOM = "quickroom_update"
PlatformConstants.UPDATE_SHOWDESK = "showdesk_update"
PlatformConstants.UPDATE_PRIVATEROOM_STATE="privateroom_state_update"

PlatformConstants.ADD_ROOMKEY = "roomkey_add"
PlatformConstants.SUB_ROOMKEY = "roomkey_sub"
PlatformConstants.CLR_ROOMKEY = "roomkey_clear"

PlatformConstants.ADD_ROOMCHC = "roomchoice_add"
PlatformConstants.SUB_ROOMCHC = "roomchoice_sub"
PlatformConstants.CHG_ROOMCHC = "roomchoice_change"

--公告相关
PlatformConstants.REQUEST_ANNOUNCELIST = "announcelist_request"  --请求公告列表
PlatformConstants.START_ANNOUNCELIST = "announcelist_start"  --初始化公告列�?
PlatformConstants.SHOW_ANNOUNCELIST = "announcelist_show"  --显示公告列表
PlatformConstants.REQUEST_ANNOUNCEBYID = "announce_requestbyid"  --根据ID来请求某个公告正�?
PlatformConstants.SHOW_ANNOUNCECONTENT = "announce_show"  --显示某条公告具体正文内容

--银行相关
PlatformConstants.START_BANKLAYER = "banklayer_start" --请求显示银行界面
PlatformConstants.REQUEST_USERWEALTHCHANGE = "userwealthchange_request" --请求用户的财�?
PlatformConstants.UPDATE_USERWEALTH = "userwealth_update"  --更新用户财富
PlatformConstants.START_SETBANKPASS = "setbankpass_start"  --显示设置银行密码
PlatformConstants.REQUEST_SETBANKPASS = "setbankpass_request"  --请求设置银行密码
PlatformConstants.REQUEST_MOBILECODE = "mobilecode_request"  --请求手机验证�?
PlatformConstants.REQUEST_BINDMOBILE = "bindmobile_request"  --请求绑定手机�? 
PlatformConstants.RESULT_BINDMOBILE = "bindmobile_result"  --绑定手机号结�?
PlatformConstants.RESULT_MOBILECODE = "mobilecode_result" --请求手机验证码结�?
PlatformConstants.REQUEST_SAVEBANKMONEY = "savebankmoney_request"  --请求存钱到银�?
PlatformConstants.REQUEST_DRAWBANKMONEY = "drawbankmoney_request"  --请求银行取钱
PlatformConstants.REQUEST_USERPERFECTINFO = "userperfectinfo_request"  --请求用户是否完善了个人信息，是否实名认证，是否设置了银行密码�?
PlatformConstants.RESULT_BANKPASSSET = "bankpassset_result"  --设置银行密码结果 
PlatformConstants.RESULT_BANKPASSMODIFY = "bankpassmodify_result"  --修改银行密码结果
PlatformConstants.RESULT_SAVEBANKMONEY = "savebankmoney_result"  --银行存钱结果
PlatformConstants.RESULT_DRAWBANKMONEY = "drawbankmoney_result" --银行取钱结果
PlatformConstants.START_INPUTBANKPASS = "inputpassword_start"  --请求显示输入密码界面
PlatformConstants.START_BINDMOBILE = "bindmobile_start" --开始显示绑定手机号UI
PlatformConstants.START_MODIFYBANKPASS = "modifybankpass_start" --开始显示修改密码UI
PlatformConstants.REQUEST_MODIFYBANKPASS = "modifybankpass_request" --请求修改银行密码
PlatformConstants.START_FORGETBANKPASS = "forgetbankpass_start" --启动找回密码UI
PlatformConstants.REQUEST_FORGETBANKPASS = "forgetbankpass_request" --找回密码请求
PlatformConstants.RESULT_FORGETBANKPASS = "forgetbankpass_result" --找回密码请求结果返回
PlatformConstants.PHONE_VALID = "valid_phone" --手机验证码已发�?通知改变界面

--用户协议相关
--PlatformConstants.START_USERLOGIN = "userlogin_start"  --启动用户登录
PlatformConstants.START_USERAGREE = "useragree_start"  --启动用户协议
PlatformConstants.SET_USERAGREE = "useragree_set"  --设置用户协议为true

--商城相关
PlatformConstants.START_SHOPLAYER = "shoplayer_start"  --初始化显示商�?
PlatformConstants.UPDATE_SHOPCOINLIST = "shopcoinlist_update"   --更新金币列表
PlatformConstants.UPDATE_SHOPDIAMONDLIST = "shopdiamondlist_update" --更新钻石商品列表
PlatformConstants.UPDATE_SHOPFANGKALIST = "shopfangkalist_update"  --更新房卡商品列表
PlatformConstants.REQUEST_SHOPLISTBYID = "shoplistbyid_request"   --请求某种商品列表
PlatformConstants.SHOW_SHOPLIST = "shoplist_show"  --显示商品列表
PlatformConstants.UPDATE_SHOPLIST = "shoplist_update"  --更新商品列表
PlatformConstants.RESULT_SHOPDIAMONDBUY = "shopdiamondbuy_result"  --商城钻石购买结果
PlatformConstants.REQUEST_DIAMONDBUY = "shopdiamondbuy_request"   --请求钻石购买
PlatformConstants.START_PAYSELECT = "payselect_start"   --请求钻石购买

--抽奖相关
PlatformConstants.START_LOTTERYLAYER = "lotterylayer_start"  --启动抽奖UI
PlatformConstants.UPDATE_LOTTERYFREELIST = "lotteryfreelist_update"  --更新免费抽奖列表
PlatformConstants.UPDATE_LOTTERYVIPLIST = "lotteryviplist_update"  --更新vip抽奖列表
PlatformConstants.UPDATE_LOTTERYLIST = "lotterylist_update"  --更新vip抽奖列表
PlatformConstants.REQUEST_LOTTERYLIST = "lotterylist_request" --请求抽奖列表
PlatformConstants.REQUEST_DRAWLOTTER = "drawlotter_request"  --请求用户抽奖结果
PlatformConstants.UPDATE_FREETIMES = "freetimes_update"     --免费抽奖次数更新
PlatformConstants.UPDATE_PAYTIMES = "paytimes_update"       --付费抽奖次数更新
PlatformConstants.RESULT_ROLLER = "roller_result"  --获得抽奖结果
PlatformConstants.UPDATE_USERLOTTERYLIST = "userlotterylist_update"  --用户列表更新
PlatformConstants.UPDATE_TOTALLOTTERYLIST = "totallotterylist_update"  --全部用户列表更新
PlatformConstants.REQUEST_LOTTERYLISTUSER = "lotterylistuser_request" --请求用户自己的抽奖列�?
PlatformConstants.REQUEST_LOTTERYLISTTOTAL = "lotterylisttotal_request" --请求全部用户的抽奖列�?
PlatformConstants.START_LOTTERYBANDPHONE = "lotterybandphone_start"  --抽奖时请求绑定手�?
PlatformConstants.START_LOTTERYGIFTANIM = "lotterygiftanim_start"  --抽奖时请求抽奖动�?

--实名认证相关
PlatformConstants.START_REALNAMELAYER = "realnamelayer_start"  --启动实名认证UI
PlatformConstants.RESULT_REALNAME = "realname_result"  --实名认证请求结果
PlatformConstants.REQUEST_REALNAME = "realname_request"  --请求实名认证

--设置相关
PlatformConstants.START_SYSSETLAYER = "syssetlayer_start"  --启动系统设置UI
PlatformConstants.START_GAMEHELPLAYER = "gamehelplayer_start"  --启动游戏帮助UI
PlatformConstants.START_CUSTOMHELPLAYER = "customhelplayer_start"  --启动客服帮助UI
PlatformConstants.START_USERAGREEUILAYER = "useragreeuilayer_start" --启动用户协议UI

--战绩相关
PlatformConstants.START_MATCHRECORDSLAYER = "matchrecordslayer_start"  --启动战绩UI
PlatformConstants.START_MATCHRECORDDETAIL = "matchrecorddetail_start"  --启动战绩详情UI
PlatformConstants.REQUEST_MATCHRECORDNUM = "matchrecordsnum_request"  --请求战绩数量
PlatformConstants.REQUEST_MATCHRECORDLIST = "matchrecordslist_request"  --请求战绩列表
PlatformConstants.REQUEST_MATCHRECORDVIDEOURL = "matchrecordvideourl_request"  --请求回放下载地址
PlatformConstants.REQUEST_MATCHRECORDVIDEODATA = "matchrecordvideodata_request"  --请求比赛回放资源
PlatformConstants.REQUEST_MATCHRECORDDETAIL = "matchrecorddetail_request"  --请求私人房战局详细列表
PlatformConstants.UPDATE_MATCHRECORDLIST = "matchrecordlist_update"     --战绩列表更新
PlatformConstants.UPDATE_MATCHRECORDNUM = "matchrecordnum_update"  --战绩数量更新
PlatformConstants.GET_MATCHRECORDDETAIL = "matchrecorddetail_get"   --获取到战局详细信息
PlatformConstants.PLAY_MATCHVIDEO = "matchrecordvideo_play"    --播放比赛视频
PlatformConstants.REQUEST_MATCHRECORDVIDEO = "matchrecordvideo_play"  --请求播放比赛视频

--任务分享相关
PlatformConstants.REQUEST_TASKSHARE_ID = "taskidshare_request"  --请求任务分享的任务ID
PlatformConstants.REQUEST_TASKSHARE_AWARD = "taskshareaward_request"  --请求任务分享奖励
PlatformConstants.UPDATE_TASKSHARE_INFO = "taskshareinfo_update"  --任务分享信息更新
PlatformConstants.REQUEST_TASKSHARE = "taskshare_request"   --请求分享任务
PlatformConstants.REQUEST_TASKSHARE_CONFIG = "taskshare_config_request"  --请求分享任务的配�?
PlatformConstants.START_TASKSHARE = "taskshare_start"   --启动任务分享UI
PlatformConstants.RESULT_WEIXINSHARE = "weixinshare_result"   --微信分享结果
PlatformConstants.SHARE_FINISH = "finish_share"   --分享成功
PlatformConstants.BIND_SUCCESS="binding_success" --绑定成功


--绑定邀请码相关
PlatformConstants.BINDFRIENDCODE_START = "bindfriendcode_start"  --启动绑定朋友邀请码UI
PlatformConstants.REQUEST_BINDINVITECODE = "bindinvitecode_request"  --绑定邀请码请求

PlatformConstants.DOWNLOAD_HEAD = "head_download"

--消息相关
PlatformConstants.CREATE_MSGBOX = "msgbox_create"		--创建消息对话�?
PlatformConstants.UPDATE_MSGBOX = "msgbox_update"		--更新消息对话�?
PlatformConstants.UPDATE_MSGBOX_EX = "msgbox_update_ex"		--扩展版更新消息对话框
PlatformConstants.CREATE_MSGBOXEX = "create_msgbox_ex"		--创建扩展功能的消息对话框
PlatformConstants.CLOSE_MSGBOX = "close_msgbox"		--关闭消息对话框
PlatformConstants.MSGBOX_CANCEL = "msgbox_cancel"		--点击取消按钮
PlatformConstants.MSGBOX_OK = "msgbox_ok"		--点击确定按钮
PlatformConstants.MSGBOX_KNOW = "msgbox_know"		--点击知道按钮

--Loading转圈动画相关
PlatformConstants.CREATE_LOADINGANIM = "loadinganim_create"		--创建转圈动画
PlatformConstants.SHOW_LOADINGANIM = "loadinganim_show"		--显示动画
PlatformConstants.HIDE_LOADINGANIM = "loadinganim_hide"		--显示动画

--支付相关
PlatformConstants.WXPAY_OK = "ok_wxpay"		--微信支付成功消息
PlatformConstants.ALIPAY_OK = "ok_alipay"		--支付宝支付成功消�?
PlatformConstants.WXPAY_FAILED = "failed_wxpay"		--微信支付失败消息
PlatformConstants.ALIPAY_FAILED = "failed_alipay"		--支付宝支付失败消�?

--比赛相关
PlatformConstants.START_COMPETITIONLIST = "competitionlist_start"
PlatformConstants.START_COMPETITIONDETAIL = "competitiondetail_start"
PlatformConstants.SHOW_COMPETITIONDETAIL="competitiondetail_show"
PlatformConstants.START_COMPETITIONGAMELIST="competitiongamelist_show"
PlatformConstants.START_COMPETITIONMOREGAME="competitionmoregame_show"

PlatformConstants.REQUEST_COMPETITIONLIST= "competitionlist_request"
PlatformConstants.REQUEST_COMPETITIONDETAIL="competitiondetail_request"
PlatformConstants.REQUEST_COMPETITIONLISTPLAYERNUM="competitionlistplayernum_request"
PlatformConstants.REQUEST_COMPETITIONGAMELIST="competitiongamelist_request"   --请求比赛游戏列表

PlatformConstants.UPDATE_SHOWCOMPETITIONLIST="showcompetitionlist_update"
PlatformConstants.UPDATE_SHOWCOMPETITIONDETAIL="showcompetitiondetail_update"
PlatformConstants.UPDATE_COMPETITIONLISTPLAYERNUM="competitionlistplayernum_update"
PlatformConstants.UPDATE_COMPETITIONGAMELIST="competitiongamelist_upadte"
PlatformConstants.UPDATE_COMPETITIONMOREGAME="competitionmoregame_upadte"
PlatformConstants.UPDATE_COMPETITIONMOREGAMELIST="competitionmoregamelist_upadte"
PlatformConstants.UPDATE_COMPETITIONMOREGAMELISTSELECTED="competitionmoregamelistselected_upadte"
PlatformConstants.UPDATE_COMPETITIONBMSTATE="competitionbmstate" --更新报名按钮状�?

--俱乐部相�?
PlatformConstants.START_MATCHHOME = "matchhome_start"		--创建比赛首页
PlatformConstants.START_MATCHSHARE = "matchshare_start"     --创建分享朋友的页�?

--背景音乐
PlatformConstants.HALL_MUSIC_PATH = "sound/hallbackgroudmusic.mp3"       --音乐路径
PlatformConstants.BUTTON_MUSIC_PATH = "sound/btnmusic.mp3"     --按钮音乐路径

cc.exports.PlatformConstants = PlatformConstants