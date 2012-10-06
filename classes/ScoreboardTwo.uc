class ScoreboardTwo extends ScoreboardInteractionBase;

var() localized string timeText;
function drawHeaders(Canvas canvas, float YL, int BoxXPos, int BoxWidth, int TitleYPos) {
    local float timeXL;
    super.drawHeaders(canvas, YL, BoxXPos, BoxWidth, TitleYPos);

    Canvas.StrLen(timeText, timeXL, YL);
    canvas.SetPos(BoxXPos + 0.425 * BoxWidth - 0.5*timeXL, TitleYPos);
    canvas.DrawText(timeText, true);
}

function drawStats(Canvas canvas, int i, PlayerReplicationInfo pri, float YL, int PlayerBoxSizeY, int BoxSpaceY, int BoxTextOffsetY, int BoxXPos, int BoxWidth) {
    super.drawStats(canvas, i, pri, YL, PlayerBoxSizeY, BoxSpaceY, BoxTextOFfsetY, BoxXPos, BoxWidth);
    canvas.DrawColor = HUDClass.default.WhiteColor;
    canvas.SetPos(BoxXPos + 0.425 * BoxWidth, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
    canvas.DrawText(FormatTime(ViewportOwner.Actor.GameReplicationInfo.ElapsedTime - pri.StartTime),true);
}

defaultproperties {
    keyDataIndex= 2
    timeText= "Time"
}
