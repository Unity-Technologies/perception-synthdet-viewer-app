using UnityEditor;

public class BuildForIOS
{
    private static string[] SCENES = {
        "Assets/Scenes/MainScene.unity"
    };

    [MenuItem ("File/Build for iOS")]
    public static void Build()
    {
        string deployPath = "xcode-build";
        BuildPipeline.BuildPlayer(SCENES, deployPath, BuildTarget.iOS, BuildOptions.AcceptExternalModificationsToPlayer);
    }
}
