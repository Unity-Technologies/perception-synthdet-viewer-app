using System.Collections.Generic;
using UnityEngine;

public class BoxColors
{
    private static  Dictionary<string, Color> _labelPrefixToColorMap = new Dictionary<string, Color>();

    static BoxColors() 
    {
        _labelPrefixToColorMap.Add("NONE", Utils.ColorFromRgba255(0, 0, 0));
        _labelPrefixToColorMap.Add("book", Utils.ColorFromRgba255(0, 122, 255));
        _labelPrefixToColorMap.Add("candy", Utils.ColorFromRgba255(52, 199, 89));
        _labelPrefixToColorMap.Add("cereal", Utils.ColorFromRgba255(108, 106, 234));
        _labelPrefixToColorMap.Add("chips", Utils.ColorFromRgba255(255, 149, 0));
        _labelPrefixToColorMap.Add("cleaning", Utils.ColorFromRgba255(255, 45, 85));
        _labelPrefixToColorMap.Add("cracker", Utils.ColorFromRgba255(175, 82, 222));
        _labelPrefixToColorMap.Add("craft", Utils.ColorFromRgba255(255, 59, 48));
        _labelPrefixToColorMap.Add("drink", Utils.ColorFromRgba255(90, 200, 250));
        _labelPrefixToColorMap.Add("footware", Utils.ColorFromRgba255(255, 204, 0));
        _labelPrefixToColorMap.Add("hygiene", Utils.ColorFromRgba255(255, 204, 0));
        _labelPrefixToColorMap.Add("lotion", Utils.ColorFromRgba255(0, 122, 255));
        _labelPrefixToColorMap.Add("pasta", Utils.ColorFromRgba255(52, 199, 89));
        _labelPrefixToColorMap.Add("pest", Utils.ColorFromRgba255(88, 86, 214));
        _labelPrefixToColorMap.Add("porridge", Utils.ColorFromRgba255(255, 149, 0));
        _labelPrefixToColorMap.Add("seasoning", Utils.ColorFromRgba255(255, 45, 85));
        _labelPrefixToColorMap.Add("snack", Utils.ColorFromRgba255(175, 82, 222));
        _labelPrefixToColorMap.Add("soup", Utils.ColorFromRgba255(255, 59, 48));
        _labelPrefixToColorMap.Add("storage", Utils.ColorFromRgba255(90, 200, 250));
        _labelPrefixToColorMap.Add("toiletry", Utils.ColorFromRgba255(255, 204, 0));
        _labelPrefixToColorMap.Add("toy", Utils.ColorFromRgba255(255, 204, 0));
        _labelPrefixToColorMap.Add("utensil", Utils.ColorFromRgba255(0, 122, 255));
        _labelPrefixToColorMap.Add("vitamin", Utils.ColorFromRgba255(52, 199, 89));
    }

    public static Color? ColorForItemLabel(string label)
    {
        var prefix = label.GetUntilOrEmpty("_");

        if (_labelPrefixToColorMap.TryGetValue(prefix, out var color))
        {
            return color;
        }

        return null;
    }
}
