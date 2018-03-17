--region *.lua
--Date
--幸运转盘的init

--初始化显示抽奖UI
cc.exports.StartLotteryCommand = import(".command.StartLotteryCommand")

--请求抽奖奖品列表
cc.exports.RequestLotteryListCommand = import(".command.RequestLotteryListCommand")

--用户请求抽奖的命令
cc.exports.RequestDrawLotteryCommand = import(".command.RequestDrawLotteryCommand")

--请求用户自己的抽奖列表命令  
cc.exports.RequestListUserCommand = import(".command.RequestListUserCommand")

--请求全部用户的抽奖列表命令 
cc.exports.RequestListTotalCommand = import(".command.RequestListTotalCommand")
--请求启动绑定手机号UI命令 
cc.exports.StartBandPhoneCommand = import(".command.StartBandPhoneCommand")

--启动抽奖中奖页面
cc.exports.StartGiftAnimCommand = import(".command.StartGiftAnimCommand")
--endregion
