Shader "Unlit/Glitch"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GlitchIntensity ("Glitch Intensity", Range(0,1)) = 0.1
        _BlockScale("Block Scale", Range(1,50)) = 10
        _NoiseSpeed("Noise Speed", Range(1,10)) = 10
    }
    SubShader
    {
        Tags 
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }
        LOD 100

        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _GlitchIntensity;
            float _BlockScale;
            float _NoiseSpeed;

            float rand(float2 uv)
            {
                return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
            }

            float blockNoise(float2 uv, float s = 1.0)
            {
                uv=floor(uv*s);
                return rand(uv);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col;
                float2 gv = i.uv;

                // ずらす縦の大きさを決める
                float noise = blockNoise(i.uv.y, _BlockScale);
                
                // 時間で変わるランダムな値
                float2 randomValue = blockNoise(float2(i.uv.y, _Time.y * _NoiseSpeed)) * 2. - 1.;

                // uvをずらす
                gv.x += randomValue * _GlitchIntensity * noise * frac(_Time.y);
                
                // 色収差する
                col.r = tex2D(_MainTex, gv + float2(0.006, 0)).r;
                col.g = tex2D(_MainTex, gv).g;
                col.b = tex2D(_MainTex, gv - float2(0.008, 0)).b;
                col.a = tex2D(_MainTex, gv).a;

                return col;
            }
            ENDCG
        }
    }
}
