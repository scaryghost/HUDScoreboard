class ScoreboardTwo extends ScoreboardInteractionBase;

var() localized string TimeText, CharText;
function drawHeaders(Canvas canvas, float YL, int BoxXPos, int BoxWidth, int TitleYPos) {
    local float timeXL, charXL;
    super.drawHeaders(canvas, YL, BoxXPos, BoxWidth, TitleYPos);

    Canvas.StrLen(CharText, charXL, YL);
    canvas.SetPos(BoxXPos + 0.5 * BoxWidth - 0.5*timeXL, TitleYPos);
    canvas.DrawText(TimeText, true);
    canvas.SetPos(BoxXPos + 0.375 * BoxWidth - 0.5*charXL, TitleYPos);
    canvas.DrawText(CharText,true);
    
}

function drawStats(Canvas canvas, int i, PlayerReplicationInfo pri, float YL, int PlayerBoxSizeY, int BoxSpaceY, int BoxTextOffsetY, int BoxXPos, int BoxWidth) {
    local float charXL;

    super.drawStats(canvas, i, pri, YL, PlayerBoxSizeY, BoxSpaceY, BoxTextOFfsetY, BoxXPos, BoxWidth);
    canvas.DrawColor = HUDClass.default.WhiteColor;
    canvas.SetPos(BoxXPos + 0.5 * BoxWidth, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
    canvas.DrawText(FormatTime(ViewportOwner.Actor.GameReplicationInfo.ElapsedTime - pri.StartTime),true);

    Canvas.StrLen(CharText, charXL, YL);
    canvas.SetPos(BoxXPos + 0.375 * BoxWidth  - 0.5*charXL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
    Canvas.DrawText(KFPlayerReplicationInfo(pri).ClientVeteranSkillLevel, true);
}

defaultproperties {
    keyDataIndex= 2
    TimeText= "Time"
    CharText= "Level"
}
