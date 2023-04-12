using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageCounterAutoUpdate : MonoBehaviour {

    [SerializeField, Header("CoinControllerオブジェクトを指定する")]
    GameObject coinControllerObject;

    CoinController coinController;

    ImageCountController imageCountController;

    // 前回のコイン
    int lastCoin = 0;

    private void Start()
    {
        coinController = coinControllerObject.GetComponent<CoinController>();
        imageCountController = GetComponent<ImageCountController>();


    }
    void Update () {
        int coin = coinController.GetCoin();
        
        if (lastCoin !=  coin)
        {
            if (lastCoin < coin)
            {

                transform.parent.GetComponent<Animator>().SetTrigger("GetCoin");
            }
            imageCountController.UpdateCounter(coinController.GetCoin());
            lastCoin = coin;
        }
        
    }
}
