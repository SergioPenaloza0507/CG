Shader "Unlit/InvertColorsDistort"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Distortion ("Distortion Map", 2D) = "bump" {}
        _DistortionParams ("Distortion Parameters", vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100
        GrabPass
        {
            "_GrabTex"
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 screenSpaceUv : TEXCOORD2;
                float depth : DEPTH;
            };

            sampler2D _MainTex;
            sampler2D _GrabTex;
            sampler2D _CameraDepthTexture ;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenSpaceUv = ComputeScreenPos(o.vertex);
                COMPUTE_EYEDEPTH(o.depth)
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float2 ssUv = i.screenSpaceUv.xy / i.screenSpaceUv.w;
                float intersection = saturate(smoothstep(0, 0.3,LinearEyeDepth(tex2D(_CameraDepthTexture , ssUv)) - i.depth));// );
                fixed4 grabTex = 1 - tex2D(_GrabTex, ssUv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return lerp(1, grabTex, intersection);
            }
            ENDCG
        }
    }
}
