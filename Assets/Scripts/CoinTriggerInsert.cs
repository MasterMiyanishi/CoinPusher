using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoinTriggerInsert : MonoBehaviour {

    [Header("発射されるオブジェクト")]
    public GameObject insertObject;

    float nowTime = 0f;

    [SerializeField, Header("発射してから次回発射までの待ち時間")]
    private float waitTime = 1f;

    [SerializeField, Header("自分の位置から出現する場合はチェック")]
    private bool ownPosition = false;

    [SerializeField, Header("出現する位置")]
    private Vector3 popPosition;

    [SerializeField, Header("発射する速度Zで奥へYで上へXで右へ")]
    private Vector3 skipForce;

    [SerializeField, Header("左右方向に対するブレ")]
    private bool bightLaunchBlur = true;

    [SerializeField, Header("発射する向き")]
    private Vector3 launchFacing;

    [SerializeField, Header("発射するキー")]
    private string launchKey = "Fire1";

    [SerializeField, Header("自動払い出し")]
    private bool autoPayout = false;

    [SerializeField, Header("自動払い出し枚数")]
    private int autoPayoutCount = 10;

    [SerializeField, Header("ボーナス獲得コイン枚数")]
    private int bonusEarnCoin = 5;

    [SerializeField, Header("手持ちコインを減らすかどうか")]
    private bool decreaseOnHandCoin = false;

    [SerializeField, Header("CoinControllerオブジェクトを指定する")]
    GameObject coinControllerObject;

    CoinController coinController;

    [SerializeField, Header("ボーナス獲得時のキャンバス")]
    GameObject bonusCanvas;
    private void Start()
    {
        // コインを投入する場合
        if (decreaseOnHandCoin)
        {
            coinController = coinControllerObject.GetComponent<CoinController>();
        }
    }
    private void Update()
    {
        // 救済処置
        if (Input.GetKeyDown(KeyCode.C))
        {
            autoPayoutCount = 10;
            autoPayout = true;
        }

        // 前回フレームから今回フレームまでの時間を追加
        nowTime += Time.deltaTime;

        if (nowTime > waitTime)
        {
            if (bightLaunchBlur)
            {
                skipForce = new Vector3(skipForce.x * -1f, skipForce.y, skipForce.z);
            }
            // Fire1ボタンが押されかつnowTimeがwaitTimeを超えたら処理する
            if ((launchKey == "" && autoPayout) || (launchKey != "" && Input.GetButton(launchKey)))
            {
                if (autoPayoutCount <= 0)
                {
                    // 自動払い出し終わり
                    autoPayout = false;
                }
                else
                {
                    autoPayoutCount--;
                }


                // 手持ちコインを減らすフラグがtrueならコインを減らす処理を呼び出す
                if (decreaseOnHandCoin)
                {
                    // コインがなかった時は途中で中断する
                    if (!coinController.CoinDecreaseOne())
                    {
                        // 待ち時間をリセット
                        nowTime = 0f;
                        return;
                    }
                }
                else
                {
                    if (autoPayoutCount > 0)
                    {
                        bonusCanvas.GetComponent<Animator>().SetBool("BonusGet", true);
                    }
                    else
                    {
                        bonusCanvas.GetComponent<Animator>().SetBool("BonusGet", false);
                    }
                }
                // オブジェクトを生成する
                GameObject gameObj = Instantiate(insertObject);
                if (ownPosition)
                {
                    // 出現する位置を自分の位置に指定する
                    gameObj.transform.position = transform.position;
                }
                else
                {
                    gameObj.transform.position = popPosition;
                }

                // 出現する向きを指定
                gameObj.transform.Rotate(launchFacing);

                if (gameObj.GetComponent<Rigidbody>() != null)
                {
                    gameObj.GetComponent<Rigidbody>().AddForce(skipForce, ForceMode.Impulse);
                }


                // 待ち時間をリセット
                nowTime = 0f;
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Coin")
        {
            BonusPayout(bonusEarnCoin);
        }
    }

    /// <summary>
    /// ボーナス払い出しメソッド
    /// </summary>
    /// <param name="getCoin">払い出しコイン</param>
    public void BonusPayout(int getCoin)
    {
        autoPayoutCount += getCoin;
        autoPayout = true;
    }
}
