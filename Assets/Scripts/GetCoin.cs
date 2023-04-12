using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetCoin : MonoBehaviour {

    [SerializeField ,Header("CoinControllerオブジェクトを指定する")]
    GameObject coinControllerObject;

    CoinController coinController;
    private void Start()
    {
        coinController = coinControllerObject.GetComponent<CoinController>();
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Coin")
        {
            coinController.SetCoin();
            Destroy(collision.gameObject, 1f);
        }
    }
}
