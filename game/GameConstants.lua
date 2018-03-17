local GameConstants = {}

GameConstants.START_GAME = "game_start"
GameConstants.SHOW_GAME = "game_show"
GameConstants.EXIT_GAME = "game_exit"
GameConstants.REMOVE_ELIMINATE="eliminate_remove"

GameConstants.START_REDDOT = "reddot_start"

GameConstants.START_TCP = "tcp_start"
GameConstants.SEND_SOCKET = "socket_send"
GameConstants.RECV_SOCKET = "socket_recv"
GameConstants.CONN_SOCKET = "socket_connect"
GameConstants.FAIL_SOCKET = "socket_fail"

GameConstants.REQUEST_VIDEOCREATE = "videocreate_request"
GameConstants.REQUEST_PRVCONNECT = "privateconnect_request"
GameConstants.REQUEST_PRVROOM = "privateroom_request"
GameConstants.REQUEST_PRVSIT = "privatesit_request"
GameConstants.REQUEST_PRVLEAVE = "privateleave_request"
GameConstants.REQUEST_PRVDISMISS = "privatedismiss_request"
GameConstants.REQUEST_STVOTE = "votestart_request"
GameConstants.REQUEST_VOTE = "vote_request"
GameConstants.REQUEST_ELIMINATE= "eliminate_request"
GameConstants.START_WAITRISE= "waitrise_start"
GameConstants.START_ELIMINATE= "eliminate_start"

GameConstants.REQUEST_QUKCONNECT = "quickconnect_request"
GameConstants.REQUEST_QUKQUEUE = "quickqueue_request"
GameConstants.REQUEST_QUKCACQUE = "quickcancelqueue_request"
GameConstants.REQUEST_QUKLEAVE = "quickleave_request"

GameConstants.REQUEST_FRECONNECT = "freeconnect_request"
GameConstants.REQUEST_FRESIT = "freesit_request"
GameConstants.REQUEST_FRELEAVE = "freeleave_request"

GameConstants.REQUEST_JOINCOMPETITION="joincompetitionlist_request"
GameConstants.REQUEST_QUITCOMPETITION="quitcompetitionlist_request"

GameConstants.UPDATE_USER = "user_update"
GameConstants.UPDATE_VOTE = "vote_update"
GameConstants.UPDATE_WAITINGRISE="waitingrise_update"
GameConstants.UPDATE_RANDING="ranking_update"



GameConstants.START_VOTE = "vote_start"
GameConstants.END_VOTE = "vote_end"

GameConstants.PENETRATE_MSG = "message_penetrate"

GameConstants.TEST_GAME = "game_test"

GameConstants.DOWNLOAD_HEAD = "head_download"

--消息相关
GameConstants.START_MESSAGE = "message_start"
GameConstants.CREATE_MSGBOX = "msgbox_create"		--创建消息对话框
GameConstants.UPDATE_MSGBOX = "msgbox_update"		--更新消息对话框
GameConstants.UPDATE_MSGBOX_EX = "msgbox_update_ex"		--扩展版更新消息对话框
GameConstants.CREATE_MSGBOXEX = "create_msgbox_ex"		--创建扩展功能的消息对话框
GameConstants.MSGBOX_CANCEL = "msgbox_cancel"		--点击取消按钮
GameConstants.MSGBOX_OK = "msgbox_ok"		--点击确定按钮
GameConstants.MSGBOX_KNOW = "msgbox_know"		--点击知道按钮

cc.exports.GameConstants = GameConstants