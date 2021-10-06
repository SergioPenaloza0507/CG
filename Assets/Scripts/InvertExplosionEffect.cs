using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InvertExplosionEffect : MonoBehaviour
{
    [SerializeField] private float duration;
    [SerializeField] private float speed;
    [SerializeField] private AnimationCurve expansionCurve;
    [SerializeField] [Range(0, 1)] private float explosionTime;
    [SerializeField] private float explosionForce;
    [SerializeField] private LayerMask explosionLayer;

    private void Start()
    {
        StartCoroutine(Execute());
    }

    IEnumerator Execute()
    {
        float realTime = duration / speed;
        bool exploded = false;
        for (float time = 0; time < realTime; time += Time.deltaTime)
        {
            float playback = time / realTime;
            transform.localScale = Vector3.one * expansionCurve.Evaluate(playback);
            if (playback >= explosionTime && !exploded)
            {
                PerformExplosion();
                exploded = true;
            }
            yield return null;
        }
    }

    void PerformExplosion()
    {
        foreach (Collider collider1 in Physics.OverlapSphere(transform.position, explosionLayer))
        {
            if (collider1.TryGetComponent(out Rigidbody r))
            {
                r.AddExplosionForce(explosionForce,transform.position,transform.localScale.magnitude);
            }
        }
    }
}
