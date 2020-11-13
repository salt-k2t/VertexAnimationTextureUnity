Shader "Unlit/VertexAnimation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PosTex("position texture", 2D) = "black"{}
		_Length ("animation length", Float) = 1
		[Toggle(ANIM_LOOP)] _Loop("loop", Float) = 0
		_Scale("Scale" , Range(0,1)) = 0.1
		_Middle("middle" , Range(0,1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100 Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile ___ ANIM_LOOP

			#include "UnityCG.cginc"

			//#define ts _PosTex_TexelSize

			struct appdata
			{
                float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
				float3 normal : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex, _PosTex;
            float4 _MainTex_ST;
			float4 _PosTex_TexelSize;
			float _Length, _Scale;

			#define ts _PosTex_TexelSize
			
			v2f vert (appdata v, uint vid : SV_VertexID)
			{
                float t = float(_Time.y) / _Length;
                #if ANIM_LOOP
				t = fmod(t, 1.0f);
                #else
				t = saturate(t);
                #endif
                float x = float(vid + 0.5f) * ts.x; // ts.x = 1.0/width
				float y = 1.0f - t;
				float4 dif_pos = tex2Dlod(_PosTex, float4(x, y, 0.0f, 0.0f));
                float4 middle = float4(0.5f, -0.5f, -0.5f, 0.0f);
				v2f o;
                o.vertex = UnityObjectToClipPos(_Scale * (float4(- dif_pos.x, dif_pos.y, dif_pos.z, 0.0f) + middle));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
            ENDCG
		}
	}
}
