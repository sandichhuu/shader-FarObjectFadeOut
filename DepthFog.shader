// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/DepthFog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Near("Near", float) = 3
        _Far("Far", float) = 6
    }
    SubShader
    {
        Tags 
        {
            "Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
        }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On

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
                float depth : float;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Far;
            fixed _Near;
  
            v2f vert (appdata v)
            {
                float4 worldPosition = mul(unity_ObjectToWorld, v.vertex);

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.depth = length(worldPosition.xyz - _WorldSpaceCameraPos.xyz);
                return o;
            }

            fixed map(fixed s, fixed a1, fixed a2, fixed b1, fixed b2)
            {
                return b1 + (s-a1)*(b2-b1)/(a2-a1);
            }

            fixed4 frag (v2f i) : SV_Target
            { 
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed alpha = map(i.depth, _Near, _Far, 1, 0);
                col.a *= alpha;
                return col;
            }
            ENDCG
        }
    }
}