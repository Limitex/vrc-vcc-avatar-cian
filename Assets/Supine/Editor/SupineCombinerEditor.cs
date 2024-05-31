using UnityEngine;
using UnityEditor;
using UnityEditor.Animations;
using static VRC.SDK3.Avatars.Components.VRCAvatarDescriptor;
using VRC.SDK3.Avatars.Components;
using System.IO;
using VRC.SDK3.Avatars.ScriptableObjects;
using static VRC.SDK3.Avatars.ScriptableObjects.VRCExpressionsMenu.Control;
using System.Reflection;
using Supine;

public class SupineCombinerEditor : EditorWindow
{
    private GameObject avatar;
    private SupineCombiner supineCombiner;

    private int _language = 0;

    private bool _canCombine = false;
    private bool _shouldInheritOriginalAnimation = true;

    private int _sittingPose1 = 0;
    private int _sittingPose2 = 1;

    [MenuItem("MinMinMart/Supine Combiner")]
    private static void Create()
    {
        GetWindow<SupineCombinerEditor>("Supine Combiner");
    }

    private void OnGUI()
    {
        // 言語選択＆辞書取得
        string[] _languages = {"Japanese", "English"};
        _language = EditorGUILayout.Popup("Language", _language, _languages);
        var localizeDict = LocalizeHelper.GetLocalizedTexts(_language);

        EditorGUILayout.Space();

        // アバター取得
        using (new GUILayout.HorizontalScope())
        {
            EditorGUI.BeginChangeCheck();
            avatar = EditorGUILayout.ObjectField(localizeDict.avatar, avatar, typeof(GameObject), true) as GameObject;
            
            if (EditorGUI.EndChangeCheck())
            {
                _canCombine = false;
            }
        }

        EditorGUILayout.Space();

        // 元の立ち、しゃがみ、伏せアニメーションを継承するか
        _shouldInheritOriginalAnimation = EditorGUILayout.ToggleLeft(localizeDict.inherit_original, _shouldInheritOriginalAnimation);

        EditorGUILayout.Space();

        // 座り方選択
        string[] _sittingPoses =
            {
                localizeDict.petan,
                localizeDict.tatehiza_girl,
                localizeDict.agura,
                localizeDict.tatehiza_boy
            };
        _sittingPose1 = EditorGUILayout.Popup(localizeDict.sit1, _sittingPose1, _sittingPoses);
        _sittingPose2 = EditorGUILayout.Popup(localizeDict.sit2, _sittingPose2, _sittingPoses);

        EditorGUILayout.Space();

        // Checkボタン
        using (new GUILayout.VerticalScope())
        {
            using (new EditorGUI.DisabledGroupScope(!avatar))
            {
                if (GUILayout.Button(localizeDict.check))
                {
                    supineCombiner = new SupineCombiner(avatar);
                    if (supineCombiner.canCombine)
                    {
                        _canCombine = true;
                        EditorUtility.DisplayDialog(localizeDict.check_successful, localizeDict.check_successful_message, "OK");
                        Debug.Log("[VRCSupine] Check OK.");
                    }
                    else
                    {
                        _canCombine = false;
                        EditorUtility.DisplayDialog(localizeDict.check_failure, localizeDict.check_failure_message, "OK");
                        Debug.Log("[VRCSupine] Check failed.");
                    }

                    if (supineCombiner.alreadyCombined)
                    {
                        EditorUtility.DisplayDialog(localizeDict.already_combined, localizeDict.already_combined_message, "OK");
                    }
                }
            }

            // Combineボタン
            using (new EditorGUI.DisabledGroupScope(!_canCombine))
            {
                if (GUILayout.Button(localizeDict.combine))
                {
                    try
                    {
                        supineCombiner.CombineWithAvatar(
                            shouldInheritOriginalAnimation: _shouldInheritOriginalAnimation,
                            sittingPoseOrder1: _sittingPose1,
                            sittingPoseOrder2: _sittingPose2
                        );
                    }
                    catch (IOException e)
                    {
                        EditorUtility.DisplayDialog(localizeDict.combine_failure, localizeDict.combine_failure_message, "OK");
                        throw e;
                    }
                    EditorUtility.DisplayDialog(localizeDict.combine_successful, localizeDict.combine_successful_message, "OK");
                    _canCombine = false;
                }
            }
        }
    }
}