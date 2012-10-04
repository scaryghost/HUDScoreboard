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

function drawStats(Canvas canvas, int i, PlayerReplicationInfo KFHP, float YL, int PlayerBoxSizeY, int BoxSpaceY, int BoxTextOffsetY, int BoxXPos, int BoxWidth) {
    local float DeathsXL;

    super.drawStats(canvas, i, KFHP, YL, PlayerBoxSizeY, BoxSpaceY, BoxTextOFfsetY, BoxXPos, BoxWidth);

    canvas.DrawColor = HUDClass.default.WhiteColor;
    // draw cash
    canvas.SetPos(BoxXPos + 0.5 * BoxWidth, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
    canvas.DrawText("£"$int(KFHP.Score),true);

    // draw deaths
    Canvas.StrLen(DeathsText, DeathsXL, YL);
    Canvas.SetPos(BoxXPos + 0.375 * BoxWidth - 0.5 * DeathsXL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
    Canvas.DrawText(int(KFHP.Deaths),true);
}

defaultproperties {
    keyDataIndex= 1
}
