using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputRotation : MonoBehaviour {

    [Header("入力キー")]
    public string launchKey = "Horizontal";

    [Header("回転パワー")]
    public Vector3 rotationPower = new Vector3(0,5,0);

    private Quaternion preRotation;

    private void Start()
    {
        preRotation = transform.rotation;
    }
    private void Update()
    {
        // 入力キーが押されているとき押された方向に回転する
        //GetComponent<Rigidbody>().MoveRotation(Quaternion.Euler(rotationPower * Input.GetAxis(launchKey)));
        //GetComponent<Rigidbody>().rotation = defaultRotation * Quaternion.Euler(rotationPower * Input.GetAxis(launchKey));

        //transform.rotation = defaultRotation * Quaternion.Euler(rotationPower * Input.GetAxis(launchKey));
        
        // ローテーションのXが0.2以上の時は回転する
        if (transform.rotation.x >= 0.092f)
        {
            preRotation = transform.rotation;
            transform.Rotate(rotationPower * Input.GetAxis(launchKey));
            if (transform.rotation.x < 0.092f)
            {
                transform.rotation = preRotation;
            }
        }
        else
        {
            transform.rotation = preRotation;
        }
    }
}
