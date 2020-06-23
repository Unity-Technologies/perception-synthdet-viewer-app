using System.Collections.Generic;
using JetBrains.Annotations;

namespace Models
{
    [System.Serializable]
    public class SettingsModel
    {
        public float predictionScoreThreshold = 0.75f;

        public List<ModelEndpoint> modelEndpoints = new List<ModelEndpoint>();

        [CanBeNull] public ModelEndpoint activeEndpoint;
    }
}
