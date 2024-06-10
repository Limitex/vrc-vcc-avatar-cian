using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoConstraintInsp : MonoBehaviour
{
    public GameObject avatar = null;
    public GameObject target = null;

    public bool locked = false;
    public bool useFolder = false;
    public string folderName = "";

    public List<GameObject> itemList = new List<GameObject>() { null };

    public bool removeSelf = false;
    public bool lockedScript = false;
}
