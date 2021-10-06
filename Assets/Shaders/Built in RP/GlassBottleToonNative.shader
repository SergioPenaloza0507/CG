// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/GlassBottleToonNative"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FresnelPower ("Fresnel Power", float) = 0.0
        _GlassColor ("Glass Color", color) = (1.0,1.0,1.0,1.0)
        _SpecularHardness ("Specular Hardness", float) = 1.0
        _SpecularCutOff("Specular CutOff", Range(1.0, 0.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            colormask 0    
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD2;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            half _FresnelPower;
            fixed4 _GlassColor;
            half _SpecularHardness;
            half _SpecularCutOff;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = mul(unity_ObjectToWorld, v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
              
                float3 intNormal = normalize(i.normal);
                float3 normViewDir = normalize(i.viewDir);
                float rim = saturate(pow(dot(intNormal, normViewDir), _FresnelPower));
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 h = normalize(lightDir + normViewDir);
                float blinnPhong = step(_SpecularCutOff, saturate(pow(saturate(dot(intNormal, h)), _SpecularHardness)));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //return rim;
                return lerp(_GlassColor, 0, rim) + blinnPhong;
            }
            ENDCG
        }
    }
}
