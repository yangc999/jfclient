--region *.lua
--Date
--战绩的命令

cc.exports.StartMatchRecordsCommand = import(".command.StartMatchRecordsCommand")  --初始化显示战绩UI

cc.exports.StartMatchRecordDetailCommand = import(".command.StartMatchRecordDetailCommand")  --初始化显示详细战绩UI

cc.exports.RequestRecordsNumCommand = import(".command.RequestRecordsNumCommand") --请求战绩总数

cc.exports.RequestRecordListCommand = import(".command.RequestRecordListCommand") --请求战绩纪录列表

cc.exports.RequestRecordDetailCommand = import(".command.RequestRecordDetailCommand") --请求私人房战局详细纪录列表

cc.exports.RequestVideoUrlComman = import(".command.RequestVideoUrlComman") --请求录像回放地址

cc.exports.DownloadWatchVideoCommand = import(".command.DownloadWatchVideoCommand") --下载录像回放资源
--endregion
