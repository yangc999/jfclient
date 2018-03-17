--region *.lua
--Date 2017/11/10
--yang

--启动初始化银行UI的命令
cc.exports.StartBankUICommand = import(".command.StartBankUICommand")

--启动输入银行密码UI 
cc.exports.StartInputPassUICommand = import(".command.StartInputPassUICommand")

--启动设置银行取款密码的命令
cc.exports.StartSetBankPassUICommand = import(".command.StartSetBankPassUICommand")

--启动修改银行取款密码的命令 RequestModifyBankPassCommand
cc.exports.StartModifyBankPassUICommand = import(".command.StartModifyBankPassUICommand")

--请求修改银行取款密码的命令 
cc.exports.RequestModifyBankPassCommand = import(".command.RequestModifyBankPassCommand")

--请求第一次设置银行取款密码的命令
cc.exports.RequestSetBankPassCommand = import(".command.RequestSetBankPassCommand")

--请求手机验证码的命令
cc.exports.RequestMobileCodeCommand = import(".command.RequestMobileCodeCommand")

--请求绑定手机号的命令
cc.exports.RequestBindMobileCommand = import(".command.RequestBindMobileCommand")

--开始显示绑定手机号UI的命令
cc.exports.StartBindMobileCommand = import(".command.StartBindMobileCommand")

--开始显示找回银行密码UI的命令
cc.exports.StartForgetBankPassUICommand = import(".command.StartForgetBankPassUICommand")

--请求用户财富信息的命令
cc.exports.RequestUserWealthChangeCommand = import(".command.RequestUserWealthChangeCommand")

--存钱进银行命令  
cc.exports.RequestSaveBankMoneyCommand = import(".command.RequestSaveBankMoneyCommand")

--从银行取钱的命令 
cc.exports.RequestDrawBankMoneyCommand = import(".command.RequestDrawBankMoneyCommand")

--请求用户信息完善情况 
cc.exports.RequestUserPerfectInfoCommand = import(".command.RequestUserPerfectInfoCommand")

--请求找回用户密码命令 
cc.exports.RequestForgetBankPassCommand = import(".command.RequestForgetBankPassCommand")

--endregion
