class ScoreboardOne extends ScoreboardInteractionBase;

function drawHeaders(Canvas canvas, float YL, int BoxXPos, int BoxWidth, int TitleYPos) {
    local float ScoreXL, DeathsXL;
    super.drawHeaders(canvas, YL, BoxXPos, BoxWidth, TitleYPos);

    Canvas.StrLen(DeathsText, DeathsXL, YL);
    canvas.SetPos(BoxXPos + 0.5 * BoxWidth - 0.5*ScoreXL, TitleYPos);
    canvas.DrawText(PointsText,true);
    canvas.SetPos(BoxXPos + 0.375 * BoxWidth - 0.5*DeathsXL, TitleYPos);
    canvas.DrawText(DeathsText,true);
    
}

function drawStats(Canvas canvas, int i, KFHumanPawn KFHP, float YL, int PlayerBoxSizeY, int BoxSpaceY, int BoxTextOffsetY, int BoxXPos, int BoxWidth) {
    canvas.DrawColor = HUDClass.default.WhiteColor;
    canvas.StrLen(KFPlayerReplicationInfo(KFHP.PlayerReplicationInfo).Kills, KillWidthX, YL);
    canvas.SetPos(BoxXPos + 0.60 * BoxWidth - 0.5 * KillWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
    canvas.DrawText(KFPlayerReplicationInfo(KFHP.PlayerReplicationInfo).Kills, true);

    // draw cash
    canvas.SetPos(BoxXPos + 0.5 * BoxWidth, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
    canvas.DrawText("£"$int(KFHP.PlayerReplicationInfo.Score),true);


    // draw deaths
    Canvas.SetPos(BoxXPos + 0.375 * BoxWidth, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
    Canvas.DrawText(int(KFHP.PlayerReplicationInfo.Deaths),true);

    // draw healths
    Canvas.SetPos(BoxXPos + 0.75 * BoxWidth - 0.5 * HealthWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);

    if ( KFHP.PlayerReplicationInfo.bOutOfLives ) {
        Canvas.DrawColor = HUDClass.default.RedColor;
        Canvas.DrawText(OutText,true);
    } else {
        if( KFPlayerReplicationInfo(KFHP.PlayerReplicationInfo).PlayerHealth>=95 ) {
            Canvas.DrawColor= HUDClass.default.GreenColor;
            Canvas.DrawText(HealthyString,true);
        }
        else if( KFPlayerReplicationInfo(KFHP.PlayerReplicationInfo).PlayerHealth>=50 ) {
            Canvas.DrawColor= HUDClass.default.GoldColor;
            Canvas.DrawText(InjuredString,true);
        }
        else {
            Canvas.DrawColor= HUDClass.default.RedColor;
            Canvas.DrawText(CriticalString,true);
        }
    }

}

defaultproperties {
    keyDataIndex= 1
}
