Shader "Unlit/VatSample"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PosTex("position texture", 2D) = "black"{}
		_Length ("animation length", Float) = 1
		[Toggle(ANIM_LOOP)] _Loop("loop", Float) = 0
		[IntRange]_Detail("Detail" , Range(1,5)) = 2        
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
			float _Length, _Detail;

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
				float4 pos = tex2Dlod(_PosTex, float4(x, y, 0.0f, 0.0f));
				fixed SCALE_CONVERSION = 1.5f * 100.0f;
				float CorrectionValue = pow(10, 5 - _Detail) / SCALE_CONVERSION;

				v2f o;
                o.vertex = UnityObjectToClipPos(CorrectionValue * float4(- (pos.x - 0.5f), pos.y - 0.5f, pos.z - 0.5f, 0.0f));
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
