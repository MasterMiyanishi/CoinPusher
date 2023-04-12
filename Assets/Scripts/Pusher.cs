using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pusher : MonoBehaviour {

    public float nowTime = 5f;
    // 待ち時間
    public float waitTime = 5f;

    // 離散値移動にするかどうか
    public bool transformMove = false;

    // 動かす力
    public float power = 10f;

    // 動かす方向
    public Vector3 moveDirection = new Vector3(1,0,0);

    Rigidbody t_Rigidbody;
    private void Start()
    {
        // 物理挙動コンポーネントを取得
        t_Rigidbody = GetComponent<Rigidbody>();

        // 物理挙動がない場合は離散値移動にする
        if (t_Rigidbody == null)
        {
            power /= 5f;
            transformMove = true;
        }

        // 押す強さを加える
        moveDirection *= power;
    }

    private void FixedUpdate () {

        // 前回フレームから今回フレームまでの時間を追加
        nowTime += Time.deltaTime;

        // nowTimeがwaitTimeを超えたら処理する
        if (nowTime > waitTime)
        {

            // 移動を反転する
            moveDirection *= -1;

            if (!transformMove)
            {
                t_Rigidbody.velocity = Vector3.zero;
            }

            // 待ち時間をリセット
            nowTime = 0f;
        }

        // 離散値移動の場合
        if (transformMove)
        {
            transform.position += moveDirection;
        }
        // 物理挙動移動の場合
        else
        {
            t_Rigidbody.MovePosition(transform.position + moveDirection);
        }

        // 範囲制御

    }
}
