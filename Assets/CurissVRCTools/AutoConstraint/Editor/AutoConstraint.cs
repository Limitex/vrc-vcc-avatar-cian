using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;
using UnityEditor;

public class AutoConstraint : EditorWindow
{
    GameObject _avatar = null;
    GameObject _target = null;
    bool _locked = false;

    bool _useFolder = false;
    string _folderName = "";

    int _itemCount = 1;
    List<GameObject> _itemList = new List<GameObject>() { null };

    [MenuItem("Curiss/Auto Constraint", false , 1)]
    public static void ShowWindow()
    {
        EditorWindow window = GetWindow<AutoConstraint>("Auto Constraint");
        window.minSize = new Vector2(330, 330);
    }

    void OnGUI()
    {
        // 타이틀.
        GUILayout.Space(7);
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
        _avatar = (GameObject)EditorGUILayout.ObjectField("Avatar", _avatar, typeof(GameObject), true);

        // 연결할 대상.
        _target = (GameObject)EditorGUILayout.ObjectField("Connect Target", _target, typeof(GameObject), true);


        //-------- Constraint 세팅.
        GuiLine();
        GUILayout.Label(" Constraint Setting", new GUIStyle() { fontStyle = FontStyle.Bold });

        // Locked 설정.
        _locked = EditorGUILayout.Toggle("Locked", _locked);

        // Folder 사용.
        _useFolder = EditorGUILayout.Toggle("Use Folder", _useFolder);

        if (_useFolder)
        {
            _folderName = EditorGUILayout.TextField("Folder Name", _folderName);
        }


        //-------- 오브젝트 목록.
        GuiLine();
        GUILayout.Label(" Items", new GUIStyle() { fontStyle = FontStyle.Bold });

        // 오브젝트 갯수.
        EditorGUI.BeginChangeCheck();
        _itemCount = EditorGUILayout.DelayedIntField("count", _itemCount);
        if (EditorGUI.EndChangeCheck())
        {
            while (_itemCount < _itemList.Count)
                _itemList.RemoveAt(_itemList.Count - 1);
            while (_itemCount > _itemList.Count)
                _itemList.Add(null);
        }

        // 오브젝트 목록.
        for (int i = 0; i < _itemList.Count; i++)
        {
            _itemList[i] = (GameObject)EditorGUILayout.ObjectField(" ", _itemList[i], typeof(GameObject), true);
        }

        // 오류 체크.
        bool error = ErrorCheck();

        GuiLine();

        // 적용 버튼.
        EditorGUI.BeginDisabledGroup(error);
        if (GUILayout.Button("Apply"))
        {
            Transform parentObject;

            // Constraint 오브젝트 찾기/생성.
            Transform constraintObject = _avatar.transform.Find("Constratint." + _target.name);
            if(!constraintObject)
                constraintObject = new GameObject("Constratint." + _target.name).transform;

            constraintObject.position = _target.transform.position;
            constraintObject.rotation = _target.transform.rotation;
            constraintObject.parent = _avatar.transform;
            parentObject = constraintObject;

            // Folder 생성.
            if (_useFolder)
            {
                parentObject = constraintObject.Find(_folderName);
                if (!parentObject)
                    parentObject = new GameObject(_folderName).transform;

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
                    sourceTransform = _target.transform
                });
                constraint.weight = 1;
                constraint.locked = _locked;
                constraint.constraintActive = true;
            }
            // 오브젝트 부모 설정.
            for (int i = 0; i < _itemList.Count; i++)
            {
                if (_itemList[i])
                    _itemList[i].transform.parent = parentObject;
            }
        }
        EditorGUI.EndDisabledGroup();
    }

    // 오류 체크.
    bool ErrorCheck()
    {
        bool error = false;
    
        if (!_avatar)
        {
            EditorGUILayout.HelpBox("Avatar is not specified.", MessageType.Error);
            error = true;
        }

        if (!_target)
        {
            EditorGUILayout.HelpBox("Connect Target is not specified.", MessageType.Error);
            error = true;
        }

        if (_useFolder && _folderName.Equals(""))
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