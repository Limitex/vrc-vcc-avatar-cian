using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEditor;
using UnityEditor.Animations;
using static VRC.SDK3.Avatars.Components.VRCAvatarDescriptor;
using VRC.SDK3.Avatars.Components;
using VRC.SDK3.Avatars.ScriptableObjects;

using ExpressionsMenu = VRC.SDK3.Avatars.ScriptableObjects.VRCExpressionsMenu;
using ExpressionsMenuControl = VRC.SDK3.Avatars.ScriptableObjects.VRCExpressionsMenu.Control;
using ExpressionParameters = VRC.SDK3.Avatars.ScriptableObjects.VRCExpressionParameters;
using ExpressionParameter = VRC.SDK3.Avatars.ScriptableObjects.VRCExpressionParameters.Parameter;


/// <summary>
/// avatarにLocomotion, Menu, Parametersを組み込むクラス
/// </summary>

public class SupineCombiner
{
    private GameObject _avatar;
    private string _avatar_name;
    private VRCAvatarDescriptor _avatarDescriptor;
    public bool canCombine = true;
    public bool alreadyCombined = false;

    private string _templatesPath = "Assets\\Supine\\Templates\\";
    private string _generatedPath = "Assets\\Supine\\Generated\\";

    private ExpressionParameter[] _oldSupineParameters = new ExpressionParameter[4]
        {
            new ExpressionParameter { name = "VRCLockPose", valueType = ExpressionParameters.ValueType.Int },
            new ExpressionParameter { name = "VRCFootAnchor", valueType = ExpressionParameters.ValueType.Int },
            new ExpressionParameter { name = "VRCMjiTime", valueType = ExpressionParameters.ValueType.Float },
            new ExpressionParameter { name = "VRCKjiTime", valueType = ExpressionParameters.ValueType.Float }
        };
    private string[] _sittingAnimationFilePaths =
    {
        "Assets\\Supine\\Animations\\座り\\ぺたん.anim",
        "Assets\\Supine\\Animations\\座り\\たてひざ（女）.anim",
        "Assets\\Supine\\Animations\\座り\\あぐら.anim",
        "Assets\\Supine\\Animations\\座り\\たてひざ（男）.anim"
    };

    /// <summary>
    /// Constructor
    /// </summary>
    /// <param name="avatar">アバターのGameObject</param>
    public SupineCombiner(GameObject avatar)
    {
        _avatar = avatar;
        _avatar_name = avatar.name;
        _avatarDescriptor = avatar.GetComponent<VRCAvatarDescriptor>();

        if (_avatarDescriptor == null)
        {
            // avatar descriptorがなければエラー
            Debug.LogError("[VRCSupine] Could not find VRCAvatarDescriptor.");
            canCombine = false;
        }
        else if (hasGeneratedFiles())
        {
            //  すでに組込済みの場合、(アバター名)_(数字)で作れるようになるまでループ回す
            alreadyCombined = true;
            Debug.Log("[VRCSupine] Directory already exists.");
            int suffix;
            for (suffix=1; hasGeneratedFiles(suffix); suffix++);
            _avatar_name = _avatar_name + "_" + suffix.ToString();
        }
    }

    /// <summary>
    /// avatarにLocomotion, Menu, Parametersの組込実行
    /// </summary>
    public void CombineWithAvatar(
        bool shouldInheritOriginalAnimation = true,
        int sittingPoseOrder1 = 0,
        int sittingPoseOrder2 = 1
    )
    {
        if (canCombine)
        {
            // SerializedObjectで操作する
            var descriptorObj = new SerializedObject(_avatarDescriptor);
            descriptorObj.FindProperty("customizeAnimationLayers").boolValue = true;
            descriptorObj.FindProperty("customExpressions").boolValue = true;

            // Locomotionを組む
            var locomotionController = CreateAssetFromTemplate<AnimatorController>("SupineLocomotion.controller");
            var locomotionStates = locomotionController.layers[0].stateMachine.states;

            if (shouldInheritOriginalAnimation)
            {
                // 元のLocomotionからアニメーションを取り出す
                var originalLocomotion = _avatarDescriptor.baseAnimationLayers[0].animatorController as AnimatorController;
                if (originalLocomotion != null)
                {
                    var originalLocomotionStates = originalLocomotion.layers[0].stateMachine.states;
                    var standingState = FindStateByName(originalLocomotionStates, "Standing");
                    var crouchingState = FindStateByName(originalLocomotionStates, "Crouching");
                    var proneState = FindStateByName(originalLocomotionStates, "Prone");

                    // モーション上書き
                    var standing = FindStateByName(locomotionStates, "Standing");
                    var crouching = FindStateByName(locomotionStates, "Crouching");
                    var prone = FindStateByName(locomotionStates, "Prone");
                    if (standingState != null)
                        standing.motion = standingState.motion;
                    if (crouchingState != null)
                        crouching.motion = crouchingState.motion;
                    if (proneState != null)
                        prone.motion = proneState.motion;
                }
            }

            // 座りアニメーションを変更
            var sittingPose1 = AssetDatabase.LoadAssetAtPath<AnimationClip>(_sittingAnimationFilePaths[sittingPoseOrder1]);
            var sittingPose2 = AssetDatabase.LoadAssetAtPath<AnimationClip>(_sittingAnimationFilePaths[sittingPoseOrder2]);
            var sittingPose1State = FindStateByName(locomotionStates, "Sit 1");
            var sittingPose2State = FindStateByName(locomotionStates, "Sit 2");
            sittingPose1State.motion = sittingPose1 as AnimationClip;
            sittingPose2State.motion = sittingPose2 as AnimationClip;

            // Avatar DescriptorにLocomotionをセット
            var layersProp = descriptorObj.FindProperty("baseAnimationLayers.Array");
            var layerProp = layersProp.GetArrayElementAtIndex(0);
            layerProp.FindPropertyRelative("isDefault").boolValue = false;
            var controllerProp = layerProp.FindPropertyRelative("animatorController");
            controllerProp.objectReferenceValue = locomotionController;

            // ExMenuを組む
            var exMenu = CreateAssetFromTemplate<ExpressionsMenu>("MainMenu.asset");
            EditorUtility.SetDirty(exMenu);
            var descriptorMenuProp = descriptorObj.FindProperty("expressionsMenu");

            ExpressionsMenu descriptorMenu = _avatarDescriptor.expressionsMenu;
            if (descriptorMenu == null) descriptorMenu = new ExpressionsMenu();
            var descriptorControls = descriptorMenu.controls;
            if (descriptorControls == null) descriptorControls = new List<ExpressionsMenuControl>();

            exMenu.controls = AssembleExMenuControls(descriptorControls, exMenu.controls);

            descriptorMenuProp.objectReferenceValue = exMenu;

            // ExParametersを組む
            var exParameters = CreateAssetFromTemplate<ExpressionParameters>("SupineParameters.asset");
            EditorUtility.SetDirty(exParameters);
            var descriptorParamsProp = descriptorObj.FindProperty("expressionParameters");

            var descriptorParams = _avatarDescriptor.expressionParameters;
            if (descriptorParams == null) descriptorParams = new ExpressionParameters();
            var descriptorParamsArray = descriptorParams.parameters;
            if (descriptorParamsArray == null) descriptorParamsArray = new ExpressionParameter[0];

            exParameters.parameters = AssembleExParameters(descriptorParamsArray, exParameters.parameters);

            descriptorParamsProp.objectReferenceValue = exParameters;
            
            // 変更を適用
            descriptorObj.ApplyModifiedProperties();

            Debug.Log("[VRCSupine] Created the directory '" + generatedDirectory() + "'.");
            Debug.Log("[VRCSupine] Combination is done.");

        } else {
            Debug.LogError("[VRCSupine] Could not combine with this avatar.");
        }
    }

    private T CreateAssetFromTemplate<T>(string name) where T : Object
    {
        string generatedPath = generatedDirectory() + "\\" + _avatar_name + "_" + name;
        string templatePath = _templatesPath + name;
        
        if (!Directory.Exists(generatedDirectory()))
        {
            Directory.CreateDirectory(generatedDirectory());
        }

        if (!AssetDatabase.CopyAsset(templatePath, generatedPath))
        {
            Debug.LogError("[VRCSupine] Could not create asset: (" + generatedPath + ") from: (" + templatePath + ")");
            throw new IOException();
        }

        return AssetDatabase.LoadAssetAtPath<T>(generatedPath);
    }

    private string generatedDirectory(int suffix = 0)
    {
        if (suffix > 0) {
            return _generatedPath + _avatar_name + "_" + suffix.ToString();
        }
        else
        {
            return _generatedPath + _avatar_name;
        }
    }

    private bool hasGeneratedFiles(int suffix = 0)
    {
        return AssetDatabase.IsValidFolder(generatedDirectory(suffix));
    }

    private List<ExpressionsMenuControl> AssembleExMenuControls(List<ExpressionsMenuControl> baseControls, List<ExpressionsMenuControl> templateControls)
    {
        // 結合して重複要素＆古いごろ寝メニューがあれば削除
        var concatinated = baseControls.Concat(templateControls).ToList<ExpressionsMenuControl>();
        concatinated.RemoveAll(IsMissingSupineMenu);
        var uniqued = concatinated.Distinct(new ExMenuControlComparer()).ToList<ExpressionsMenuControl>();
        return uniqued;
    }

    private ExpressionParameter[] AssembleExParameters(ExpressionParameter[] baseParams, ExpressionParameter[] templateParams)
    {
        // 結合して重複要素を削除＆古いごろ寝パラメータがあれば削除
        var baseParamsList = new List<ExpressionParameter>(baseParams);
        var concatinated = baseParamsList.Concat(templateParams);
        var uniqued = concatinated.Distinct(new ExParameterComparer()).ToList<ExpressionParameter>();
        uniqued.RemoveAll(IsOldSupineParameter);
        return uniqued.ToArray<ExpressionParameter>();
    }

    private bool IsMissingSupineMenu(ExpressionsMenuControl control)
    {
        // 古いごろ寝サブメニューか
        if (control.name == "Suimin" && control.type == ExpressionsMenuControl.ControlType.SubMenu)
        {
            return control.subMenu == null;
        }
        else
        {
            return false;
        }
    }

    private bool IsOldSupineParameter(ExpressionParameter parameter)
    {
        // 古いごろ寝パラメータと一致するか
        return _oldSupineParameters.Contains(parameter, new ExParameterComparer());
    }

    private AnimatorState FindStateByName(ChildAnimatorState[] states, string name)
    {
        // 名前でステートを探索
        foreach (var childState in states)
        {
            if (childState.state.name == name)
            {
                return childState.state;
            }
        }
        return null;
    }

}