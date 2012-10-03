class ScoreboardTwo extends ScoreboardInteractionBase;

function PostRender(Canvas canvas) {
    local PlayerReplicationInfo PRI, OwnerPRI;
    local int i, FontReduction, NetXPos, PlayerCount, HeaderOffsetY, HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, OwnerOffset, HealthXPos, BoxXPos,KillsXPos, TitleYPos, BoxWidth, VetXPos, ScoreXPos, DeathsXPos;
    local float XL,YL, MaxScaling;
    local float deathsXL, KillsXL, netXL,HealthXL, MaxNamePos, KillWidthX, HealthWidthX, ScoreXL;
    local bool bNameFontReduction;
    local Material VeterancyBox;
    local array<KFHumanPawn> pawnArray;
    local KFHumanPawn KFHP;

    OwnerPRI = ViewportOwner.Actor.PlayerReplicationInfo;
    OwnerOffset = -1;

    foreach ViewportOwner.Actor.DynamicActors(class'KFHumanPawn', KFHP) {
        PRI= KFHP.PlayerReplicationInfo;

        if ( !PRI.bOnlySpectator ) {
            if ( PRI == OwnerPRI ) {
                OwnerOffset = i;
            }

            PlayerCount++;
            pawnArray[pawnArray.Length]= KFHP;
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

    // draw background boxes
    Canvas.Style = ViewportOwner.Actor.ERenderStyle.STY_Alpha;
    Canvas.DrawColor = HUDClass.default.WhiteColor;
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

    Canvas.DrawColor = HUDClass.default.WhiteColor;
    Canvas.SetPos(NameXPos, TitleYPos);
    Canvas.DrawText(PlayerText,true);

    if( bDisplayWithKills ) {
        Canvas.SetPos(KillsXPos - 0.5 * KillsXL, TitleYPos);
        Canvas.DrawText(KillsText,true);
    }

    Canvas.SetPos(HealthXPos - 0.5 * HealthXL, TitleYPos);
    Canvas.DrawText(HealthText,true);

    Canvas.SetPos(ScoreXPos - 0.5*ScoreXL, TitleYPos);
    Canvas.DrawText(PointsText,true);
    Canvas.SetPos(DeathsXPos - 0.5*DeathsXL, TitleYPos);
    Canvas.DrawText(DeathsText,true);

    // draw player names
    MaxNamePos = 0.9 * (KillsXPos - NameXPos);

    for ( i = 0; i < PlayerCount; i++ ) {
        Canvas.StrLen(pawnArray[i].PlayerReplicationInfo.PlayerName, XL, YL);

        if ( XL > MaxNamePos ) {
            bNameFontReduction = true;
            break;
        }
    }

    if ( bNameFontReduction ) {
        Canvas.Font = GetSmallerFontFor(Canvas, FontReduction + 1);
    }

    Canvas.Style = ViewportOwner.Actor.ERenderStyle.STY_Normal;
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);
    BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

    Canvas.DrawColor = HUDClass.default.WhiteColor;
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

        Canvas.DrawTextClipped(pawnArray[i].PlayerReplicationInfo.PlayerName);
    }

    Canvas.ClipX = MaxNamePos;
    Canvas.DrawColor = HUDClass.default.WhiteColor;

    if ( bNameFontReduction ) {
        Canvas.Font = GetSmallerFontFor(Canvas, FontReduction);
    }

    Canvas.Style = ViewportOwner.Actor.ERenderStyle.STY_Normal;
    MaxScaling = FMax(PlayerBoxSizeY,30.f);

    for ( i = 0; i < PlayerCount; i++ ) {
        Canvas.DrawColor = HUDClass.default.WhiteColor;

        // Display perks.
        if ( KFPlayerReplicationInfo(pawnArray[i].PlayerReplicationInfo)!=None && KFPlayerReplicationInfo(pawnArray[i].PlayerReplicationInfo).ClientVeteranSkill != none ) {
            VeterancyBox = KFPlayerReplicationInfo(pawnArray[i].PlayerReplicationInfo).ClientVeteranSkill.default.OnHUDIcon;

            if ( VeterancyBox != None ) {
                Canvas.SetPos(VetXPos, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY - PlayerBoxSizeY * 0.22);
                Canvas.DrawTile(VeterancyBox, PlayerBoxSizeY, PlayerBoxSizeY, 0, 0, VeterancyBox.MaterialUSize(), VeterancyBox.MaterialVSize());
            }
        }

        // draw kills
        if( bDisplayWithKills ) {
            Canvas.StrLen(KFPlayerReplicationInfo(pawnArray[i].PlayerReplicationInfo).Kills, KillWidthX, YL);
            Canvas.SetPos(KillsXPos - 0.5 * KillWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);
            Canvas.DrawText(KFPlayerReplicationInfo(pawnArray[i].PlayerReplicationInfo).Kills, true);
        }

        // draw cash
        Canvas.SetPos(ScoreXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
        Canvas.DrawText(pawnArray[i].Weapon.AmmoAmount(0)$"/"$pawnArray[i].Weapon.MaxAmmo(0),true);

        // draw deaths
        Canvas.SetPos(DeathsXPos  - 0.5*DeathsXL, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
        if (class<KFWeaponPickup>(pawnArray[i].Weapon.PickupClass) != none) {
            Canvas.DrawText(class<KFWeaponPickup>(pawnArray[i].Weapon.PickupClass).default.ItemShortName,true);
        } else {
            Canvas.DrawText(pawnArray[i].Weapon.PickupClass.default.InventoryType.default.ItemName, true);
        }

        // draw healths
        Canvas.SetPos(HealthXpos - 0.5 * HealthWidthX, (PlayerBoxSizeY + BoxSpaceY) * i + BoxTextOffsetY);

        if ( pawnArray[i].PlayerReplicationInfo.bOutOfLives ) {
            Canvas.DrawColor = HUDClass.default.RedColor;
            Canvas.DrawText(OutText,true);
        }
        else {
            if( KFPlayerReplicationInfo(pawnArray[i].PlayerReplicationInfo).PlayerHealth>=95 ) {
                Canvas.DrawColor = HUDClass.default.GreenColor;
                Canvas.DrawText(HealthyString,true);
            }
            else if( KFPlayerReplicationInfo(pawnArray[i].PlayerReplicationInfo).PlayerHealth>=50 ) {
                Canvas.DrawColor = HUDClass.default.GoldColor;
                Canvas.DrawText(InjuredString,true);
            }
            else {
                Canvas.DrawColor = HUDClass.default.RedColor;
                Canvas.DrawText(CriticalString,true);
            }
        }
    }

    if ( ViewportOwner.Actor.GetEntryLevel().NetMode == NM_Standalone )
        return;

    Canvas.StrLen(NetText, NetXL, YL);
    Canvas.DrawColor = HUDClass.default.WhiteColor;
    Canvas.SetPos(NetXPos - 0.5 * NetXL, TitleYPos);
    Canvas.DrawText(NetText,true);

    for ( i=0;i < pawnArray.Length; i++ ) {
        PRIArray[i] = pawnArray[i].PlayerReplicationInfo;
    }

    DrawNetInfo(Canvas, FontReduction, HeaderOffsetY, PlayerBoxSizeY, BoxSpaceY, BoxTextOffsetY, OwnerOffset, PlayerCount, NetXPos);
    DrawMatchID(Canvas, FontReduction);

}

defaultproperties {
    keyDataIndex= 2
    DeathsText= "Weapon"
    PointsText= "Ammo"
}
