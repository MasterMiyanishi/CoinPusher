using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageCountSetImageData : MonoBehaviour {

    [Header("ImageCountControllerで使用する画像データ")]
    [Header("GetCount()で登録されている画像の枚数を出力")]
    [Header("GetTexture2D(int index)で指定されたindexの")]
    [Header("画像データをTexture2Dで返す")]
    [Header("-----------------------------")]

    [Space(5)]

    [Header("表示する画像一覧")]
    [SerializeField]
    Texture2D[] setImageSource;

    /// <summary>
    /// 登録されている画像の枚数を出力
    /// </summary>
    /// <returns>画像の枚数</returns>
    public int GetCount()
    {
        return setImageSource.Length;
    }

    /// <summary>
    /// 指定されたindexの画像データをTexture2Dで返す
    /// </summary>
    /// <param name="index">取得したい画像データの番号</param>
    /// <returns>indexの画像データをTexture2D</returns>
    public Texture2D GetTexture2D(int index)
    {
        return setImageSource[index];
    }
}
