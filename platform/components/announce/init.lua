--region *.lua
--Date 2017、11、7
--yangyisong
--每天第一次显示公告
cc.exports.StartFirstShowAnnounceCommand = import(".command.StartFirstShowAnnounceCommand")

--启动公告UI的命令
cc.exports.StartAnnounceListCommand = import(".command.StartAnnounceListCommand")

--请求公告列表的命令
cc.exports.RequestAnnounceListCommand = import(".command.RequestAnnounceListCommand")

--根据某个公告ID获取公告正文的命令
cc.exports.RequestAnnounceByIDCommand = import(".command.RequestAnnounceByIDCommand")
--endregion
