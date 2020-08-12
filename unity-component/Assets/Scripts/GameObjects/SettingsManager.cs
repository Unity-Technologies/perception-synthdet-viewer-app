using Models;
using UnityEngine;

namespace GameObjects
{
    /// <summary>
    /// Component for saving and loading app settings
    /// </summary>
    public class SettingsManager : MonoBehaviour
    {
        private const string PlayerPrefsKey = "com.unity3d.synthdet-viewer-app.SettingsPlayerPrefKey";
    
        private SettingsModel _settingsModel;
    
        public SettingsModel SettingsModel
        {
            get => _settingsModel;

            private set
            {
                _settingsModel = value;
                SendToNativePlatforms();
            }
        }

        private void Start()
        {
            if (PlayerPrefs.HasKey(PlayerPrefsKey))
            {
                SetSettingsModelFromJson(PlayerPrefs.GetString(PlayerPrefsKey));
            }
            else
            {
                SettingsModel = new SettingsModel();
            }
        }

        // Can be called from native platforms that want to change settings
        // ReSharper disable once MemberCanBePrivate.Global
        public void SetSettingsModelFromJson(string json)
        {
            SettingsModel = JsonUtility.FromJson<SettingsModel>(json);
        }

        // Can be called from native platforms that want to save settings
        // ReSharper disable once UnusedMember.Global
        public void SaveSettings()
        {
            PlayerPrefs.SetString(PlayerPrefsKey, JsonUtility.ToJson(_settingsModel));
            PlayerPrefs.Save();
        }

        // Can be called from native platforms for changing active model
        // ReSharper disable once UnusedMember.Global
        public void SetActiveEndpointFromJson(string json)
        {
            _settingsModel.activeEndpoint = JsonUtility.FromJson<ModelEndpoint>(json);
        }

        private void SendToNativePlatforms()
        {
#if UNITY_IOS
            var settingsAsJson = JsonUtility.ToJson(_settingsModel).ToCharArray();
            NativeApi.settingsJsonDidChange(settingsAsJson, settingsAsJson.Length);
#endif
        }
    }
}
