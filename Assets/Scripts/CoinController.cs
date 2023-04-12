using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoinController : MonoBehaviour {

    [SerializeField,Header("プレイヤーの手持ちコイン")]
    private int playerCoin = 10;

    public int PlayerCoin
    {
        get
        {
            return playerCoin;
        }

        set
        {
            playerCoin = value;
        }
    }

    /// <summary>
    /// コインを1枚減らす
    /// </summary>
    /// <returns>減らすことができたかどうか</returns>
    public bool CoinDecreaseOne()
    {
        // コインが0よりも多いときコインを1減らす
        if(PlayerCoin > 0)
        {
            PlayerCoin--;
            return true;
        }
        return false;
    }

    /// <summary>
    /// コインを1枚増やす
    /// </summary>
    public void SetCoin()
    {
        SetCoin(1);
    }
    /// <summary>
    /// コインを増やす（増やす量指定版）
    /// </summary>
    /// <param name="coin">増やすコインの量</param>
    public void SetCoin(int coin)
    {
        PlayerCoin += coin;
    }

    /// <summary>
    /// 現在の手持ちコインを返す
    /// </summary>
    /// <returns>手持ちコイン</returns>
    public int GetCoin()
    {
        return PlayerCoin;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#elif UNITY_STANDALONE
    UnityEngine.Application.Quit();
#endif
        }
    }
}
