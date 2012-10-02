class ScoreboardInteractionBase extends Interaction
    abstract;

var() Material BoxMaterial;
var() localized string HealthText, DeathsText, AdminText, NetText, KillsText, PlayerText, PingText, PLText, ReadyText, NotReadyText, FPH, TimeLimit, FooterText, Restart, PointsText;
var() class<HUD> HUDClass;
var localized string OutText, HealthyString, InjuredString, CriticalString, MatchIDText, WaveString, OutFireText;
var bool bDisplayWithKills;
var PlayerReplicationInfo PRIArray[32];
var float FPHTime;
var localized string        SkillLevel[8];
var int keyDataIndex;

event NotifyLevelChange() {
    Master.RemoveInteraction(self);
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta ) {
    local string alias;

    alias= ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));
    if (Action == IST_Press || Action == IST_Hold) {
        if (alias == class'HSBKeyBinding'.default.KeyData[keyDataIndex].Alias) {
            bVisible= true;
        }
    } else if (Action == IST_Release) {
        if (alias == class'HSBKeyBinding'.default.KeyData[keyDataIndex].Alias) {
            bVisible= false;
        }
    }
 
    return false;
}


function String FormatTime(int Seconds) {
    local int Minutes, Hours;
    local String Time;

    if( Seconds > 3600 ) {
        Hours = Seconds / 3600;
        Seconds -= Hours * 3600;

        Time = Hours$":";
    }
    Minutes = Seconds / 60;
    Seconds -= Minutes * 60;

    if( Minutes >= 10 )
        Time = Time $ Minutes $ ":";
    else
        Time = Time $ "0" $ Minutes $ ":";

    if( Seconds >= 10 )
        Time = Time $ Seconds;
    else
        Time = Time $ "0" $ Seconds;

    return Time;
}

function DrawTitle(Canvas Canvas, float HeaderOffsetY, float PlayerAreaY, float PlayerBoxSizeY) {
    local string TitleString, ScoreInfoString, RestartString;
    local float TitleXL, ScoreInfoXL, YL, TitleY, TitleYL;

    TitleString = SkillLevel[Clamp(InvasionGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo).BaseDifficulty, 0, 7)] @ "|" @ WaveString @ (InvasionGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo).WaveNumber + 1) @ "|" @ ViewportOwner.Actor.GetEntryLevel().Title;

    Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);

    Canvas.StrLen(TitleString, TitleXL, TitleYL);

    if ( ViewportOwner.Actor.GameReplicationInfo.TimeLimit != 0 ) {
        ScoreInfoString = TimeLimit $ FormatTime(ViewportOwner.Actor.GameReplicationInfo.RemainingTime);
    }
    else {
        ScoreInfoString = FooterText @ FormatTime(ViewportOwner.Actor.GameReplicationInfo.ElapsedTime);
    }

    Canvas.DrawColor = HUDClass.default.RedColor;

    if ( UnrealPlayer(ViewportOwner.Actor).bDisplayLoser ) {
        ScoreInfoString = class'HUDBase'.default.YouveLostTheMatch;
    }
    else if ( UnrealPlayer(ViewportOwner.Actor).bDisplayWinner ) {
        ScoreInfoString = class'HUDBase'.default.YouveWonTheMatch;
    }
    else if (ViewportOwner.Actor.IsDead()) {
        RestartString = Restart;

        if (ViewportOwner.Actor.PlayerReplicationInfo.bOutOfLives ) {
            RestartString = OutFireText;
        }

        ScoreInfoString = RestartString;
    }

    TitleY = Canvas.ClipY * 0.13;
    Canvas.SetPos(0.5 * (Canvas.ClipX - TitleXL), TitleY);
    Canvas.DrawText(TitleString);

    Canvas.StrLen(ScoreInfoString, ScoreInfoXL, YL);
    Canvas.SetPos(0.5 * (Canvas.ClipX - ScoreInfoXL), TitleY + TitleYL);
    Canvas.DrawText(ScoreInfoString);
}

function Font GetSmallFontFor(int ScreenWidth, int offset) {
    local int i;

    for ( i=0; i<8-offset; i++ ) {
        if ( HUDClass.default.FontScreenWidthSmall[i] <= ScreenWidth )
            return HUDClass.static.LoadFontStatic(i+offset);
    }
    return HUDClass.static.LoadFontStatic(8);
}

function Font GetSmallerFontFor(Canvas Canvas, int offset) {
    local int i;

    for ( i=0; i<8-offset; i++ ) {
        if ( HUDClass.default.FontScreenWidthMedium[i] <= Canvas.ClipX )
            return HUDClass.static.LoadFontStatic(i+offset);
    }
    return HUDClass.static.LoadFontStatic(8);
}

function DrawMatchID(Canvas Canvas,int FontReduction) {
    local float XL,YL;

    if ( ViewportOwner.Actor.GameReplicationInfo.MatchID != 0 ) {
        Canvas.Font = GetSmallFontFor(1.5*Canvas.ClipX, FontReduction+1);
        Canvas.StrLen(MatchIDText@ViewportOwner.Actor.GameReplicationInfo.MatchID, XL, YL);
        Canvas.SetPos(Canvas.ClipX - XL - 4, 4);
        Canvas.DrawText(MatchIDText@ViewportOwner.Actor.GameReplicationInfo.MatchID,true);
    }
}

function DrawNetInfo(Canvas Canvas,int FontReduction,int HeaderOffsetY,int PlayerBoxSizeY,int BoxSpaceY,int BoxTextOffsetY,int OwnerOffset,int PlayerCount, int NetXPos) {
    local float XL,YL;
    local int i;
    local bool bHaveHalfFont, bDrawFPH, bDrawPL;

    bDrawPL = false;
    bDrawFPH = false;
    bHaveHalfFont = false;

    // draw admins
    if ( ViewportOwner.Actor.GameReplicationInfo.bMatchHasBegun ) {
        Canvas.DrawColor = HUDClass.default.RedColor;

        for ( i = 0; i < PlayerCount; i++ )
            if ( PRIArray[i].bAdmin ) {
                Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
                Canvas.DrawText(AdminText,true);
            }
        if ( (OwnerOffset >= PlayerCount) && PRIArray[OwnerOffset].bAdmin )  {
            Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY) * PlayerCount + BoxTextOffsetY);
            Canvas.DrawText(AdminText,true);
        }
    }

    Canvas.DrawColor = HUDClass.default.WhiteColor;
    //Canvas.Font = GetSmallFontFor(Canvas.ClipX, FontReduction);
    Canvas.StrLen("Test", XL, YL);
    BoxTextOffsetY = HeaderOffsetY + 0.5*PlayerBoxSizeY;
    //bHaveHalfFont = ( YL < 0.5 * PlayerBoxSizeY);

    // if game hasn't begun, draw ready or not ready
    if ( !ViewportOwner.Actor.GameReplicationInfo.bMatchHasBegun ) {
        //bDrawPL = PlayerBoxSizeY > 3 * YL;
        for ( i=0;  i < PlayerCount; i++ ) {
            if ( bDrawPL ) {
                Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
                Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
                Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
                Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
                Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
            }
            else if ( bHaveHalfFont ) {
                Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
                Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
                Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
            }
            else
                Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
            if ( PRIArray[i].bReadyToPlay )
                Canvas.DrawText(ReadyText,true);
            else
                Canvas.DrawText(NotReadyText,true);
        }
        return;
    }

    // draw time and ping
    if ( Canvas.ClipX < 512 )
        PingText = "";
    else {
        PingText = Default.PingText;
        //bDrawFPH = PlayerBoxSizeY > 3 * YL;
        //bDrawPL = PlayerBoxSizeY > 4 * YL;
    }
    if ( ((FPHTime == 0) || (!UnrealPlayer(ViewportOwner.Actor).bDisplayLoser && !UnrealPlayer(ViewportOwner.Actor).bDisplayWinner))
        && (ViewportOwner.Actor.GameReplicationInfo.ElapsedTime > 0) )
        FPHTime = ViewportOwner.Actor.GameReplicationInfo.ElapsedTime;

    for ( i = 0; i < PlayerCount; i++ )
        if ( !PRIArray[i].bAdmin && !PRIArray[i].bOutOfLives ) {
                if ( bDrawPL ) {
                    Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.9 * YL);
                    Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
                    Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.9 * YL);
                    Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
                    Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.1 * YL);
                    Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
                    Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 1.1 * YL);
                    Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
                }
                else if ( bDrawFPH ) {
                    Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
                    Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
                    Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
                    Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
                    Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
                    Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
                }
                else if ( bHaveHalfFont ) {
                    Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
                    Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
                    Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
                    Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
                }
                else {
                    Canvas.StrLen(Min(999, 4 * PRIArray[i].Ping), XL, YL);
                    Canvas.SetPos(NetXPos - 0.5 * xL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
                    Canvas.DrawText(Min(999,4*PRIArray[i].Ping),true);
                }
            }
    if ( (OwnerOffset >= PlayerCount) && !PRIArray[OwnerOffset].bAdmin && !PRIArray[OwnerOffset].bOutOfLives ) {
        if ( bDrawFPH ) {
            Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
            Canvas.DrawText(PingText@Min(999,4*PRIArray[OwnerOffset].Ping),true);
            Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
            Canvas.DrawText(FPH@Min(999,3600*PRIArray[OwnerOffset].Score/FMax(1,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
            Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
            Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
        }
        else if ( bHaveHalfFont ) {
            Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
            Canvas.DrawText(PingText@Min(999,4*PRIArray[OwnerOffset].Ping),true);
            Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
            Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
        }
        else {
            Canvas.StrLen(Min(999, 4 * PRIArray[i].Ping), XL, YL);
            Canvas.SetPos(NetXPos - 0.5 * XL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
            Canvas.DrawText(Min(999,4*PRIArray[OwnerOffset].Ping), true);
        }
    }
}

defaultproperties {
    bActive= true

    BoxMaterial=Material'InterfaceArt_tex.Menu.DownTickBlurry'
    HealthText= "Status"
    KillsText= "Kills"
    NetText= "PING"
    AdminText= "ADMIN"
    DeathsText= "DEATHS"
    PlayerText= "PLAYER"
    OutText= "DEAD"
    PointsText="CASH"
    bDisplayWithKills= true
    HealthyString= "HEALTHY"
    InjuredString= "INJURED"
    Criticalstring= "CRITICAL"
    PingText= "PING:"
    PLText= "P/L:"
    ReadyText= "READY"
    NotReadyText= "NOT RDY"
    FPH= "PPH"
    MatchIDText="Killing Floor Stats Match ID"
    WaveString= "Wave"

    SkillLevel(1)="Beginner"
    SkillLevel(2)="Normal"
    SkillLevel(4)="Hard"
    SkillLevel(5)="Suicidal"
    SkillLevel(7)="Hell on Earth"

    TimeLimit= "REMAINING TIME:"
    FooterText= "Elapsed Time:"
    Restart= "   You were killed. Press Fire to respawn!"
    OutFireText= "   You are OUT. Fire to view other players."

    HUDClass= class'ROHud'
}
