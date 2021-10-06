using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class PlayerControllerCameraManager : MonoBehaviour
{
    private Dictionary<string, CinemachineVirtualCamera> cameras = new Dictionary<string, CinemachineVirtualCamera>();

    public void SetupCharacterCameras(string id)
    {
        foreach (var cinemachineVirtualCamera in cameras)
        {
            if (cinemachineVirtualCamera.Key != id)
            {
                cinemachineVirtualCamera.Value.gameObject.SetActive(false);
            }
            else
            {
                cinemachineVirtualCamera.Value.gameObject.SetActive(true);
            }
        }
    }
}
