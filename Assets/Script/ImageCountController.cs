using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ImageCountController : MonoBehaviour
{
    [Header("countDataに入力されている値を画像で表示するクラス")]
    [Header("画像を更新する場合はUpdateCounter()を呼び出す")]
    [Header("UpdateCounter(long)のかっこ内に数値を入れると")]
    [Header("その値で更新される")]
    [Header("ImageCountSetImageData.csも追加しないと動かない")]

    [Header("-----------------------------")]

    [Space(5)]

    [Header("表示する数値データ（long型）")]
    public long countData;

    [Header("設定する画像オブジェクト")]
    [SerializeField]
    private GameObject[] imageObjects;

    // 表示する画像一覧
    private ImageCountSetImageData imageCountSetImageData;

    private int maxCharacters = 0;

    // 初期化用の最大桁数
    private int initialMaxCharacters;

    [Header("表示する桁数")]
    [SerializeField]
    private int displayDigits = 0;

    [Header("チェックすると値を強制更新")]
    [SerializeField]
    private bool testInput = false;

    private void Start()
    {
        // 表示桁が0の時自動で全桁表示する
        // 入力された桁が0又は登録されている画像の数を超えた場合
        // 強制的に登録されている画像の桁数に補正される
        if (displayDigits == 0 || displayDigits > transform.childCount)
        {
            maxCharacters = transform.childCount-1;
        }
        else
        {
            int workForDigitsReduction = displayDigits;
            // 表示桁の加算
            for (int i = transform.childCount-1; i >= 0; i--)
            {

                // 有効桁を超える桁は非アクティブ化する
                if (workForDigitsReduction > 0)
                {
                    transform.GetChild(i).gameObject.SetActive(true);
                }
                else
                {
                    transform.GetChild(i).gameObject.SetActive(false);
                }
                workForDigitsReduction--;
            }

            maxCharacters = displayDigits;
        }
        print(maxCharacters);
        // 初期化用の最大桁数を設定
        initialMaxCharacters = maxCharacters;

        // 画像のデータ取得
        if (GetComponent<ImageCountSetImageData>() == null)
        {

            print("ImageCountSetImageDataのスクリプトを追加してください");
        }
        imageCountSetImageData = GetComponent<ImageCountSetImageData>();
    }

    private void Update()
    {
        // テスト用
        if (testInput)
        {
            UpdateCounter();
            testInput = false;
        }
    }

    /// <summary>
    /// 表示する数値をパブリック変数で指定する場合
    /// </summary>
    public void UpdateCounter()
    {
        UpdateCounter(countData);
    }
    /// <summary>
    /// 表示する数値を引数で指定する場合
    /// </summary>
    /// <param name="countData"></param>
    public void UpdateCounter(long countData)
    {
        this.countData = countData;
        // 最大の桁数まで画像を描画する
        while (maxCharacters > 0)
        {
            // 割る値の算出
            long divisor = (long)System.Math.Pow(10, maxCharacters);
            //print("divisor" + divisor);
            //print("maxCharacters" + maxCharacters);

            // 商を算出
            long dividedValue = countData / divisor;

            // 算出した商が9を超えていた場合は限界値を上回っているので
            // すべてのデータを9で埋めて終了する
            if (dividedValue > 9)
            {           
                for (int i = 0; i <= initialMaxCharacters; i++)
                {
                    imageObjects[i].GetComponent<Image>().sprite =
                        Sprite.Create(imageCountSetImageData.GetTexture2D(9),
                        new Rect(0, 0,
                            imageCountSetImageData.GetTexture2D(9).width,
                            imageCountSetImageData.GetTexture2D(9).height),
                        Vector2.zero);
                }
                return;
            }
            countData = countData % divisor;
            //print("dividedValue" + dividedValue);

            // イメージの張替え
            imageObjects[maxCharacters].GetComponent<Image>().sprite =
                Sprite.Create(imageCountSetImageData.GetTexture2D((int)dividedValue),
                new Rect(0, 0,
                    imageCountSetImageData.GetTexture2D((int)dividedValue).width,
                    imageCountSetImageData.GetTexture2D((int)dividedValue).height),
                Vector2.zero);

            maxCharacters--;
        }

        // イメージの張替え
        imageObjects[0].GetComponent<Image>().sprite =
            Sprite.Create(imageCountSetImageData.GetTexture2D((int)countData),
            new Rect(0, 0,
                imageCountSetImageData.GetTexture2D((int)countData).width,
                imageCountSetImageData.GetTexture2D((int)countData).height),
            Vector2.zero);
        maxCharacters = initialMaxCharacters;
    }
}
