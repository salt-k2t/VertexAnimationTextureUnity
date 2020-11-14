Shader "Unlit/VertexAnimation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_VatTex("VertexAnimationTexture", 2D) = "white"{}
		_Length ("AnimationLength", Float) = 1
		[Toggle(IS_LOOP)] _IsLoop("IsLoop", Float) = 0
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
			#pragma multi_compile ___ IS_LOOP

			#include "UnityCG.cginc"

			#define ts _VatTex_TexelSize

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

			sampler2D _MainTex, _VatTex;
			float4 _MainTex_ST;
			float4 _VatTex_TexelSize;
			float _Length, _Detail;
			
			v2f vert (appdata v, uint vid : SV_VertexID)
			{
				float t = float(_Time.y) / _Length;
				#if IS_LOOP
					t = fmod(t, 1.0f);
				#else
					t = saturate(t);
				#endif

				float x = float(vid + 0.5f) * ts.x; // ts.x = 1.0/width
				float y = 1.0f - t;
				float4 dif_pos = tex2Dlod(_VatTex, float4(x, y, 0.0f, 0.0f));
				float ScaleCorrectionValue = 1.0f / (1.5f * 100.0f) * pow(10, 5 - _Detail);
				
				v2f o;
				o.vertex = UnityObjectToClipPos(ScaleCorrectionValue * (float4(-(dif_pos.x -0.5f), dif_pos.y -0.5f, dif_pos.z -0.5f, 0.0f)));
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
