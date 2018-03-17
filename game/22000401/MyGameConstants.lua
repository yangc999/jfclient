local MyGameConstants = {}

-- 接收游戏消息名称(服务器发来的消息)
MyGameConstants.PLAYER_SIT = "player_sit"                           -- 有玩家坐下
MyGameConstants.PLAYER_STAND = "player_stand"                       -- 有玩家离桌
MyGameConstants.PLAYER_OFFLINE = "player_offline"                   -- 有玩家掉线
MyGameConstants.PLAYER_RECOME = "player_recome"                     -- 有玩家重入

MyGameConstants.AGREE_GAME = "agree_game"                           -- 同意游戏
MyGameConstants.START_GAME = "start_game"                           -- 开始游戏
MyGameConstants.AUTO_INFO = "auto_info"                             -- 某玩家托管或者取消托管

MyGameConstants.PIAO_NOTIFY = "piao_notify"                         -- 通知加漂
MyGameConstants.PIAO_RESP = "piao_resp"                             -- 加漂结果

MyGameConstants.MAKE_NT = "make_nt"                                 -- 定庄
MyGameConstants.FETCH_HANDCARDS = "fetch_handcads"                  -- 发手牌
MyGameConstants.FETCH_VIDEO_HANDCARDS = "fetch_video_handcads"      -- 录像发手牌
MyGameConstants.GET_TOKEN = "get_token"                             -- 得到令牌
MyGameConstants.OUTCARD_INFO = "outcard_info"                       -- 出牌结果

MyGameConstants.ACT_NOTIFY = "act_notify"                           -- 动作通知
MyGameConstants.ACT_REQ = "act_req"                                 -- 动作请求
MyGameConstants.ACT_INFO = "act_info"                               -- 动作返回结果

MyGameConstants.NIAO_CARD = "niao_card"                             -- 抓鸟

MyGameConstants.ROUND_FINISH = "round_finish"                       -- 一回合结束
MyGameConstants.PAIJU_INFO = "paiju_info"                           -- 牌局结束

MyGameConstants.GAME_STATION = "game_station"                       -- 断线重连
MyGameConstants.GAME_TEST = "game_test"                             -- 测试

-----------------------------------------------------------
-- 游戏内部消息名称
MyGameConstants.C_PREPARE_REQ = "c_prepare_req"                     -- 准备请求
MyGameConstants.C_OUTCARD_REQ = "c_outcard_req"                     -- 出牌请求
MyGameConstants.C_PIAO_REQ = "c_piao_req"                           -- 加飘请求
MyGameConstants.C_AUTO = "c_auto"                                   -- 托管请求

MyGameConstants.C_EAT_REQ = "c_eat_req"                             -- 吃请求
MyGameConstants.C_PENG_REQ = "c_peng_req"                           -- 碰请求
MyGameConstants.C_GANG_REQ = "c_gang_req"                           -- 杠请求
MyGameConstants.C_HU_REQ = "c_hu_req"                               -- 胡请求
MyGameConstants.C_PASS_REQ = "c_pass_req"                           -- 过请求
MyGameConstants.C_FRE_STARTGAME = "c_fre_startgame"                 -- 快速开始场开始游戏请求
MyGameConstants.C_ADVANCE = "c_advance"                             -- 录像快进请求
MyGameConstants.C_BACKWARD = "c_backward"                           -- 录像快退请求

MyGameConstants.C_PLAY_VIDEO = "c_play_video"                       -- 播放录像
MyGameConstants.C_RULES_OPEN = "c_rules_open"                       -- 玩法界面
MyGameConstants.C_SET_OPEN = "c_set_open"                           -- 设置界面
MyGameConstants.C_HELP_OPEN = "c_help_open"                         -- 帮助界面
MyGameConstants.C_UPDATE_TABLECLOTH = "c_update_tablecloth"         -- 刷新桌布
MyGameConstants.C_UPDATE_CARDBACK = "c_update_cardback"             -- 刷新牌背
MyGameConstants.C_MATCHCARD_OPEN = "c_matchcard_open"               -- 配牌器界面
MyGameConstants.C_GAME_INIT = "c_game_init"                         -- 游戏初始化
MyGameConstants.C_CLOSE_TINGCARDS = "c_close_tingcards"             -- 删除听牌层
MyGameConstants.C_SHOW_TINGCARDS = "c_show_tingcards"               -- 显示听哪些牌
MyGameConstants.C_SHOW_LOADING_ANIMATE = "c_show_loading_animate"   -- 显示加载动画
MyGameConstants.C_CLOSE_LOADING_ANIMATE = "c_close_loading_animate" -- 关闭加载动画
MyGameConstants.C_SHOW_RESULTTOTAL = "c_show_resulttotal"           -- 显示总结算界面
MyGameConstants.C_BUTTONPANEL_OPEN = "c_buttonpanel_open"           -- 打开按钮弹开界面
MyGameConstants.C_BUTTONPANEL_CLOSE = "c_buttonpanel_close"         -- 关闭按钮弹开界面
MyGameConstants.C_HANDCARD_INITPOS = "c_handcard_initpos"           -- 所有手牌初始位置
MyGameConstants.C_CLOSE_RESULT = "c_close_result"                   -- 删除游戏单局结算界面
MyGameConstants.C_SHOW_CURSAME_CARD = "c_show_cursame_card"         -- 显示当前牌桌面所有可见的牌颜色
MyGameConstants.C_CANCEL_CURSAME_CARD = "c_cancel_cursame_card"     -- 取消当前牌桌面所有可见的牌颜色

-----------------------------------------------------------
MyGameConstants.GAME_ID = 22000401                                  -- 游戏ID
MyGameConstants.PLAYER_COUNT = 4                                    -- 游戏人数
MyGameConstants.FIRST_LEFT_DIS = 90                                 -- 第一张牌距离左边的距离
MyGameConstants.CARD_POSITION_Y = 65                                -- 玩家手牌的初始Y位置  
MyGameConstants.CARD_POSITION_Y_UP = 105                            -- 点击牌玩家手牌的新的Y位置  
MyGameConstants.CARDS_DISTANCE = 80                                 -- 移动距离
MyGameConstants.SELECTED_COLOR = cc.c3b(123,215,245)                -- 鸟牌胡牌颜色
MyGameConstants.UNSELECTED_COLOR = cc.c3b(255, 255, 255)            -- 白色
MyGameConstants.IS_HAVE_TWO_MJZ_AUDIO = false                       -- 是否有两套麻将子的音效
MyGameConstants.IS_SHOW_CPG_FROM = true                             -- 是否显示吃碰杠标志
MyGameConstants.IS_SHOW_ANGANG_CARD = false                         -- 是否显示暗杠
MyGameConstants.IS_SHOW_CHECK_TING= true                            -- 是否显示查听
MyGameConstants.IS_SHOW_MATCH_CARD = true                           -- 是否显示配牌器

-- 游戏各层顺序
MyGameConstants.ORDER_DESK_INFO  = 1                                -- 桌子信息层
MyGameConstants.ORDER_PLAYER_INFO = 2                               -- 玩家信息层
MyGameConstants.ORDER_MENU = 3                                      -- 菜单层
MyGameConstants.ORDER_OUT_CARD = 4                                  -- 出牌层
MyGameConstants.ORDER_HAND_CARD = 5                                 -- 手牌层
MyGameConstants.ORDER_CHI_PENG_GANG = 6                             -- 吃碰杠动作层
MyGameConstants.ORDER_GAME_ANIMATE = 7                              -- 游戏动画层
MyGameConstants.ORDER_SETTING = 8                                   -- 设置层
MyGameConstants.ORDER_RULE = 9                                      -- 规则层
MyGameConstants.ORDER_RESULT = 10                                   -- 结算层
MyGameConstants.ORDER_TOTAL_RESULT = 11                             -- 总结算层
MyGameConstants.ORDER_MATCH = 12                                    -- 比赛层
MyGameConstants.ORDER_GAME_VIDEO = 100                              -- 录像层

-- 所有牌和桌布的颜色配置
MyGameConstants.COLOR_TYPES = {
    GREEN = 1,
    BLUE = 2,
    YELLOW = 3
} 

-- 每种颜色对应的麻将子和桌布的图片路径
MyGameConstants.COLOR_RES_PATH = {
    "ui_res/ColorPick/blue/",
    "ui_res/ColorPick/green/",
    "ui_res/ColorPick/yellow/"
}

MyGameConstants.GameStation = {
    GS_WAIT_SETGAME = 0,     -- 刚进房间等待状态
    GS_WAIT_PLAYING = 1,     -- 已开始状态
    GS_WAIT_NEXT_ROUND = 2   -- 等待下一回合状态

}
-- UI玩家方位 (上下左右)
MyGameConstants.Direct = {
    Down = 1,
    Right = 2,
    Up = 3,
    Left = 4
}

-- 表情显示位置
MyGameConstants.EMOJI_POSITIONS = {

    cc.p(80,245),
    cc.p(1185,420),
    cc.p(358,623),
    cc.p(80,493)

}

MyGameConstants.EMOJI_POSITIONS_NOTSTART = {

    cc.p(640,185),
    cc.p(1185,360),
    cc.p(640,623),
    cc.p(115,390)
}

-- 聊天显示位置
MyGameConstants.CHAT_POSITIONS = {
    cc.p(80 + 50,245),
    cc.p(1185 - 50,420),
    cc.p(358 + 50,623),
    cc.p(80 + 50,493)
}

MyGameConstants.CHAT_POSITIONS_NOTSTART = {
    cc.p(640 + 50,245),
    cc.p(1185 - 50,360),
    cc.p(640 + 50,623),
    cc.p(80 + 50,360)
}

-- 快捷聊天内容
MyGameConstants.CHAT_CONTENTS =
{
    "你太牛了",
    "哈哈,手气真好",
    "快点出牌啊",
    "今天真高兴",
    "这个吃得好",
    "你放炮，我不胡",
    "你家里是开银行的吧",
    "不好意思，我有事要先走一步啦",
    "你的牌打得太好啦",
    "大家好，很高兴见到各位",
    "怎么又断线啦，网络怎么这么差啦"
}

------------------------------------------------------------------

-- 动作标记
MyGameConstants.MJActFlag = {
    Guo  = 15,            --过
    Chi  = 16,            --吃
    Peng = 32,            --碰
    Gang = 48,            --杠
    DianGang = 49,        --点杠
    AnGang = 50,          --暗杠
    BuGang = 51,          --补杠
    Hu   = 64,            --胡
}

--吃的类型
MyGameConstants.EatType = {
    usT	= 1,			--吃头
    usZ	= 2,			--吃中
	usW	= 4,			--吃尾
	usTZ = 3,			--吃头 吃中
	usTW = 5,			--吃头 吃尾
	usZW = 6,			--吃中 吃尾
	usTZW = 7,			--吃头 吃中 吃尾
}

cc.exports.MyGameConstants = MyGameConstants