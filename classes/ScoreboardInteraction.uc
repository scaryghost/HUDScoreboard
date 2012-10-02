class ScoreboardInteraction extends Interaction;

var() Material BoxMaterial;
var() localized string HealthText, DeathsText, AdminText, NetText, KillsText, PlayerText, PingText, PLText, ReadyText, NotReadyText, FPH, TimeLimit, FooterText, Restart;
var localized string OutText, HealthyString, InjuredString, CriticalString, MatchIDText, WaveString, OutFireText;
var bool bDisplayWithKills;
var PlayerReplicationInfo PRIArray[32];
var float FPHTime;
var localized string		SkillLevel[8];

event NotifyLevelChange() {
    Master.RemoveInteraction(self);
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta ) {
    local string alias;

    alias= ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));
    if (Action == IST_Press || Action == IST_Hold) {
        if (alias == class'HSBKeyBinding'.default.KeyData[1].Alias) {
            bVisible= true;
        }
    } else if (Action == IST_Release) {
        if (alias == class'HSBKeyBinding'.default.KeyData[1].Alias) {
            bVisible= false;
        }
    }
 
    return false;
}

function String FormatTime( int Seconds )
{
    local int Minutes, Hours;
    local String Time;

    if( Seconds > 3600 )
    {
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

    Canvas.DrawColor = class'ROHud'.default.RedColor;

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

function Font GetSmallFontFor(int ScreenWidth, int offset)
{
	local int i;

	for ( i=0; i<8-offset; i++ )
	{
		if ( class'ROHud'.default.FontScreenWidthSmall[i] <= ScreenWidth )
			return class'ROHud'.static.LoadFontStatic(i+offset);
	}
	return class'ROHud'.static.LoadFontStatic(8);
}

function Font GetSmallerFontFor(Canvas Canvas, int offset) {
    local int i;

    for ( i=0; i<8-offset; i++ ) {
        if ( class'ROHud'.default.FontScreenWidthMedium[i] <= Canvas.ClipX )
            return class'ROHud'.static.LoadFontStatic(i+offset);
    }
    return class'ROHud'.static.LoadFontStatic(8);
}

function PostRender(Canvas canvas) {
    local PlayerReplicationInfo PRI, OwnerPRI;
    local int i, FontReduction, NetXPos, PlayerCount, HeaderOffsetY, HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, OwnerOffset, HealthXPos, BoxXPos,KillsXPos, TitleYPos, BoxWidth, VetXPos;
    local float XL,YL, MaxScaling;
    local float deathsXL, KillsXL, netXL,HealthXL, MaxNamePos, KillWidthX, HealthWidthX;
    local bool bNameFontReduction;
    local Material VeterancyBox;

    OwnerPRI = ViewportOwner.Actor.PlayerReplicationInfo;
    OwnerOffset = -1;

    for ( i = 0; i < ViewportOwner.Actor.GameReplicationInfo.PRIArray.Length; i++) {
        PRI = ViewportOwner.Actor.GameReplicationInfo.PRIArray[i];

        if ( !PRI.bOnlySpectator ) {
            if ( PRI == OwnerPRI ) {
                OwnerOffset = i;
            }

            PlayerCount++;
        }
    }

    PlayerCount = Min(PlayerCount, 32);

    // Select best font size and box size to fit as many players as possible on screen
    Canvas.Font = class'ROHud'.static.GetSmallMenuFont(Canvas);
    Canvas.StrLen("Test", XL, YL);
    BoxSpaceY = 0.25 * YL;
    PlayerBoxSizeY = 1.2 * YL;
    HeadFoot = 7 * YL;
    MessageFoot = 1.5 * HeadFoot;

    if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) ) {
        BoxSpaceY = 0.125 * YL;
        PlayerBoxSizeY = 1.25 * YL;

        if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) ) {
            if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) ) {
                PlayerBoxSizeY = 1.125 * YL;
            }
        }
    }

    if ( Canvas.ClipX < 512 ) {
        PlayerCount = Min(PlayerCount, 1+(Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) );
    }
    else {
        PlayerCount = Min(PlayerCount, (Canvas.ClipY - HeadFoot) / (PlayerBoxSizeY + BoxSpaceY) );
    }

    if ( FontReduction > 2 ) {
        MaxScaling = 3;
    }
    else {
        MaxScaling = 2.125;
    }

    PlayerBoxSizeY = FClamp((1.25 + (Canvas.ClipY - 0.67 * MessageFoot)) / PlayerCount - BoxSpaceY, PlayerBoxSizeY, MaxScaling * YL);

//    bDisplayMessages = (PlayerCount <= (Canvas.ClipY - MessageFoot) / (PlayerBoxSizeY + BoxSpaceY));

    HeaderOffsetY = 10 * YL;
    BoxWidth = 0.7 * Canvas.ClipX;
    BoxXPos = 0.5 * (Canvas.ClipX - BoxWidth);
    BoxWidth = Canvas.ClipX - 2 * BoxXPos;
    VetXPos = BoxXPos + 0.0001 * BoxWidth;
    NameXPos = BoxXPos + 0.08 * BoxWidth;
    KillsXPos = BoxXPos + 0.60 * BoxWidth;
    HealthXpos = BoxXPos + 0.75 * BoxWidth;
    NetXPos = BoxXPos + 0.90 * BoxWidth;

    // draw background boxes
    Canvas.Style = ViewportOwner.Actor.ERenderStyle.STY_Alpha;
    Canvas.DrawColor = class'ROHud'.default.WhiteColor;
    Canvas.DrawColor.A = 128;

    for ( i = 0; i < PlayerCount; i++ ) {
        Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY) * i);
        Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
    }

    // draw title
    Canvas.Style = ViewportOwner.Actor.ERenderStyle.STY_Normal;
    DrawTitle(Canvas, HeaderOffsetY, (PlayerCount + 1) * (PlayerBoxSizeY + BoxSpaceY), PlayerBoxSizeY);

    // Draw headers
    TitleYPos = HeaderOffsetY - 1.1 * YL;
    Canvas.StrLen(HealthText, HealthXL, YL);
    Canvas.StrLen(DeathsText, DeathsXL, YL);
    Canvas.StrLen(KillsText, KillsXL, YL);
    Canvas.StrLen("INJURED", HealthWidthX, YL);

    Canvas.DrawColor = class'ROHud'.default.WhiteColor;
    Canvas.SetPos(NameXPos, TitleYPos);
    Canvas.DrawText(PlayerText,true);

    if( bDisplayWithKills ) {
        Canvas.SetPos(KillsXPos - 0.5 * KillsXL, TitleYPos);
        Canvas.DrawText(KillsText,true);
    }

    Canvas.SetPos(HealthXPos - 0.5 * HealthXL, TitleYPos);
    Canvas.DrawText(HealthText,true);

    // draw player names
    MaxNamePos = 0.9 * (KillsXPos - NameXPos);

    for ( i = 0; i < PlayerCount; i++ ) {
        Canvas.StrLen(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i].PlayerName, XL, YL);

        if ( XL > MaxNamePos ) {
            bNameFontReduction = true;
            break;
        }
    }

    if ( bNameFontReduction ) {
        Canvas.Font = GetSmallerFontFor(Canvas, FontReduction + 1);
    }

    Canvas.Style = ViewportOwner.Actor.ERenderStyle.STY_Normal;
    Canvas.DrawColor = class'ROHud'.default.WhiteColor;
    Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);
    BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

    Canvas.DrawColor = class'ROHud'.default.WhiteColor;
    MaxNamePos = Canvas.ClipX;
    Canvas.ClipX = KillsXPos - 4.f;

    for ( i = 0; i < PlayerCount; i++ ) {
        Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);

        if( i == OwnerOffset )
        {
            Canvas.DrawColor.G = 0;
            Canvas.DrawColor.B = 0;
        }
        else
        {
            Canvas.DrawColor.G = 255;
            Canvas.DrawColor.B = 255;
        }

        Canvas.DrawTextClipped(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i].PlayerName);
    }

    Canvas.ClipX = MaxNamePos;
    Canvas.DrawColor = class'ROHud'.default.WhiteColor;

    if ( bNameFontReduction ) {
        Canvas.Font = GetSmallerFontFor(Canvas, FontReduction);
    }

    Canvas.Style = ViewportOwner.Actor.ERenderStyle.STY_Normal;
    MaxScaling = FMax(PlayerBoxSizeY,30.f);

    // Draw the player informations.
    for ( i = 0; i < PlayerCount; i++ ) {
        Canvas.DrawColor = class'ROHud'.default.WhiteColor;

        // Display perks.
        if ( KFPlayerReplicationInfo(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i])!=None && KFPlayerReplicationInfo(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i]).ClientVeteranSkill != none ) {
            VeterancyBox = KFPlayerReplicationInfo(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i]).ClientVeteranSkill.default.OnHUDIcon;

            if ( VeterancyBox != None ) {
                Canvas.SetPos(VetXPos, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY - PlayerBoxSizeY * 0.22);
                Canvas.DrawTile(VeterancyBox, PlayerBoxSizeY, PlayerBoxSizeY, 0, 0, VeterancyBox.MaterialUSize(), VeterancyBox.MaterialVSize());
            }
        }

        // draw kills
        if( bDisplayWithKills ) {
            Canvas.StrLen(KFPlayerReplicationInfo(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i]).Kills, KillWidthX, YL);
            Canvas.SetPos(KillsXPos - 0.5 * KillWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
            Canvas.DrawText(KFPlayerReplicationInfo(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i]).Kills, true);
        }

        // draw cash
        //Canvas.SetPos(ScoreXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
        //Canvas.DrawText(int(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i].Score),true);

        // draw healths
        Canvas.SetPos(HealthXpos - 0.5 * HealthWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);

        if ( ViewportOwner.Actor.GameReplicationInfo.PRIArray[i].bOutOfLives ) {
            Canvas.DrawColor = class'ROHud'.default.RedColor;
            Canvas.DrawText(OutText,true);
        }
        else {
            if( KFPlayerReplicationInfo(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i]).PlayerHealth>=95 ) {
                Canvas.DrawColor = class'ROHud'.default.GreenColor;
                Canvas.DrawText(HealthyString,true);
            }
            else if( KFPlayerReplicationInfo(ViewportOwner.Actor.GameReplicationInfo.PRIArray[i]).PlayerHealth>=50 ) {
                Canvas.DrawColor = class'ROHud'.default.GoldColor;
                Canvas.DrawText(InjuredString,true);
            }
            else {
                Canvas.DrawColor = class'ROHud'.default.RedColor;
                Canvas.DrawText(CriticalString,true);
            }
        }
    }

    if ( ViewportOwner.Actor.GetEntryLevel().NetMode == NM_Standalone )
        return;

    Canvas.StrLen(NetText, NetXL, YL);
    Canvas.DrawColor = class'ROHud'.default.WhiteColor;
    Canvas.SetPos(NetXPos - 0.5 * NetXL, TitleYPos);
    Canvas.DrawText(NetText,true);

    for ( i=0; i<ViewportOwner.Actor.GameReplicationInfo.PRIArray.Length; i++ ) {
        PRIArray[i] = ViewportOwner.Actor.GameReplicationInfo.PRIArray[i];
    }

    DrawNetInfo(Canvas, FontReduction, HeaderOffsetY, PlayerBoxSizeY, BoxSpaceY, BoxTextOffsetY, OwnerOffset, PlayerCount, NetXPos);
    DrawMatchID(Canvas, FontReduction);
}

function DrawMatchID(Canvas Canvas,int FontReduction)
{
	local float XL,YL;

	if ( ViewportOwner.Actor.GameReplicationInfo.MatchID != 0 )
	{
		Canvas.Font = GetSmallFontFor(1.5*Canvas.ClipX, FontReduction+1);
		Canvas.StrLen(MatchIDText@ViewportOwner.Actor.GameReplicationInfo.MatchID, XL, YL);
		Canvas.SetPos(Canvas.ClipX - XL - 4, 4);
		Canvas.DrawText(MatchIDText@ViewportOwner.Actor.GameReplicationInfo.MatchID,true);
	}
}

function DrawNetInfo(Canvas Canvas,int FontReduction,int HeaderOffsetY,int PlayerBoxSizeY,int BoxSpaceY,int BoxTextOffsetY,int OwnerOffset,int PlayerCount, int NetXPos)
{
	local float XL,YL;
	local int i;
	local bool bHaveHalfFont, bDrawFPH, bDrawPL;

	bDrawPL = false;
	bDrawFPH = false;
	bHaveHalfFont = false;

	// draw admins
	if ( ViewportOwner.Actor.GameReplicationInfo.bMatchHasBegun )
	{
		Canvas.DrawColor = class'ROHud'.default.RedColor;

		for ( i = 0; i < PlayerCount; i++ )
			if ( PRIArray[i].bAdmin )
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(AdminText,true);
				}
		if ( (OwnerOffset >= PlayerCount) && PRIArray[OwnerOffset].bAdmin )
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY) * PlayerCount + BoxTextOffsetY);
			Canvas.DrawText(AdminText,true);
		}
	}

	Canvas.DrawColor = class'ROHud'.default.WhiteColor;
	//Canvas.Font = GetSmallFontFor(Canvas.ClipX, FontReduction);
	Canvas.StrLen("Test", XL, YL);
	BoxTextOffsetY = HeaderOffsetY + 0.5*PlayerBoxSizeY;
	//bHaveHalfFont = ( YL < 0.5 * PlayerBoxSizeY);

	// if game hasn't begun, draw ready or not ready
	if ( !ViewportOwner.Actor.GameReplicationInfo.bMatchHasBegun )
	{
		//bDrawPL = PlayerBoxSizeY > 3 * YL;
		for ( i=0;  i < PlayerCount; i++ )
		{
			if ( bDrawPL )
			{
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
				Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
				Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
				Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
			}
			else if ( bHaveHalfFont )
			{
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
	else
	{
		PingText = Default.PingText;
		//bDrawFPH = PlayerBoxSizeY > 3 * YL;
		//bDrawPL = PlayerBoxSizeY > 4 * YL;
	}
	if ( ((FPHTime == 0) || (!UnrealPlayer(ViewportOwner.Actor).bDisplayLoser && !UnrealPlayer(ViewportOwner.Actor).bDisplayWinner))
		&& (ViewportOwner.Actor.GameReplicationInfo.ElapsedTime > 0) )
		FPHTime = ViewportOwner.Actor.GameReplicationInfo.ElapsedTime;

	for ( i = 0; i < PlayerCount; i++ )
		if ( !PRIArray[i].bAdmin && !PRIArray[i].bOutOfLives )
 			{
 				if ( bDrawPL )
 				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.9 * YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.9 * YL);
					Canvas.DrawText(PLText@PRIArray[i].PacketLoss,true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.1 * YL);
					Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 1.1 * YL);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}
 				else if ( bDrawFPH )
 				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
					Canvas.DrawText(FPH@Clamp(3600*PRIArray[i].Score/FMax(1,FPHTime - PRIArray[i].StartTime),-999,9999),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}
				else if ( bHaveHalfFont )
				{
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
					Canvas.DrawText(PingText@Min(999,4*PRIArray[i].Ping),true);
					Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
					Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[i].StartTime)),true);
				}
				else
				{
					Canvas.StrLen(Min(999, 4 * PRIArray[i].Ping), XL, YL);
					Canvas.SetPos(NetXPos - 0.5 * xL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5*YL);
					Canvas.DrawText(Min(999,4*PRIArray[i].Ping),true);
				}
			}
	if ( (OwnerOffset >= PlayerCount) && !PRIArray[OwnerOffset].bAdmin && !PRIArray[OwnerOffset].bOutOfLives )
	{
 		if ( bDrawFPH )
 		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 1.5 * YL);
			Canvas.DrawText(PingText@Min(999,4*PRIArray[OwnerOffset].Ping),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - 0.5 * YL);
			Canvas.DrawText(FPH@Min(999,3600*PRIArray[OwnerOffset].Score/FMax(1,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY + 0.5 * YL);
			Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
		}
		else if ( bHaveHalfFont )
		{
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY - YL);
			Canvas.DrawText(PingText@Min(999,4*PRIArray[OwnerOffset].Ping),true);
			Canvas.SetPos(NetXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawText(FormatTime(Max(0,FPHTime - PRIArray[OwnerOffset].StartTime)),true);
		}
		else
		{
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
    OutText= "OUT"
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
}
