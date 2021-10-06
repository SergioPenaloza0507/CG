using System;
using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.Animations.Rigging;

[RequireComponent(typeof(Animator))]
public class CharacterMortionControllerRE : MonoBehaviour
{
    private const string VELOCITY_SPEED_PARAM = "Velocity";
    private const string SET_AIM_PARAM = "AimEnter";
    private const string UNSET_AIM_PARAM = "AimExit";
    
    [Header("Movement")]
    [SerializeField] private float moveSpeed = 1f;
    [SerializeField] private float turnSpeed;
    [SerializeField] private CinemachineVirtualCamera baseVirtualCamera;


    [Header("Aim")]
    [SerializeField] private float aimTurningSpeed = 20f;
    [SerializeField] private float aimingSocketDistance = 6f;
    [SerializeField] private Transform aimingSocket;
    [SerializeField] private Transform aimingTarget;
    [SerializeField] private float aimSpringArmLength;
    [SerializeField] private Vector3 localSpaceAimSpringArmStart;
    [SerializeField] private LayerMask preventAimCollisionMask;
    [SerializeField] private TwoBoneIKConstraint leftIk, rightIk;
    [SerializeField] private Transform gunSocket;
    [SerializeField] private CinemachineVirtualCamera aimingVirtualCamera;

    [SerializeField] private Material mat;

    [Header("Shoot")] 
    [SerializeField] private float areaRadius;


    private Vector3 motionTarget;
    private float rotationValue;
    private Vector3 iKTarget;
    private Vector3 iKTargetDir;

    private Animator anim;
    private bool aiming;
    private bool canShoot;
    private void Awake()
    {
        anim = GetComponent<Animator>();
    }

    void Start()
    {
        motionTarget = transform.forward;
    }

    void Update()
    {
        if (!aiming)
        {
            Vector3 cameraVector = Vector3.ProjectOnPlane(Camera.main.transform.forward, transform.up) *
                                   Input.GetAxis("Vertical");
            Vector3 characterVector = transform.right * (Input.GetAxis("Horizontal") * turnSpeed) +
                                      transform.forward * (Input.GetAxis("Vertical") * moveSpeed);
            motionTarget = (characterVector) * Time.deltaTime;


            anim.SetFloat(VELOCITY_SPEED_PARAM, motionTarget.magnitude * Input.GetAxis("Vertical"));
            if (Input.GetButtonDown("Fire2"))
            {
                aiming = true;
                anim.SetTrigger(SET_AIM_PARAM);
                baseVirtualCamera.gameObject.SetActive(false);
                aimingVirtualCamera.gameObject.SetActive(true);
                gunSocket.gameObject.SetActive(true);
                leftIk.weight = 1;
                rightIk.weight = 1;
            }
        }
        else
        {
            Vector2 mousePos = Input.mousePosition;
            if (mousePos.x / (float)Screen.width < 0.4f)
            {
                rotationValue = -aimTurningSpeed;
            }
            else if(mousePos.x / (float)Screen.width > 0.6f)
            {
                rotationValue = aimTurningSpeed;
            }
            else
            {
                rotationValue = 0;
            }

            Vector3 worldSpaceAiminSpringArmStart = transform.position + localSpaceAimSpringArmStart;
            

           
            
            aimingSocket.transform.position = Camera.main.ScreenToWorldPoint(new Vector3(Input.mousePosition.x,
                Input.mousePosition.y, aimingSocketDistance));
            iKTargetDir = (aimingSocket.position - worldSpaceAiminSpringArmStart).normalized;
            iKTarget = worldSpaceAiminSpringArmStart +
                       iKTargetDir * aimSpringArmLength;
            canShoot = true;
            if (Physics.Raycast(worldSpaceAiminSpringArmStart, iKTargetDir, aimSpringArmLength,
                preventAimCollisionMask))
            {
                canShoot = false;
            }
            if (Physics.Raycast(worldSpaceAiminSpringArmStart, iKTargetDir, out RaycastHit hit, Mathf.Infinity,
                preventAimCollisionMask))
            {
                aimingTarget.position = hit.point;
            }
            else
            {
                aimingTarget.position = aimingSocket.position;
            }
            if (Input.GetButtonUp("Fire2"))
            {
                aiming = false;
                anim.SetTrigger(UNSET_AIM_PARAM);
                baseVirtualCamera.gameObject.SetActive(true);
                aimingVirtualCamera.gameObject.SetActive(false);
                leftIk.weight = 0;
                rightIk.weight = 0;
                gunSocket.gameObject.SetActive(false);

            }
        }
    }

    private void LateUpdate()
    {
        if (!aiming)
        {
            if (Mathf.Abs(Vector3.SignedAngle(transform.forward, motionTarget, transform.up)) < 70)
            {
                transform.LookAt(transform.position + motionTarget.normalized);
            }
        }
        else
        {
            transform.Rotate(transform.up * (rotationValue * Time.deltaTime));
            gunSocket.position = iKTarget;
            gunSocket.right = iKTargetDir;
            gunSocket.rotation = quaternion.LookRotation(iKTargetDir, transform.up);
        }
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Vector3 worldSpaceAiminSpringArmStart = transform.position + localSpaceAimSpringArmStart;

        Gizmos.DrawLine(worldSpaceAiminSpringArmStart,worldSpaceAiminSpringArmStart + (aimingSocket.position - worldSpaceAiminSpringArmStart).normalized * aimSpringArmLength);
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(iKTarget, 0.5f);
    }
#endif
}
