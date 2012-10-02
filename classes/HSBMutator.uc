class HSBMutator extends Mutator;

function PostBeginPlay() {
    if (KFGameType(Level.Game) == none) {
        destroy();
        return;
    }

    AddToPackageMap("HUDScoreboard");
}

simulated function Tick(float DeltaTime) {
    local PlayerController PC;

    PC= Level.GetLocalPlayerController();
    if (PC != none) {
        PC.Player.InteractionMaster.AddInteraction("HUDScoreboard.ScoreboardInteraction", PC.Player);
    }
    Disable('Tick');
}

defaultproperties {
    GroupName="KFHudScoreboard"
    FriendlyName= "HUD Scoreboard"
    Description= "A custom scoreboard"

    RemoteRole= ROLE_SimulatedProxy
    bAlwaysRelevant= true
}
