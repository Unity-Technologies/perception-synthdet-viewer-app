using JetBrains.Annotations;

namespace Models
{
    [System.Serializable]
    public class ModelEndpoint
    {
        [CanBeNull] public string name;
        [CanBeNull] public string url;
    }
}
