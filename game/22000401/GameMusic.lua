--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GameMusic = class("GameMusic")

--不区分男女方言相关
cc.exports.EffectEnum = {
    ANN     = "ann.mp3",
    WIN     = "win.mp3",
    LOSE    = "lose.mp3",
    KAIS    = "kais.mp3",
    PAOD    = "paod.mp3",
    DAOJS   = "daojs.mp3",
    LIK     = "lik.mp3",
    JIAR    = "jiar.mp3", 
    ZHUAP   = "zhuap.mp3",
    CHUP    = "chup.mp3",
    QIEP    = "qiep.mp3",
    SHOUP   = "shoup.mp3",
    DIANP   = "dianp.mp3",
    XIAOX   = "xiaox.mp3",
    TOUZ    = "touz.mp3",
}
-- 播放音效(根据男女方言)
function GameMusic:PlayEffect(effectname,server_chair)
    local filename = self:getEffectPath(server_chair)..effectname
    local isExit = cc.FileUtils:getInstance():isFileExist(filename)

    if isExit == true then
        print("GameMusic:PlayEffect")
        print("effect volume = " .. tostring(AudioEngine.getEffectsVolume()))
        AudioEngine.playEffect(filename, false)
    end
end

-- 播放背景音乐
function GameMusic:playBGM()
    print("GameMusic:playBGM")
    print("music volume = " .. tostring(AudioEngine.getMusicVolume()))
    AudioEngine.playMusic("sound/other/bgm.mp3", true)
end

-- 播放出牌音效 server_chair : 玩家的服务器椅子号
function GameMusic:PlayCardEffect(value,server_chair)
    if MyGameConstants.IS_HAVE_TWO_MJZ_AUDIO then
        if value < 0  then
            self:playOtherEffect(EffectEnum.CHUP,false)
        elseif value < 10 then
            self:PlayEffect("w_".. value%10 .."_".. tostring(math.random(2)) .. ".mp3",server_chair)
        elseif value < 20 then
            self:PlayEffect("s_".. value%10 .."_".. tostring(math.random(2)) .. ".mp3",server_chair)
        elseif value < 30 then
            self:PlayEffect("t_".. value%10 .."_".. tostring(math.random(2)) .. ".mp3",server_chair)
        elseif value < 38 then
            self:PlayEffect("f_".. value%10 .."_".. tostring(math.random(2)) .. ".mp3",server_chair)
        end
    else
        if value < 0  then
            self:playOtherEffect(EffectEnum.CHUP,false)
        elseif value < 10 then
            self:PlayEffect("w_".. value%10 ..".mp3",server_chair)
        elseif value < 20 then
            self:PlayEffect("s_".. value%10 ..".mp3",server_chair)
        elseif value < 30 then
            self:PlayEffect("t_".. value%10 ..".mp3",server_chair)
        elseif value < 38 then
            self:PlayEffect("f_".. value%10 ..".mp3",server_chair)
        end
    end

    
end

--播放出牌动作音效
function GameMusic:PlayActEffect(actFlag , server_chair)
    math.randomseed(os.time())
    local MyGameConstants = cc.exports.MyGameConstants
    if actFlag == MyGameConstants.MJActFlag.Guo then
        
    elseif actFlag == MyGameConstants.MJActFlag.Chi then
        self:PlayEffect("chi_" .. tostring(math.random(2)+1) .. ".mp3", server_chair)
    elseif actFlag == MyGameConstants.MJActFlag.Peng then
        self:PlayEffect("peng_" .. tostring(math.random(3)+1) .. ".mp3", server_chair)
    elseif actFlag == MyGameConstants.MJActFlag.DianGang or actFlag == MyGameConstants.MJActFlag.AnGang then
        self:PlayEffect("gang_" .. tostring(math.random(1)+1) .. ".mp3", server_chair)
    elseif actFlag == MyGameConstants.MJActFlag.BuGang then            
        self:PlayEffect("buz.mp3", server_chair)
    elseif actFlag == MyGameConstants.MJActFlag.Hu then
        self:PlayEffect("hu_" .. tostring(math.random(3)+1) .. ".mp3", server_chair)
    end
end

--播放自摸音效
function GameMusic:playZimoEffect(server_chair)
    self:PlayEffect("zim_" .. tostring(math.random(1)+1) .. ".mp3" , server_chair)
end

-- 播放点击音效
function GameMusic:playClickEffect()
    self:playOtherEffect("click.mp3",false)
end

--获取当前配置音效路径
function GameMusic:getEffectPath(server_chair)
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("DeskProxy"):getData()
    local player = data.player
    dump(player,"player")

    local iGender = player[server_chair] ~= nil and player[server_chair].gender or 1
    print(" iGender  == " .. tostring(iGender))
    local languageType = GameUtils:getInstance():getMJLanguageType()
    local path = ""
    if iGender == 1 then
        if languageType == 0 then
            path = "sound/putongnan/"
        else
            path = "sound/fangyannan/"
        end
    else
        if languageType == 0 then
            path = "sound/putongnv/"
        else
            path = "sound/fangyannv/"
        end
    end
    return path
end

----------------------------------------------------------------------

--播放其他音效
function GameMusic:playOtherEffect(effectname,isLoop)
    local filename = "sound/mjaudio/other/" .. effectname 
    AudioEngine.playEffect(effectname, isLoop)
end

--播放倒计时音效
function GameMusic:playCountdownEffect()
    local filename = "sound/other/daojs.mp3"
    -- self.sound_id = AudioEngine.playEffect(filename, true)

    local isExit = cc.FileUtils:getInstance():isFileExist(filename)
    if isExit == true then
        if UserData:getSound() == 1 then
            self.sound_id = AudioEngine.playEffect(filename, true)
            performWithDelay(GameSceneModule:getInstance():getGameScene(),
            function()
                self:stopCountdownEffect()
            end
            , 3
            )
        end
    else
        api_show_Msg_Box("音效不存在  " .. filename)
    end
end

--停止播放倒计时音效
function GameMusic:stopCountdownEffect()
    print("GameMusic:stopCountdownEffect")
    if self.sound_id ~= nil then
        
        AudioEngine.stopEffect(self.sound_id)
        self.sound_id = nil
    end
end

return GameMusic

