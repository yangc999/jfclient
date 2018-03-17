--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--初始化任务配置
cc.exports.StartTasksCommand = import(".command.StartTasksCommand")  --启动任务UI

cc.exports.RequestTaskShareConfigCommand = import(".command.RequestTaskShareConfigCommand") --请求任务配置

cc.exports.RequestTaskSharesCommand = import(".command.RequestTaskSharesCommand") --请求任务详细参数  

cc.exports.RequestGetTaskShareAwardCommand = import(".command.RequestGetTaskShareAwardCommand") --请求任务分享奖励
--endregion
