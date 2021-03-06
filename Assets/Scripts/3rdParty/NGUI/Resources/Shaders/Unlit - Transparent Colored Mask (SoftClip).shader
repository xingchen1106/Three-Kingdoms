Shader "Unlit/Transparent Colored Mask (SoftClip)"
{
	Properties
	{
		_MainTex ("Base (RGB), Alpha (A)", 2D) = "white" {}
		_MaskTex ("Base (RGB), Alpha (A)", 2D) = "white" {}			
		_Grey ("Grey scale", Range (0,1)) = 0		
	}

	SubShader
	{
		LOD 200

		Tags
		{
			"Queue" = "Transparent-256"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Offset -1, -1
			Fog { Mode Off }
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _MaskTex;
			half4 _MainTex_ST;
			float2 _ClipSharpness = float2(20.0, 20.0);
			float _Grey;
			
			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 worldPos : TEXCOORD1;
			};

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.color = v.color;
				o.texcoord = v.texcoord;
				o.worldPos = TRANSFORM_TEX(v.vertex.xy, _MainTex);
				return o;
			}

			half4 frag (v2f IN) : COLOR
			{
				// Softness factor
				float2 factor = (float2(1.0, 1.0) - abs(IN.worldPos)) * _ClipSharpness;
			
				// Sample the texture
				half4 col = tex2D(_MainTex, IN.texcoord) * IN.color;
				half4 mask = tex2D(_MaskTex, IN.texcoord);
				float fade = clamp( min(factor.x, factor.y), 0.0, 1.0);
				col.a *= fade;
				col.rgb = lerp(half3(0.0, 0.0, 0.0), col.rgb, fade);
				col.a = min(col.a, mask.a);
				
				if(col.r < 0.5 &&
					col.g < 0.5 &&
					col.b < 0.5 &&
					col.a < 1 &&
					fade > 0.5)
				{
				//删除摄像机背景色
					col.a = 1;
				}
				
				//if (_Grey > 0.5)
			//	{
				//	fixed grayscale = Luminance(col.rgb);
				//	col = half4(grayscale, grayscale, grayscale, col.a);
				//}
								
				return col;
			}
			ENDCG
		}
	}
	Fallback Off
}