using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ImageCounterDataInsert : MonoBehaviour {
    [Header("-----------------------------")]
    [Header("数値を更新するテスト用クラス")]
    [Header("-----------------------------")]
    [Space(10)]

    public GameObject imageCounter;

    public bool autoUpdate = false;

    public void UpdateData(int updateData)
    {
        imageCounter.GetComponent<ImageCountController>().UpdateCounter(
            imageCounter.GetComponent<ImageCountController>().countData+(long)updateData
            );

    }

    private void Update()
    {
        if (autoUpdate)
        {
            imageCounter.GetComponent<ImageCountController>().UpdateCounter(
                imageCounter.GetComponent<ImageCountController>().countData + 1
                );
        }
    }
}
