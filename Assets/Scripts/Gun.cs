using System;
using Unity.Mathematics;
using UnityEngine;

[RequireComponent(typeof(LineRenderer))]
public class Gun : MonoBehaviour
{
    [SerializeField] private ParticleSystem laserPoint;
    [SerializeField] private Transform aimReference;
    [SerializeField] private Transform laserReference;
    [SerializeField] private float areaRadius = 3;
    [SerializeField] private InvertExplosionEffect projectilePrefab;
    private LineRenderer line;
    private void Awake()
    {
        line = GetComponent<LineRenderer>();
        line.positionCount = 2;
    }

    private void Update()
    {
        line.SetPosition(0, laserReference.position);
        var position = aimReference.position;
        line.SetPosition(1, position);
        laserPoint.transform.position = position;
        Shader.SetGlobalVector("position", new Vector4(aimReference.position.x, aimReference.position.y, aimReference.position.z, areaRadius));
        if (Input.GetButtonDown("Fire1"))
        {
            var go = Instantiate(projectilePrefab, aimReference.position, quaternion.identity).gameObject;
            go.SetActive(true);
        }
    }

    private void OnDisable()
    {
        Shader.SetGlobalVector("position", new Vector4(aimReference.position.x, aimReference.position.y, aimReference.position.z, 0));
    }
}
