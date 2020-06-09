using UnityEditor;

public class BuildForIOS
{
    private static string[] SCENES = {
        "Assets/Scenes/MainScene.unity"
    };

    public static void Build()
    {
        string deployPath = "xcode-build";
        BuildPipeline.BuildPlayer(SCENES, deployPath, BuildTarget.iOS, BuildOptions.AcceptExternalModificationsToPlayer);
    }
}
