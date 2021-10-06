using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightCollision : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.TryGetComponent(out ILightCollider collider))
        {
            collider.ActivateCollisions();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.TryGetComponent(out ILightCollider collider))
        {
            collider.DisableCollisions();
        }
    }
}
