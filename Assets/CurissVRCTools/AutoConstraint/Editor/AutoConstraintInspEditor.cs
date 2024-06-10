using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;
using UnityEditor;

[CustomEditor(typeof(AutoConstraintInsp))]
public class AutoConstraintInspEditor : Editor
{
    SerializedProperty _avatar, _target;
    SerializedProperty _locked, _useFolder, _folderName;
    SerializedProperty _itemList;
    SerializedProperty _removeSelf, _lockedScript;

    void OnEnable()
    {
        AutoConstraintInsp script = (AutoConstraintInsp)target;

        if (PrefabUtility.IsAnyPrefabInstanceRoot(script.gameObject))
            PrefabUtility.UnpackPrefabInstance(script.gameObject, PrefabUnpackMode.OutermostRoot, InteractionMode.AutomatedAction);

        _avatar = serializedObject.FindProperty(nameof(script.avatar));
        _target = serializedObject.FindProperty(nameof(script.target));
        _locked = serializedObject.FindProperty(nameof(script.locked));
        _useFolder = serializedObject.FindProperty(nameof(script.useFolder));
        _folderName = serializedObject.FindProperty(nameof(script.folderName));
        _itemList = serializedObject.FindProperty(nameof(script.itemList));
        _removeSelf = serializedObject.FindProperty(nameof(script.removeSelf));
        _lockedScript = serializedObject.FindProperty(nameof(script.lockedScript));
    }

    public override void OnInspectorGUI()
    {
        AutoConstraintInsp script = (AutoConstraintInsp)target;

        GuiLine();

        // 타이틀.
        Rect controlRect = EditorGUILayout.GetControlRect();
        GUI.Label(controlRect, "Auto Constraint", new GUIStyle() { alignment = TextAnchor.MiddleCenter, fontStyle = FontStyle.Bold, fontSize = 16 });

        // 크레딧.
        GUIContent credit = new GUIContent("Script by Curiss");
        Vector2 labelSize = EditorStyles.label.CalcSize(credit);
        Rect creditRect = new Rect(controlRect.width - labelSize.x + 10, controlRect.y, labelSize.x, labelSize.y);

        if (GUI.Button(creditRect, credit, new GUIStyle(EditorStyles.label) { alignment = TextAnchor.LowerLeft, fontSize = 10 }))
        {
            Application.OpenURL("https://twitter.com/_Curiss");
        }

        //-------- 아바타 세팅.
        GuiLine();
        GUILayout.Label(" Avatar Setting", new GUIStyle() { fontStyle = FontStyle.Bold });

        // 아바타.
        EditorGUILayout.PropertyField(_avatar, new GUIContent("Avatar"));

        // 연결할 대상.
        EditorGUILayout.PropertyField(_target, new GUIContent("Connect Target"));

        EditorGUI.BeginDisabledGroup(script.lockedScript);
        //-------- Constraint 세팅.
        GuiLine();
        GUILayout.Label(" Constraint Setting", new GUIStyle() { fontStyle = FontStyle.Bold });

        // Locked 설정.
        EditorGUILayout.PropertyField(_locked, new GUIContent("Locked"));

        // Folder 사용.
        EditorGUILayout.PropertyField(_useFolder, new GUIContent("Use Folder"));

        if (_useFolder.boolValue)
        {
            EditorGUILayout.PropertyField(_folderName, new GUIContent("Folder Name"));
        }

        //-------- 오브젝트 목록.
        GuiLine();
        GUILayout.Label(" Items", new GUIStyle() { fontStyle = FontStyle.Bold });

        // 오브젝트 목록.
        EditorGUILayout.PropertyField(_itemList, true);


        //-------- 스크립트 세팅.
        GuiLine();
        GUILayout.Label(" Script Setting", new GUIStyle() { fontStyle = FontStyle.Bold });

        // 적용 후 삭제.
        EditorGUILayout.PropertyField(_removeSelf, new GUIContent("Remove script after apply"));
        EditorGUI.EndDisabledGroup();

        // 스크립트 잠금.
        EditorGUILayout.PropertyField(_lockedScript, new GUIContent("Locked Script"));

        GuiLine();

        // Inspecter 적용.
        serializedObject.ApplyModifiedProperties();

        // 오류 체크.
        bool error = ErrorCheck();

        // 적용 버튼.
        EditorGUI.BeginDisabledGroup(error);
        if (GUILayout.Button("Apply"))
        {
            Transform parentObject;

            // Constraint 오브젝트 찾기/생성.
            Transform constraintObject = script.avatar.transform.Find("Constratint." + script.target.name);
            if (!constraintObject)
                constraintObject = new GameObject("Constratint." + script.target.name).transform;

            constraintObject.position = script.target.transform.position;
            constraintObject.rotation = script.target.transform.rotation;
            constraintObject.parent = script.avatar.transform;
            parentObject = constraintObject;

            // Folder 생성.
            if (script.useFolder)
            {
                parentObject = constraintObject.Find(script.folderName);
                if (!parentObject)
                    parentObject = new GameObject(script.folderName).transform;

                parentObject.parent = constraintObject;
                parentObject.localPosition = Vector3.zero;
                parentObject.localRotation = new Quaternion(0, 0, 0, 0);
            }

            // Constraint 생성.
            if (constraintObject.gameObject.GetComponent<ParentConstraint>() == null)
            {
                ParentConstraint constraint = constraintObject.gameObject.GetComponent<ParentConstraint>();
                if (!constraint)
                    constraint = constraintObject.gameObject.AddComponent<ParentConstraint>();

                constraint.AddSource(new ConstraintSource()
                {
                    weight = 1,
                    sourceTransform = script.target.transform
                });
                constraint.weight = 1;
                constraint.locked = script.locked;
                constraint.constraintActive = true;
            }
            // 오브젝트 부모 설정.
            for (int i = 0; i < script.itemList.Count; i++)
            {
                if (script.itemList[i])
                    script.itemList[i].transform.parent = parentObject;
            }

            // 적용후 제거.
            if (script.removeSelf)
            {
                GameObject.DestroyImmediate(script.gameObject);
            }
        }
        EditorGUI.EndDisabledGroup();
    }

    // 오류 체크.
    bool ErrorCheck()
    {
        AutoConstraintInsp script = (AutoConstraintInsp)target;

        bool error = false;
        if (!script.avatar)
        {
            EditorGUILayout.HelpBox("Avatar is not specified.", MessageType.Error);
            error = true;
        }

        if (!script.target)
        {
            EditorGUILayout.HelpBox("Connect Target is not specified.", MessageType.Error);
            error = true;
        }

        if (script.useFolder && script.folderName.Equals(""))
        {
            EditorGUILayout.HelpBox("Folder name does not exist.", MessageType.Error);
            error = true;
        }

        return error;
    }

    // 경계선.
    void GuiLine(int i_height = 1, int padding = 5)
    {
        GUILayout.Space(padding);
        Rect rect = EditorGUILayout.GetControlRect(false, i_height);
        rect.height = i_height;
        EditorGUI.DrawRect(rect, new Color(0.5f, 0.5f, 0.5f, 1));
        GUILayout.Space(padding);
    }
}