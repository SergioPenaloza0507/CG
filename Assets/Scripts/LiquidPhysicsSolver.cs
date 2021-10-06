using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LiquidPhysicsSolver : MonoBehaviour
{
    [SerializeField] private Transform liquidTarget;
    [SerializeField] private float radius;
    [SerializeField] private float accelerationScale;
    [SerializeField] private float mass = 1f;
    private Vector3 posLast;

    private Vector3 lastCentripetalForce;
    private Vector3 lastCentripetalAcceleration;
    private Vector3 lastCentripetalVelocity;
    private Vector3 lastEulerAngles;
    private void Awake()
    {
        posLast = transform.position;
    }

    private void Update()
    {
        Vector3 delta = transform.position - posLast;
        Vector3 quadraticVelocity = Vector3.Scale(delta, delta);
        Vector3 centripetalForce = mass * (quadraticVelocity / radius);
        Vector3 centripetalAcceleration = centripetalForce / mass;
        Debug.Log($"CentripetalAcceleration: {centripetalAcceleration}");
        Vector3 centripetalVelocity = lastCentripetalVelocity + lastCentripetalAcceleration * Time.deltaTime;
        Vector3 eulerAngles = lastEulerAngles + centripetalVelocity * Time.deltaTime;
        liquidTarget.eulerAngles = eulerAngles;
        liquidTarget.position = transform.position;
        liquidTarget.LookAt(delta);
        posLast = transform.position;
        lastEulerAngles = eulerAngles;
        lastCentripetalVelocity = centripetalVelocity;
        lastCentripetalAcceleration = centripetalAcceleration;
        lastCentripetalForce = centripetalForce;
    }
}
