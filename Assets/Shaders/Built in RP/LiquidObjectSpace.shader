Shader "Unlit/LiquidObjectSpace"
{
    Properties
    {
        _BoundingBox("Bounding Box", vector) = (1.0, 1.0, 1.0, 1.0)
        _Fill ("Fill", Range(0.0,1.0)) = 1.0
        _FillTurbulence("Fill Turbulence", float) = 1.0
        _FoamColor("Foam Color", color) = (1.0,1.0,1.0,1.0)
        _FoamThickness("Foam Thickness", float) = 0.3
        _FoamFallOff("Foam Fall off", float) = 1.0
        _CosmosTexture("Cosmos Texture", 2D) = "white" {}
        _ParallaxDisplacement ("Displacement Map", 2D) = "bump" {}
        _DisplacementAmount("Displacement Ammount", float) = 0.0
        _DisplacementVelX("Displacement Velocitry X", float) = 0.0
        _DisplacementVelY("Displacement Velocitry Y", float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off
            CGPROGRAM
            #define PI 3.14159265
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 objVertex : TEXCOORD2;
                float3 objViewDir : TEXCOORD3;
                float3 normal : NORMAL;
                float4 cosmosUv : TEXCOORD4;
                float2 displacementUv : TEXCOORD5;
            };
            float4 _BoundingBox;
            half _Fill;
            half _FillTurbulence;
            fixed4 _FoamColor;
            half _FoamThickness;
            half _FoamFallOff;
            sampler2D _CosmosTexture;
            

            sampler2D _ParallaxDisplacement;
            float4 _ParallaxDisplacement_ST;
            half _DisplacementAmount;
            half _DisplacementVelX;
            half _DisplacementVelY;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.objVertex = (v.vertex.xyz / _BoundingBox.xyz) * 0.5 + 0.5;
                o.objViewDir = mul(unity_WorldToObject, float4(WorldSpaceViewDir(v.vertex), 1.0));
                o.normal = v.normal;
                o.cosmosUv = ComputeScreenPos(o.vertex);
                o.displacementUv = TRANSFORM_TEX(v.uv, _ParallaxDisplacement);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float height = i.objVertex.y + sin((i.objVertex.x + _Time.y * _DisplacementVelX) * 2 * PI * _FillTurbulence) * 0.01;
                if(height > _Fill) discard;
                float2 parallaxUv = ParallaxOffset(_DisplacementAmount, tex2D(_ParallaxDisplacement, i.displacementUv).r, normalize(i.objViewDir));
                fixed4 smoke = tex2D(_ParallaxDisplacement, i.displacementUv + parallaxUv + _Time.y * float2(_DisplacementVelX, _DisplacementVelY)).r;
                fixed4 col = tex2D(_CosmosTexture, i.cosmosUv.xy / i.cosmosUv.w) + smoke;
                half hardFoam = step(0.001, -dot(normalize(i.normal), normalize(i.objViewDir)));
                half smoothFoam = (1 - saturate(pow(smoothstep(0,_FoamThickness, _Fill - height), _FoamFallOff))) * (1-hardFoam);
                half foam = smoothFoam + hardFoam;
                UNITY_APPLY_FOG(i.fogCoord, col);

                return lerp(col, _FoamColor, foam);
            }
            ENDCG
        }
    }
}
