using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestoryCoin : MonoBehaviour {

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Coin")
        {
            // エフェクト停止
            transform.GetChild(0).GetComponent<ParticleSystem>().Stop();

            // エフェクトの位置を移動
            transform.GetChild(0).transform.position = collision.transform.position;
            // エフェクトを表示
            transform.GetChild(0).gameObject.SetActive(true);

            // 2秒後コイン削除
            Destroy(collision.gameObject,2f);
        }
    }
}
