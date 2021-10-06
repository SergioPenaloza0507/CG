Shader "Custom/TriplanarNoiseWithTexture"
{
    Properties
    {
        _Color ("Color", Color) = (0.5,0.5,0.5,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "black" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _TriplanarBlend ("Triplanar Blend", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #define RANDOM_VECTOR float3(12.9898, 78.233, 37.719)
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NoiseTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
            float3 worldNormal;
            float3 worldPos;
            float eyeDepth;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _TriplanarBlend;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        
        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            COMPUTE_EYEDEPTH(o.eyeDepth);
        }

        float random( float2 p )
		{
			return frac(sin(dot(p.xy,float2(_Time.y,65.115)))*2773.8856);
		}
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            const float textureScale = lerp(1 , 10, step(10, IN.eyeDepth));
            const float2 yUv = IN.worldPos.xz / textureScale;
            const float2 xUv = IN.worldPos.zy / textureScale;
            const float2 zUv = IN.worldPos.xy / textureScale;

            const half4 yCol = tex2D(_MainTex, yUv);
            const half4 xCol = tex2D(_MainTex, xUv);
            const half4 zCol = tex2D(_MainTex, zUv);
            half3 blend = pow(IN.worldNormal, _TriplanarBlend);
            blend /= blend.x + blend.y + blend.z;
            const half4 triPlanarCol = (xCol * blend.x + yCol * blend.y + zCol * blend.z) * _Color;
            o.Albedo = triPlanarCol;
            // Metallic and smoothness come from slider variables
            o.Metallic = tex2D(_NoiseTex, IN.uv_NoiseTex).r;
            o.Smoothness = 1 - tex2D(_NoiseTex, IN.uv_NoiseTex).r;
            o.Alpha = triPlanarCol.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
