class ScoreboardTwo extends ScoreboardInteractionBase;

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
    local float DeathsXL;

    canvas.DrawColor = HUDClass.default.WhiteColor;
    canvas.StrLen(KFPlayerReplicationInfo(KFHP.PlayerReplicationInfo).Kills, KillWidthX, YL);
    canvas.SetPos(BoxXPos + 0.60 * BoxWidth - 0.5 * KillWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
    canvas.DrawText(KFPlayerReplicationInfo(KFHP.PlayerReplicationInfo).Kills, true);
    
    canvas.SetPos(BoxXPos + 0.5 * BoxWidth, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
    canvas.DrawText(KFHP.Weapon.AmmoAmount(0)$"/"$KFHP.Weapon.MaxAmmo(0),true);

    canvas.SetPos(BoxXPos + 0.375 * BoxWidth  - 0.5*DeathsXL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
    if (class<KFWeaponPickup>(KFHP.Weapon.PickupClass) != none) {
        Canvas.DrawText(class<KFWeaponPickup>(KFHP.Weapon.PickupClass).default.ItemShortName,true);
    } else {
        Canvas.DrawText(KFHP.Weapon.PickupClass.default.InventoryType.default.ItemName, true);
    }

    // draw healths
    Canvas.SetPos(BoxXPos + 0.75 * BoxWidth - 0.5 * HealthWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
    if ( KFHP.PlayerReplicationInfo.bOutOfLives ) {
        Canvas.DrawColor = HUDClass.default.RedColor;
        Canvas.DrawText(OutText,true);
    } else {
        if( KFPlayerReplicationInfo(KFHP.PlayerReplicationInfo).PlayerHealth>=95 ) {
            Canvas.DrawColor = HUDClass.default.GreenColor;
            Canvas.DrawText(HealthyString,true);
        }
        else if( KFPlayerReplicationInfo(KFHP.PlayerReplicationInfo).PlayerHealth>=50 ) {
            Canvas.DrawColor = HUDClass.default.GoldColor;
            Canvas.DrawText(InjuredString,true);
        }
        else {
            Canvas.DrawColor = HUDClass.default.RedColor;
            Canvas.DrawText(CriticalString,true);
        }
    }
}

defaultproperties {
    keyDataIndex= 2
    PointsText="Weapon"
    DeathsText= "Ammo"
}
