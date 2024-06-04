Shader "CurissShaders/DistortionParticles" 
{
	Properties
	{
		_BumpTex("Normal map", 2D) = "black" {}
		_Distortion("Distortion", Range(0,1000)) = 10
	}

	SubShader
	{
		Tags { "Queue" = "Transparent+1"  "IgnoreProjector" = "True"  "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha Cull Off Lighting Off ZWrite Off

		GrabPass {"_DistortionParticles"}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			uniform sampler2D _BumpTex;
			uniform sampler2D _DistortionParticles;
			uniform float4 _DistortionParticles_TexelSize;
			uniform float _Distortion;

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 texcoord: TEXCOORD0;
				half4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uvgrab : TEXCOORD0;
				float2 uvbump : TEXCOORD1;
				half4 color : COLOR;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;

			#if UNITY_UV_STARTS_AT_TOP
				half scale = -1.0;
			#else
				half scale = 1.0;
			#endif

				o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
				o.uvgrab.zw = o.vertex.w;

			#if UNITY_SINGLE_PASS_STEREO
				o.uvgrab.xy = TransformStereoScreenSpaceTex(o.uvgrab.xy, o.uvgrab.w);
			#endif

				o.uvgrab.z /= distance(_WorldSpaceCameraPos, mul(unity_ObjectToWorld, v.vertex));
				o.uvbump = v.texcoord;

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half3 bump = UnpackNormal(tex2D(_BumpTex, i.uvbump));
				half2 offset = bump.rg;
				half alphaBump = abs(bump.z - 1) * 255;

				clip(alphaBump - 0.1);
				offset = offset * _Distortion * _DistortionParticles_TexelSize.xy * i.color.a;
				i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;

				half4 col = tex2Dproj(_DistortionParticles, UNITY_PROJ_COORD(i.uvgrab));
				col.a = saturate(col.a * alphaBump);

				return col;
			}
			ENDCG
		}
	}
}